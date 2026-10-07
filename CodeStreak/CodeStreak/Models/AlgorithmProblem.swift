import Foundation

enum ProblemDifficulty: String, Codable, CaseIterable, Hashable, Sendable {
    case easy
    case medium
    case hard

    var title: String { rawValue.capitalized }

    var rank: Int {
        switch self {
        case .easy: 0
        case .medium: 1
        case .hard: 2
        }
    }
}

struct ProblemExample: Hashable, Sendable {
    let input: String
    let output: String
    let explanation: String?

    init(input: String, output: String, explanation: String? = nil) {
        self.input = input
        self.output = output
        self.explanation = explanation
    }
}

/// A plain-language definition for wording that has a precise algorithmic
/// meaning. Showing these next to the prompt prevents learners from having to
/// guess whether words such as "consecutive" refer to values or positions.
struct ProblemReadingNote: Identifiable, Hashable, Sendable {
    let id: String
    let term: String
    let explanation: String
}

/// One decoded function argument, ready to display without exposing the test
/// runner's outer JSON argument array.
struct ProblemArgumentDisplay: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let value: String
}

struct AlgorithmTestCase: Hashable, Sendable {
    let name: String
    let argumentsJSON: String
    let expectedJSON: String
    let derivesExpectedFromReference: Bool

    init(
        name: String,
        argumentsJSON: String,
        expectedJSON: String,
        derivesExpectedFromReference: Bool = false
    ) {
        self.name = name
        self.argumentsJSON = argumentsJSON
        self.expectedJSON = expectedJSON
        self.derivesExpectedFromReference = derivesExpectedFromReference
    }

    static func adversarial(_ name: String, _ argumentsJSON: String) -> AlgorithmTestCase {
        AlgorithmTestCase(
            name: name,
            argumentsJSON: argumentsJSON,
            expectedJSON: "null",
            derivesExpectedFromReference: true
        )
    }
}

enum SolutionComparisonKind: String, Hashable, Sendable {
    case sameBigO = "Same Big-O"
    case timeSpaceTradeoff = "Time/space trade-off"
    case simplerButSlower = "Simpler, slower"
    case constraintDependent = "Constraint-dependent"
}

/// A second valid way to think about a problem, including the cost hidden by
/// Big-O shorthand. These comparisons teach that "optimal" depends on input
/// constraints, memory, constant factors, readability, and early-exit behavior.
struct SolutionAlternative: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let kind: SolutionComparisonKind
    let summary: String
    let timeComplexity: String
    let spaceComplexity: String
    let bestWhen: String
    let tradeoff: String
    let code: String?
}

/// A framework-oriented formulation learners are likely to write in real ML
/// research code. It is intentionally separate from the plain-Python oracle
/// that must execute inside CodeStreak's bundled offline interpreter.
struct ProductionSolution: Hashable, Sendable {
    let title: String
    let summary: String
    let requirements: String
    let runtimeNote: String
    let code: String
    let documentationLabel: String
    let documentationURL: URL
    let einsumAlternative: EinsumSolution?
}

/// An optional named-axis formulation for contractions whose shape bookkeeping
/// is genuinely easier to audit with einsum. Simple elementwise operations and
/// explicitly "from scratch" exercises should not manufacture one.
struct EinsumSolution: Hashable, Sendable {
    let title: String
    let summary: String
    let requirements: String
    let code: String
    let documentationURL: URL
}

struct AlgorithmProblem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let difficulty: ProblemDifficulty
    let estimatedMinutes: Int
    let whyItMatters: String
    let prompt: String
    let examples: [ProblemExample]
    let constraints: [String]
    let functionName: String
    let starterCode: String
    let hints: [String]
    let referenceSolution: String
    let solutionExplanation: String
    let timeComplexity: String
    let spaceComplexity: String
    let tests: [AlgorithmTestCase]

    var validationTests: [AlgorithmTestCase] {
        tests + AdversarialTestCatalog.tests(for: id)
    }

    /// The learner-facing version of the executable oracle. Its comments are
    /// assembled from the same curated strategy, proof, and complexity notes
    /// as the problem card, so every reference solution explains its intent.
    /// The runner continues to execute `referenceSolution` without annotations.
    var annotatedReferenceSolution: String {
        ReferenceSolutionAnnotator.annotate(
            source: referenceSolution,
            strategy: hints.first ?? whyItMatters,
            explanation: solutionExplanation,
            timeComplexity: timeComplexity,
            spaceComplexity: spaceComplexity
        )
    }

    var solutionAlternatives: [SolutionAlternative] {
        SolutionComparisonCatalog.alternatives(for: id)
    }

    var productionSolution: ProductionSolution? {
        MLProductionSolutionCatalog.solution(for: id)
    }

    var readingNotes: [ProblemReadingNote] {
        ProblemLanguageGuide.notes(for: self)
    }

    var parameterNames: [String] {
        guard
            let opening = starterCode.firstIndex(of: "("),
            let closing = starterCode[opening...].firstIndex(of: ")")
        else {
            return []
        }

        return starterCode[starterCode.index(after: opening)..<closing]
            .split(separator: ",")
            .map { parameter in
                parameter
                    .split(separator: "=", maxSplits: 1)
                    .first
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } ?? ""
            }
            .filter { !$0.isEmpty }
    }

    /// Converts a runner test such as `[[8,3,5,4,20]]` into the learner-facing
    /// row `numbers = [8, 3, 5, 4, 20]`.
    func displayedArguments(for test: AlgorithmTestCase) -> [ProblemArgumentDisplay] {
        guard
            let data = test.argumentsJSON.data(using: .utf8),
            let arguments = try? JSONSerialization.jsonObject(with: data) as? [Any]
        else {
            return [ProblemArgumentDisplay(id: "arguments", name: "arguments", value: test.argumentsJSON)]
        }

        return arguments.enumerated().map { index, argument in
            let name = parameterNames.indices.contains(index) ? parameterNames[index] : "argument \(index + 1)"
            return ProblemArgumentDisplay(
                id: "\(index)-\(name)",
                name: name,
                value: Self.displayJSON(argument)
            )
        }
    }

    private static func displayJSON(_ value: Any) -> String {
        guard let data = try? JSONSerialization.data(
            withJSONObject: value,
            options: [.fragmentsAllowed, .sortedKeys]
        ) else {
            return String(describing: value)
        }
        return String(data: data, encoding: .utf8) ?? String(describing: value)
    }
}

private enum ReferenceSolutionAnnotator {
    private static let maximumLineLength = 96

    static func annotate(
        source: String,
        strategy: String,
        explanation: String,
        timeComplexity: String,
        spaceComplexity: String
    ) -> String {
        var lines = source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard let definitionIndex = lines.firstIndex(where: { line in
            line.trimmingCharacters(in: .whitespaces).hasPrefix("def ")
        }) else {
            return source
        }

        let definitionIndent = String(lines[definitionIndex].prefix { $0 == " " || $0 == "\t" })
        let bodyIndent = definitionIndent + "    "
        let comments = wrappedComment(label: "Strategy", text: strategy, indent: bodyIndent)
            + wrappedComment(label: "Why it works", text: explanation, indent: bodyIndent)
            + wrappedComment(
                label: "Complexity",
                text: "\(timeComplexity) time; \(spaceComplexity) extra space.",
                indent: bodyIndent
            )

        lines.insert(contentsOf: comments, at: definitionIndex + 1)
        return lines.joined(separator: "\n")
    }

    private static func wrappedComment(label: String, text: String, indent: String) -> [String] {
        let words = text.split(whereSeparator: \.isWhitespace).map(String.init)
        guard !words.isEmpty else { return [] }

        let firstPrefix = "\(indent)# \(label): "
        let continuationPrefix = "\(indent)# \(String(repeating: " ", count: label.count + 2))"
        var lines: [String] = []
        var current = firstPrefix

        for word in words {
            let separator = current == firstPrefix || current == continuationPrefix ? "" : " "
            if current.count + separator.count + word.count > maximumLineLength,
               current != firstPrefix,
               current != continuationPrefix {
                lines.append(current)
                current = continuationPrefix + word
            } else {
                current += separator + word
            }
        }

        lines.append(current)
        return lines
    }
}

/// A compact, reusable lesson for one family of algorithm problems.
/// Problems inherit this guidance from their curriculum module so every
/// exercise has a pattern-recognition scaffold without duplicating content.
struct PatternLesson: Hashable, Sendable {
    let mentalModel: String
    let recognitionQuestions: [String]
    let strategySteps: [String]
    let commonPitfalls: [String]
    let complexityTarget: String
}

/// One concrete tool taught before the learner is expected to recognize it in
/// an interview problem. The wording is intentionally independent of CS
/// jargon, and each technique includes a tiny retrieval exercise.
struct AlgorithmTechnique: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let plainLanguageMeaning: String
    let mathematicalView: String
    let useWhen: [String]
    let doNotUseWhen: String
    let invariant: String
    let pythonTemplate: String
    let drillPrompt: String
    let drillHint: String
    let drillAnswer: String
}

struct ModuleCourse: Hashable, Sendable {
    let prerequisites: [String]
    let techniques: [AlgorithmTechnique]
}

enum ProblemLearningMode: String, Hashable, Sendable {
    case guided
    case application
    case blindAssessment

    var title: String {
        switch self {
        case .guided: "Guided example"
        case .application: "Technique practice"
        case .blindAssessment: "Blind check"
        }
    }

    var shortTitle: String {
        switch self {
        case .guided: "Guided"
        case .application: "Practice"
        case .blindAssessment: "Blind"
        }
    }

    var symbol: String {
        switch self {
        case .guided: "figure.walk.motion"
        case .application: "hammer.fill"
        case .blindAssessment: "eye.slash.fill"
        }
    }

    var explanation: String {
        switch self {
        case .guided:
            "The relevant techniques are named. Concentrate on connecting the prompt to the algorithm and tracing its invariant."
        case .application:
            "The module's techniques remain available, but you decide which one fits and adapt it to this contract."
        case .blindAssessment:
            "The pattern is deliberately withheld. Choose among techniques you have already learned, as you would in an interview."
        }
    }
}

struct ProblemLearningPlacement: Hashable, Sendable {
    let mode: ProblemLearningMode
    let requiredTechniqueNames: [String]
    let recommendedProblemIDs: [String]
}

struct LearningResearchSource: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let authorsAndYear: String
    let takeaway: String
    let url: URL
}

struct CurriculumModule: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let symbol: String
    let summary: String
    let recognitionCues: [String]
    let problems: [AlgorithmProblem]

    var lesson: PatternLesson {
        LearningGuidance.lesson(for: id)
    }

    var course: ModuleCourse {
        ModuleTeachingCatalog.course(for: id, fallback: lesson)
    }

    /// Problems remain freely navigable inside the current module. These
    /// placements communicate the intended learning sequence without turning
    /// it into another hard lock.
    func learningPlacement(for problemID: String) -> ProblemLearningPlacement {
        let requiredTechniqueNames = ProblemPrerequisiteCatalog.techniqueIDs(for: problemID)
            .compactMap { ModuleTeachingCatalog.technique(for: $0)?.name }

        guard let index = problems.firstIndex(where: { $0.id == problemID }) else {
            return ProblemLearningPlacement(
                mode: .application,
                requiredTechniqueNames: requiredTechniqueNames,
                recommendedProblemIDs: []
            )
        }

        let count = problems.count
        let guidedCount = count >= 6 ? 2 : 1
        let blindCount = count >= 6 ? 2 : 1
        let mode: ProblemLearningMode
        if index < guidedCount {
            mode = .guided
        } else if index >= count - blindCount {
            mode = .blindAssessment
        } else {
            mode = .application
        }

        let recommendedProblemIDs: [String]
        switch mode {
        case .guided:
            recommendedProblemIDs = Array(problems.prefix(index).map(\.id))
        case .application:
            recommendedProblemIDs = Array(problems.prefix(guidedCount).map(\.id))
        case .blindAssessment:
            recommendedProblemIDs = Array(problems.prefix(index).map(\.id))
        }

        return ProblemLearningPlacement(
            mode: mode,
            requiredTechniqueNames: mode == .blindAssessment ? [] : requiredTechniqueNames,
            recommendedProblemIDs: recommendedProblemIDs
        )
    }
}
