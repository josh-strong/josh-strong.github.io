import XCTest

#if os(macOS)
import AppKit
#endif

#if canImport(SwiftMath)
import SwiftMath
#endif

#if canImport(CodeStreak)
@testable import CodeStreak
#else
@testable import CodeStreakCore
#endif

final class CurriculumTests: XCTestCase {
    func testEveryTechniqueHasACompleteInformativeVisualization() {
        let techniques = ModuleTeachingCatalog.allTechniques
        let taughtIDs = Set(techniques.map(\.id))

        XCTAssertTrue(taughtIDs.isSubset(of: TechniqueVisualizationCatalog.techniqueIDs))
        XCTAssertEqual(
            TechniqueVisualizationCatalog.techniqueIDs.subtracting(taughtIDs),
            ["state-invariant"],
            "The generic fallback course is the only visualization outside the current modules"
        )

        for technique in techniques {
            guard let visual = technique.visualization else {
                XCTFail("Missing visualization: \(technique.id)")
                continue
            }
            XCTAssertFalse(visual.title.isEmpty, technique.id)
            XCTAssertFalse(visual.takeaway.isEmpty, technique.id)

            switch visual.kind {
            case .sequence(let cells):
                XCTAssertGreaterThanOrEqual(cells.count, 3, technique.id)
                XCTAssertTrue(cells.allSatisfy { !$0.label.isEmpty }, technique.id)
                XCTAssertTrue(cells.contains { $0.role != .neutral }, technique.id)
            case .flow(let stages):
                XCTAssertGreaterThanOrEqual(stages.count, 3, technique.id)
                XCTAssertTrue(stages.allSatisfy { !$0.label.isEmpty }, technique.id)
                XCTAssertTrue(stages.contains { $0.role != .neutral }, technique.id)
            case .stack(let cells, _):
                XCTAssertGreaterThanOrEqual(cells.count, 3, technique.id)
                XCTAssertTrue(cells.allSatisfy { !$0.label.isEmpty }, technique.id)
            case .graph(let nodes, let edges):
                let nodeIDs = Set(nodes.map(\.id))
                XCTAssertEqual(nodeIDs.count, nodes.count, technique.id)
                XCTAssertGreaterThanOrEqual(nodes.count, 3, technique.id)
                XCTAssertFalse(edges.isEmpty, technique.id)
                XCTAssertTrue(nodes.allSatisfy { (0...1).contains($0.x) && (0...1).contains($0.y) }, technique.id)
                XCTAssertTrue(edges.allSatisfy { nodeIDs.contains($0.from) && nodeIDs.contains($0.to) }, technique.id)
            case .intervals(let rows):
                XCTAssertGreaterThanOrEqual(rows.count, 3, technique.id)
                XCTAssertTrue(rows.allSatisfy { 0 <= $0.start && $0.start <= $0.end && $0.end <= 1 }, technique.id)
            case .matrix(let rows):
                XCTAssertGreaterThanOrEqual(rows.count, 2, technique.id)
                XCTAssertTrue(rows.allSatisfy { !$0.isEmpty }, technique.id)
                XCTAssertEqual(Set(rows.map(\.count)).count, 1, "Matrix rows must align: \(technique.id)")
            }
        }
    }

    func testEveryTechniqueHasValidLatexMathematics() {
        let techniques = ModuleTeachingCatalog.allTechniques
        let taughtIDs = Set(techniques.map(\.id))

        XCTAssertTrue(
            taughtIDs.isSubset(of: TechniqueLatexCatalog.techniqueIDs),
            "Every taught technique must have a maintained LaTeX formula"
        )
        XCTAssertEqual(
            TechniqueLatexCatalog.techniqueIDs.subtracting(taughtIDs),
            ["state-invariant"],
            "The only non-module formula is the generic fallback lesson"
        )

        for technique in techniques {
            guard let latex = technique.latexFormula else {
                XCTFail("Missing LaTeX formula: \(technique.id)")
                continue
            }
            XCTAssertFalse(latex.isEmpty, technique.id)
            XCTAssertFalse(latex.contains("$"), "SwiftMath expects bare math mode in this view: \(technique.id)")

#if canImport(SwiftMath)
            XCTAssertNotNil(
                MTMathListBuilder.build(fromString: latex),
                "Malformed or unsupported LaTeX for \(technique.id): \(latex)"
            )
#endif
        }
    }

#if canImport(SwiftMath) && os(macOS)
    func testSwiftMathMacLabelReportsAnUnclippedFittingSize() {
        let label = MTMathUILabel()
        label.fontSize = 22
        label.contentInsets = NSEdgeInsets(top: 6, left: 2, bottom: 6, right: 2)
        label.latex = #"\mathrm{softmax}(x)_i=\frac{e^{x_i-m}}{\sum_j e^{x_j-m}}"#

        let fitting = label.fittingSize
        XCTAssertGreaterThan(fitting.width, 100)
        XCTAssertGreaterThan(fitting.height, 22)
        XCTAssertEqual(
            label.intrinsicContentSize.height,
            NSView.noIntrinsicMetric,
            "The wrapper must use fittingSize on macOS; intrinsicContentSize is intentionally unavailable"
        )
    }
#endif

    func testCurriculumHasTwoIndependentTracksAndOneHundredSeventyFourDistinctProblems() {
        XCTAssertEqual(Curriculum.modules.count, 18)
        XCTAssertEqual(Curriculum.mlInterviewModules.count, 4)
        XCTAssertEqual(Curriculum.algorithmProblems.count, 154)
        XCTAssertEqual(Curriculum.mlInterviewProblems.count, 20)
        XCTAssertEqual(Curriculum.allProblems.count, 174)
        XCTAssertEqual(
            Set(Curriculum.allProblems.map { SolutionComparisonCatalog.canonicalID(for: $0.id) }).count,
            Curriculum.allProblems.count,
            "Every path entry must represent a genuinely distinct problem design"
        )
        XCTAssertFalse(
            Curriculum.allProblems.contains { problem in
                ["Foundation", "Boundary cases", "Pattern recall", "Speed round",
                 "Transfer practice", "Interview mode", "Spaced review", "Mastery check"]
                    .contains { label in problem.title.hasSuffix("· \(label)") }
            },
            "Practice modes and review labels must not be presented as separate problems"
        )
    }

    func testProblemIdentifiersAndFunctionNamesAreUnique() {
        XCTAssertEqual(Set(Curriculum.allProblems.map(\.id)).count, Curriculum.allProblems.count)
        XCTAssertEqual(Set(Curriculum.allProblems.map(\.functionName)).count, Curriculum.allProblems.count)
    }

    func testNoTwoPathEntriesReuseTheSameProblemStatement() {
        let normalizedPrompts = Curriculum.allProblems.map { problem in
            problem.prompt
                .lowercased()
                .split(whereSeparator: \.isWhitespace)
                .joined(separator: " ")
        }

        XCTAssertEqual(
            Set(normalizedPrompts).count,
            Curriculum.allProblems.count,
            "Repeated retrieval belongs in the review queue, not in duplicate path entries"
        )
    }

    func testEveryProblemHasProgressiveLearningMaterial() {
        for problem in Curriculum.allProblems {
            XCTAssertFalse(problem.prompt.isEmpty, problem.id)
            XCTAssertFalse(problem.whyItMatters.isEmpty, problem.id)
            XCTAssertFalse(problem.examples.isEmpty, problem.id)
            XCTAssertFalse(problem.constraints.isEmpty, problem.id)
            XCTAssertGreaterThanOrEqual(problem.hints.count, 3, problem.id)
            XCTAssertGreaterThanOrEqual(problem.tests.count, 4, problem.id)
            XCTAssertTrue(problem.tests.allSatisfy { !$0.name.isEmpty }, problem.id)
            XCTAssertFalse(problem.solutionExplanation.isEmpty, problem.id)
            XCTAssertTrue(problem.starterCode.hasPrefix("def "), problem.id)
            XCTAssertTrue(problem.referenceSolution.hasPrefix("def "), problem.id)
            XCTAssertTrue(problem.starterCode.contains(problem.functionName), problem.id)
            XCTAssertTrue(problem.referenceSolution.contains(problem.functionName), problem.id)
        }
    }

    func testEveryReferenceSolutionDisplaysUsefulWrappedComments() {
        for problem in Curriculum.allProblems {
            let annotated = problem.annotatedReferenceSolution
            XCTAssertTrue(annotated.contains("# Strategy:"), problem.id)
            XCTAssertTrue(annotated.contains("# Why it works:"), problem.id)
            XCTAssertTrue(annotated.contains("# Complexity:"), problem.id)
            XCTAssertGreaterThan(annotated.count, problem.referenceSolution.count, problem.id)

            let originalBody = problem.referenceSolution
                .split(separator: "\n", omittingEmptySubsequences: false)
                .dropFirst()
                .joined(separator: "\n")
            XCTAssertTrue(annotated.hasSuffix(originalBody), problem.id)

            let lines = annotated.split(separator: "\n", omittingEmptySubsequences: false)
            guard let definitionIndex = lines.firstIndex(where: {
                $0.trimmingCharacters(in: .whitespaces).hasPrefix("def ")
            }) else {
                XCTFail("Missing function definition: \(problem.id)")
                continue
            }

            let leadingComments = lines.dropFirst(definitionIndex + 1).prefix {
                $0.trimmingCharacters(in: .whitespaces).hasPrefix("#")
            }
            XCTAssertGreaterThanOrEqual(leadingComments.count, 3, problem.id)
            XCTAssertTrue(
                leadingComments.allSatisfy { $0.count <= 96 },
                "Comment wrapping exceeded 96 columns: \(problem.id)"
            )
        }
    }

    func testEveryDistinctProblemDesignHasACuratedSolutionComparison() {
        let expectedCanonicalIDs = Set(
            Curriculum.allProblems.map { SolutionComparisonCatalog.canonicalID(for: $0.id) }
        )

        XCTAssertEqual(expectedCanonicalIDs.count, 174)
        XCTAssertEqual(SolutionComparisonCatalog.curatedProblemIDs, expectedCanonicalIDs)

        for problem in Curriculum.allProblems {
            let alternatives = problem.solutionAlternatives
            XCTAssertFalse(alternatives.isEmpty, problem.id)
            XCTAssertEqual(Set(alternatives.map(\.id)).count, alternatives.count, problem.id)

            for alternative in alternatives {
                XCTAssertFalse(alternative.title.isEmpty, problem.id)
                XCTAssertFalse(alternative.summary.isEmpty, problem.id)
                XCTAssertFalse(alternative.timeComplexity.isEmpty, problem.id)
                XCTAssertFalse(alternative.spaceComplexity.isEmpty, problem.id)
                XCTAssertFalse(alternative.bestWhen.isEmpty, problem.id)
                XCTAssertFalse(alternative.tradeoff.isEmpty, problem.id)
                if let code = alternative.code {
                    XCTAssertTrue(code.hasPrefix("def ") || code.contains("\ndef "), problem.id)
                }
            }
        }
    }

    func testEveryDistinctProblemDesignHasAnAdversarialValidationCase() {
        let expectedCanonicalIDs = Set(
            Curriculum.allProblems.map { SolutionComparisonCatalog.canonicalID(for: $0.id) }
        )

        XCTAssertEqual(expectedCanonicalIDs.count, 174)
        XCTAssertEqual(AdversarialTestCatalog.coveredCanonicalIDs, expectedCanonicalIDs)

        for problem in Curriculum.allProblems {
            XCTAssertGreaterThan(problem.validationTests.count, problem.tests.count, problem.id)
            XCTAssertEqual(Set(problem.validationTests.map(\.name)).count, problem.validationTests.count, problem.id)

            for test in problem.validationTests {
                XCTAssertNotNil(
                    test.argumentsJSON.data(using: .utf8).flatMap {
                        try? JSONSerialization.jsonObject(with: $0, options: [.fragmentsAllowed])
                    },
                    "\(problem.id): \(test.name)"
                )
            }
        }
    }

    func testSameCharacterCountsExplainsTheCounterSolution() throws {
        let problem = try XCTUnwrap(Curriculum.problem(withID: "arrays.same-character-counts"))
        let counter = try XCTUnwrap(problem.solutionAlternatives.first { $0.id == "counter-equality" })

        XCTAssertEqual(counter.kind, .sameBigO)
        XCTAssertEqual(counter.timeComplexity, "O(n + m)")
        XCTAssertTrue(counter.tradeoff.contains("two complete tables"))
        XCTAssertTrue(counter.code?.contains("Counter(first) == Counter(second)") == true)
    }

    func testEveryProblemProvidesPlainLanguageReadingHelpAndNamedArguments() {
        for problem in Curriculum.allProblems {
            let notes = problem.readingNotes
            XCTAssertFalse(notes.isEmpty, problem.id)
            XCTAssertEqual(Set(notes.map(\.id)).count, notes.count, problem.id)
            XCTAssertTrue(notes.allSatisfy { !$0.term.isEmpty && !$0.explanation.isEmpty }, problem.id)
            XCTAssertFalse(problem.parameterNames.isEmpty, problem.id)

            for test in problem.tests {
                let arguments = problem.displayedArguments(for: test)
                XCTAssertEqual(arguments.count, problem.parameterNames.count, "\(problem.id): \(test.name)")
                XCTAssertTrue(arguments.allSatisfy { !$0.name.isEmpty && !$0.value.isEmpty }, problem.id)
            }
        }
    }

    func testLongestConsecutiveSequenceDistinguishesValuesFromPositions() throws {
        let problem = try XCTUnwrap(Curriculum.problem(withID: "arrays.longest-consecutive"))

        XCTAssertEqual(problem.title, "Longest Consecutive-Value Sequence")
        XCTAssertTrue(problem.prompt.contains("anywhere in the list"))
        XCTAssertTrue(problem.prompt.contains("do not need to be adjacent"))
        XCTAssertTrue(problem.prompt.contains("Repeated values count only once"))
        XCTAssertTrue(problem.readingNotes.contains { $0.explanation.contains("[3, 5, 4]") })
        XCTAssertTrue(problem.examples.contains { $0.explanation?.contains("input positions") == true })
        XCTAssertTrue(problem.tests.contains {
            $0.argumentsJSON == "[[3,5,7]]" && $0.expectedJSON == "1"
        })
    }

    func testRunWordingAlwaysDefinesPositionOrValueSemantics() {
        for problem in Curriculum.allProblems where problem.prompt
            .lowercased()
            .components(separatedBy: CharacterSet.letters.inverted)
            .contains("run") {
            let wording = problem.prompt.lowercased()
            XCTAssertTrue(
                wording.contains("contiguous")
                    || wording.contains("substring")
                    || wording.contains("numeric value")
                    || wording.contains("input position"),
                "Ambiguous run wording in \(problem.id): \(problem.prompt)"
            )
        }
    }

    func testEveryEnumeratedOutputDefinesDeterministicOrdering() {
        let enumerations = Curriculum.allProblems.filter { problem in
            let prompt = problem.prompt.lowercased()
            return prompt.contains("return every") || prompt.contains("return all")
        }
        XCTAssertFalse(enumerations.isEmpty)

        for problem in enumerations {
            let contract = ([problem.prompt] + problem.constraints).joined(separator: " ").lowercased()
            XCTAssertTrue(
                contract.contains("order")
                    || contract.contains("lexicographic")
                    || contract.contains("ascending")
                    || contract.contains("sorted output")
                    || contract.contains("first-seen"),
                "Enumerated output lacks a deterministic order in \(problem.id): \(problem.prompt)"
            )
        }
    }

    func testPotentiallyNonUniqueAndBoundaryOutputsStateTheirExactRule() throws {
        let requiredContractFragments: [String: [String]] = [
            "arrays.pair-indices": ["scan left to right", "earlier matching index"],
            "pointers.sorted-pair": ["greatest index distance", "one position cannot be used twice"],
            "pointers.closest-pair": ["equal distance", "lexicographically smaller"],
            "window.minimum-cover": ["same minimum length", "smallest start index", "required is empty"],
            "window.maximum-values": ["valid k satisfies 1 ≤ k ≤ len(numbers)"],
            "binary.peak-index": ["exactly one peak", "one-element list"],
            "greedy.gas-start": ["empty tank", "exactly one valid start"],
            "mastery.sliding-window.max-vowels": ["size <= 0", "size > len(text)"],
            "mastery.sliding-window.k-distinct": ["return the length", "limit <= 0"],
            "mastery.greedy.reorganize": ["at each output position", "greatest remaining frequency", "frequency tie"],
            "mastery.queues-heaps.running-medians": ["odd-sized prefix", "even-sized prefix"],
            "advanced.median-sorted": ["total length is odd", "arithmetic mean"],
            "graphs.word-ladder": ["including end", "counting both start and end", "start == end"],
            "backtracking.phone-letters": ["2→abc", "depth-first keypad order"],
            "ml.scaled-attention": ["0 excludes", "negative infinity", "only over allowed keys"],
            "ml.kmeans-step": ["distance ties choose the lower centroid index"],
            "ml.beam-search": ["breaking equal scores", "lexicographically smaller token sequence"]
        ]

        for (problemID, fragments) in requiredContractFragments {
            let problem = try XCTUnwrap(Curriculum.problem(withID: problemID), problemID)
            let contract = ([problem.prompt] + problem.constraints).joined(separator: " ").lowercased()
            for fragment in fragments {
                XCTAssertTrue(
                    contract.contains(fragment.lowercased()),
                    "\(problemID) is missing contract rule: \(fragment)"
                )
            }
        }

        XCTAssertFalse(
            Curriculum.allProblems.contains { $0.prompt.localizedCaseInsensitiveContains("any valid peak") },
            "Exact-output tests must not rely on an unspecified 'any valid' answer"
        )
    }

    func testSortedTargetPairExplainsAndTestsItsTieBreak() throws {
        let problem = try XCTUnwrap(Curriculum.problem(withID: "pointers.sorted-pair"))

        XCTAssertTrue(problem.prompt.localizedCaseInsensitiveContains("greatest index distance"))
        let exampleExplanation = try XCTUnwrap(problem.examples.first?.explanation)
        XCTAssertTrue(exampleExplanation.contains("[0, 4]"))
        XCTAssertTrue(exampleExplanation.contains("[1, 3]"))
        XCTAssertTrue(exampleExplanation.localizedCaseInsensitiveContains("distance"))

        let duplicateEndpointTest = problem.tests.first {
            $0.argumentsJSON == "[[1,1,9,9],10]"
        }
        XCTAssertEqual(duplicateEndpointTest?.expectedJSON, "[0,3]")
    }

    func testPairProblemsCoverDistinctIndexFailureModesExplicitly() throws {
        let targetPair = try XCTUnwrap(Curriculum.problem(withID: "arrays.pair-indices"))
        let sortedPair = try XCTUnwrap(Curriculum.problem(withID: "pointers.sorted-pair"))

        XCTAssertGreaterThanOrEqual(targetPair.tests.count, 9)
        XCTAssertTrue(targetPair.prompt.localizedCaseInsensitiveContains("different positions"))
        XCTAssertTrue(targetPair.prompt.localizedCaseInsensitiveContains("may not be paired with itself"))
        XCTAssertTrue(targetPair.tests.contains {
            $0.name == "same-index match is forbidden before a real pair"
                && $0.argumentsJSON == "[[5,1,9],10]"
                && $0.expectedJSON == "[1,2]"
        })
        XCTAssertTrue(targetPair.tests.contains {
            $0.name == "earliest duplicate index is preserved"
                && $0.expectedJSON == "[0,2]"
        })

        XCTAssertGreaterThanOrEqual(sortedPair.tests.count, 9)
        XCTAssertTrue(sortedPair.tests.contains {
            $0.name == "pointers must not meet at one half-target"
                && $0.argumentsJSON == "[[1,5,8],10]"
                && $0.expectedJSON == "[-1,-1]"
        })
        XCTAssertTrue(sortedPair.tests.contains {
            $0.name == "two half-target positions form a pair"
                && $0.expectedJSON == "[0,1]"
        })
    }

    func testWaterContainerDefinesItsGeometryAndReturnValue() throws {
        let problem = try XCTUnwrap(Curriculum.problem(withID: "pointers.water-container"))
        let contract = ([problem.prompt] + problem.constraints).joined(separator: " ")

        XCTAssertEqual(problem.title, "Maximum-Area Water Container")
        XCTAssertTrue(contract.contains("right - left"))
        XCTAssertTrue(contract.contains("min(heights[left], heights[right])"))
        XCTAssertTrue(contract.localizedCaseInsensitiveContains("lines between"))
        XCTAssertTrue(contract.localizedCaseInsensitiveContains("not the chosen indices"))

        let explanation = try XCTUnwrap(problem.examples.first?.explanation)
        XCTAssertTrue(explanation.contains("7 - 1 = 6"))
        XCTAssertTrue(explanation.contains("6 * 6 = 36"))
        XCTAssertTrue(explanation.localizedCaseInsensitiveContains("farther apart"))

        XCTAssertTrue(problem.readingNotes.contains { $0.id == "container-area" })
        XCTAssertTrue(problem.readingNotes.contains { $0.id == "interior-lines-ignored" })
    }

    func testCurriculumContainsEveryDifficulty() {
        for difficulty in ProblemDifficulty.allCases {
            XCTAssertTrue(Curriculum.allProblems.contains { $0.difficulty == difficulty })
        }
    }

    func testEveryModuleHasRecognitionCues() {
        for module in Curriculum.allModules {
            XCTAssertGreaterThanOrEqual(module.problems.count, 3, module.id)
            XCTAssertGreaterThanOrEqual(module.recognitionCues.count, 3, module.id)
        }
    }

    func testEveryModuleHasACompletePatternMiniLesson() {
        XCTAssertEqual(Set(Curriculum.allModules.map(\.id)), LearningGuidance.lessonModuleIDs)

        for module in Curriculum.allModules {
            let lesson = module.lesson
            XCTAssertFalse(lesson.mentalModel.isEmpty, module.id)
            XCTAssertGreaterThanOrEqual(lesson.recognitionQuestions.count, 3, module.id)
            XCTAssertGreaterThanOrEqual(lesson.strategySteps.count, 3, module.id)
            XCTAssertGreaterThanOrEqual(lesson.commonPitfalls.count, 3, module.id)
            XCTAssertFalse(lesson.complexityTarget.isEmpty, module.id)
        }
    }

    func testEveryModuleHasAnExplicitBeginnerCourse() {
        XCTAssertEqual(Set(Curriculum.allModules.map(\.id)), ModuleTeachingCatalog.courseModuleIDs)

        for module in Curriculum.allModules {
            let course = module.course
            XCTAssertFalse(course.prerequisites.isEmpty, module.id)
            XCTAssertTrue(course.prerequisites.allSatisfy { !$0.isEmpty }, module.id)
            XCTAssertFalse(course.techniques.isEmpty, module.id)
            XCTAssertEqual(Set(course.techniques.map(\.id)).count, course.techniques.count, module.id)

            for technique in course.techniques {
                XCTAssertFalse(technique.name.isEmpty, "\(module.id).\(technique.id)")
                XCTAssertFalse(technique.plainLanguageMeaning.isEmpty, technique.id)
                XCTAssertFalse(technique.mathematicalView.isEmpty, technique.id)
                XCTAssertGreaterThanOrEqual(technique.useWhen.count, 3, technique.id)
                XCTAssertFalse(technique.doNotUseWhen.isEmpty, technique.id)
                XCTAssertFalse(technique.invariant.isEmpty, technique.id)
                XCTAssertTrue(technique.pythonTemplate.contains("def "), technique.id)
                XCTAssertFalse(technique.drillPrompt.isEmpty, technique.id)
                XCTAssertFalse(technique.drillHint.isEmpty, technique.id)
                XCTAssertFalse(technique.drillAnswer.isEmpty, technique.id)
            }
        }
    }

    func testEveryModuleFadesGuidanceIntoPracticeAndBlindChecks() {
        for module in Curriculum.allModules {
            let placements = module.problems.map { module.learningPlacement(for: $0.id) }

            XCTAssertEqual(placements.first?.mode, .guided, module.id)
            XCTAssertTrue(placements.contains { $0.mode == .application }, module.id)
            XCTAssertEqual(placements.last?.mode, .blindAssessment, module.id)

            for (index, placement) in placements.enumerated() {
                if placement.mode == .blindAssessment {
                    XCTAssertTrue(placement.requiredTechniqueNames.isEmpty, module.problems[index].id)
                } else {
                    let expectedNames = ProblemPrerequisiteCatalog.techniqueIDs(for: module.problems[index].id)
                        .compactMap { ModuleTeachingCatalog.technique(for: $0)?.name }
                    XCTAssertEqual(
                        Set(placement.requiredTechniqueNames),
                        Set(expectedNames),
                        module.problems[index].id
                    )
                }

                for prerequisiteID in placement.recommendedProblemIDs {
                    guard let prerequisiteIndex = module.problems.firstIndex(where: { $0.id == prerequisiteID }) else {
                        return XCTFail("Unknown prerequisite \(prerequisiteID) for \(module.problems[index].id)")
                    }
                    XCTAssertLessThan(prerequisiteIndex, index, module.problems[index].id)
                }
            }
        }
    }

    func testPrerequisiteCatalogCoversEveryProblemExactly() {
        let curriculumIDs = Set(Curriculum.allProblems.map(\.id))
        XCTAssertEqual(ProblemPrerequisiteCatalog.coveredProblemIDs, curriculumIDs)

        for problem in Curriculum.allProblems {
            let techniqueIDs = ProblemPrerequisiteCatalog.techniqueIDs(for: problem.id)
            XCTAssertFalse(techniqueIDs.isEmpty, "No prerequisite technique mapped for \(problem.id)")
            XCTAssertEqual(
                Set(techniqueIDs).count,
                techniqueIDs.count,
                "Duplicate prerequisite technique for \(problem.id)"
            )
        }
    }

    func testEveryMappedPrerequisiteHasACompleteLesson() {
        XCTAssertTrue(
            ProblemPrerequisiteCatalog.referencedTechniqueIDs.isSubset(of: ModuleTeachingCatalog.allTechniqueIDs),
            "Mapped techniques without lessons: \(ProblemPrerequisiteCatalog.referencedTechniqueIDs.subtracting(ModuleTeachingCatalog.allTechniqueIDs).sorted())"
        )

        let techniques = ModuleTeachingCatalog.allTechniques
        XCTAssertEqual(Set(techniques.map(\.id)).count, techniques.count, "Technique IDs must be globally unique")

        for techniqueID in ProblemPrerequisiteCatalog.referencedTechniqueIDs {
            guard let technique = ModuleTeachingCatalog.technique(for: techniqueID) else {
                return XCTFail("Missing lesson for \(techniqueID)")
            }
            XCTAssertFalse(technique.name.isEmpty, techniqueID)
            XCTAssertFalse(technique.plainLanguageMeaning.isEmpty, techniqueID)
            XCTAssertFalse(technique.mathematicalView.isEmpty, techniqueID)
            XCTAssertGreaterThanOrEqual(technique.useWhen.count, 3, techniqueID)
            XCTAssertFalse(technique.doNotUseWhen.isEmpty, techniqueID)
            XCTAssertFalse(technique.invariant.isEmpty, techniqueID)
            XCTAssertTrue(technique.pythonTemplate.contains("def "), techniqueID)
            XCTAssertFalse(technique.drillPrompt.isEmpty, techniqueID)
            XCTAssertFalse(technique.drillHint.isEmpty, techniqueID)
            XCTAssertFalse(technique.drillAnswer.isEmpty, techniqueID)
        }
    }

    func testTechniqueDependencyGraphIsCompleteAcyclicAndTopologicallyOrdered() throws {
        let knownTechniqueIDs = ModuleTeachingCatalog.allTechniqueIDs
        XCTAssertTrue(
            TechniqueDependencyCatalog.dependentTechniqueIDs.isSubset(of: knownTechniqueIDs),
            "Unknown dependent techniques: \(TechniqueDependencyCatalog.dependentTechniqueIDs.subtracting(knownTechniqueIDs).sorted())"
        )
        XCTAssertTrue(
            TechniqueDependencyCatalog.referencedTechniqueIDs.isSubset(of: knownTechniqueIDs),
            "Unknown prerequisite techniques: \(TechniqueDependencyCatalog.referencedTechniqueIDs.subtracting(knownTechniqueIDs).sorted())"
        )

        var visiting: Set<String> = []
        var completed: Set<String> = []
        func visit(_ techniqueID: String, path: [String]) {
            guard !completed.contains(techniqueID) else { return }
            if visiting.contains(techniqueID) {
                XCTFail("Technique dependency cycle: \((path + [techniqueID]).joined(separator: " -> "))")
                return
            }
            visiting.insert(techniqueID)
            for prerequisiteID in TechniqueDependencyCatalog.directPrerequisiteIDs(for: techniqueID) {
                visit(prerequisiteID, path: path + [techniqueID])
            }
            visiting.remove(techniqueID)
            completed.insert(techniqueID)
        }

        for techniqueID in knownTechniqueIDs {
            visit(techniqueID, path: [])

            let expanded = TechniqueDependencyCatalog.expandedTechniqueIDs(from: [techniqueID])
            XCTAssertEqual(Set(expanded).count, expanded.count, techniqueID)
            XCTAssertEqual(expanded.last, techniqueID, techniqueID)
            for prerequisiteID in TechniqueDependencyCatalog.directPrerequisiteIDs(for: techniqueID) {
                let prerequisiteIndex = try XCTUnwrap(expanded.firstIndex(of: prerequisiteID))
                let techniqueIndex = try XCTUnwrap(expanded.firstIndex(of: techniqueID))
                XCTAssertLessThan(prerequisiteIndex, techniqueIndex, "\(prerequisiteID) must precede \(techniqueID)")
            }
        }
    }

    func testEveryProblemIncludesTheTransitiveFoundationsOfItsAlgorithms() {
        for problem in Curriculum.allProblems {
            let direct = ProblemPrerequisiteCatalog.directTechniqueIDs(for: problem.id)
            let expanded = ProblemPrerequisiteCatalog.techniqueIDs(for: problem.id)
            XCTAssertEqual(
                expanded,
                TechniqueDependencyCatalog.expandedTechniqueIDs(from: direct),
                problem.id
            )
            XCTAssertTrue(Set(direct).isSubset(of: Set(expanded)), problem.id)
            XCTAssertEqual(Set(expanded).count, expanded.count, problem.id)

            for techniqueID in expanded {
                let dependencies = TechniqueDependencyCatalog.expandedTechniqueIDs(from: [techniqueID])
                XCTAssertTrue(Set(dependencies).isSubset(of: Set(expanded)), "\(problem.id) omits a foundation of \(techniqueID)")
            }
        }
    }

    func testSemanticallyAuditedProblemMappingsMatchTheirImplementedStrategies() {
        let expectedDirectMappings: [String: [String]] = [
            "intervals.covered-queries": ["sort-merge", "sorted-query-sweep"],
            "intervals.minimum-groups": ["sweep-events"],
            "mastery.trees.leaf-count": ["heap-array-tree"],
            "mastery.trees.right-view": ["heap-level-scan"],
            "dp.fewest-coins": ["unbounded-amount-dp"],
            "greedy.task-scheduler": ["cooldown-frame-counting"],
            "ml.scaled-attention": ["attention", "attention-masking"]
        ]

        for (problemID, expectedTechniqueIDs) in expectedDirectMappings {
            XCTAssertEqual(
                ProblemPrerequisiteCatalog.directTechniqueIDs(for: problemID),
                expectedTechniqueIDs,
                problemID
            )
        }
    }

    func testEveryPrerequisiteIsTaughtBeforeItsProblem() throws {
        let moduleOrder = Dictionary(uniqueKeysWithValues: Curriculum.allModules.enumerated().map { ($0.element.id, $0.offset) })

        for module in Curriculum.allModules {
            let problemModuleIndex = try XCTUnwrap(moduleOrder[module.id])
            for problem in module.problems {
                for techniqueID in ProblemPrerequisiteCatalog.techniqueIDs(for: problem.id) {
                    let teachingModuleID = try XCTUnwrap(
                        ModuleTeachingCatalog.moduleID(containingTechniqueID: techniqueID),
                        "No teaching module owns \(techniqueID)"
                    )
                    let teachingModuleIndex = try XCTUnwrap(moduleOrder[teachingModuleID])
                    XCTAssertLessThanOrEqual(
                        teachingModuleIndex,
                        problemModuleIndex,
                        "\(problem.id) requires future technique \(techniqueID) from \(teachingModuleID)"
                    )

                    let teachingModule = try XCTUnwrap(Curriculum.allModules.first { $0.id == teachingModuleID })
                    XCTAssertTrue(
                        teachingModule.course.techniques.contains { $0.id == techniqueID },
                        "\(techniqueID) is not visible in its owning module course"
                    )
                }
            }
        }
    }

    func testSameModuleTechniqueFoundationsAppearBeforeDependentLessons() throws {
        for module in Curriculum.allModules {
            let techniqueIDs = module.course.techniques.map(\.id)
            for techniqueID in techniqueIDs {
                let techniqueIndex = try XCTUnwrap(techniqueIDs.firstIndex(of: techniqueID))
                for prerequisiteID in TechniqueDependencyCatalog.directPrerequisiteIDs(for: techniqueID) {
                    guard let prerequisiteIndex = techniqueIDs.firstIndex(of: prerequisiteID) else {
                        continue // The prerequisite is taught in an earlier module.
                    }
                    XCTAssertLessThan(
                        prerequisiteIndex,
                        techniqueIndex,
                        "\(module.id) displays \(techniqueID) before its foundation \(prerequisiteID)"
                    )
                }
            }
        }
    }

    func testVisibleProblemPrerequisitesMatchTheCoverageMap() {
        for module in Curriculum.allModules {
            for problem in module.problems {
                let placement = module.learningPlacement(for: problem.id)
                let expected = ProblemPrerequisiteCatalog.techniqueIDs(for: problem.id)
                    .compactMap { ModuleTeachingCatalog.technique(for: $0)?.name }

                if placement.mode == .blindAssessment {
                    XCTAssertTrue(placement.requiredTechniqueNames.isEmpty, problem.id)
                } else {
                    XCTAssertEqual(placement.requiredTechniqueNames, expected, problem.id)
                }
            }
        }
    }

    func testBlindPracticeWaitsForPrerequisitesAndNeverNeedsAModuleLabel() throws {
        let module = try XCTUnwrap(Curriculum.modules.first)
        let blindProblem = try XCTUnwrap(module.problems.first {
            module.learningPlacement(for: $0.id).mode == .blindAssessment
        })
        let placement = module.learningPlacement(for: blindProblem.id)
        let accessible = Set(module.problems.map(\.id))

        XCTAssertTrue(Curriculum.readyBlindProblems(
            solvedIDs: [],
            accessibleIDs: accessible
        ).isEmpty)

        let ready = Curriculum.readyBlindProblems(
            solvedIDs: Set(placement.recommendedProblemIDs),
            accessibleIDs: accessible
        )
        XCTAssertEqual(ready.first?.id, blindProblem.id)
        XCTAssertTrue(module.learningPlacement(for: blindProblem.id).requiredTechniqueNames.isEmpty)
    }

    func testLearningGuideResearchSourcesAreCompleteAndSecure() {
        let sources = LearningGuidance.researchSources
        XCTAssertGreaterThanOrEqual(sources.count, 6)
        XCTAssertEqual(Set(sources.map(\.id)).count, sources.count)

        for source in sources {
            XCTAssertFalse(source.title.isEmpty, source.id)
            XCTAssertFalse(source.authorsAndYear.isEmpty, source.id)
            XCTAssertFalse(source.takeaway.isEmpty, source.id)
            XCTAssertEqual(source.url.scheme, "https", source.id)
        }
    }

    func testMLInterviewResearchSourcesAreCompleteAndSecure() {
        let sources = MLInterviewCurriculum.researchSources
        XCTAssertGreaterThanOrEqual(sources.count, 5)
        XCTAssertEqual(Set(sources.map(\.id)).count, sources.count)

        for source in sources {
            XCTAssertFalse(source.title.isEmpty, source.id)
            XCTAssertFalse(source.takeaway.isEmpty, source.id)
            XCTAssertEqual(source.url.scheme, "https", source.id)
        }
    }

    func testMLFrameworkComparisonsUseEinsumOnlyForAttention() throws {
        let fromScratchID = "ml.matrix-multiply"
        let expectedEinsumIDs: Set<String> = [
            "ml.scaled-attention",
            "ml.causal-self-attention",
            "ml.multi-head-causal-attention"
        ]

        XCTAssertEqual(
            MLProductionSolutionCatalog.coveredProblemIDs,
            Set(Curriculum.mlInterviewProblems.map(\.id)).subtracting([fromScratchID])
        )
        XCTAssertEqual(MLProductionSolutionCatalog.einsumProblemIDs, expectedEinsumIDs)

        for problem in Curriculum.mlInterviewProblems {
            if problem.id == fromScratchID {
                XCTAssertNil(problem.productionSolution)
                XCTAssertTrue(problem.prompt.localizedCaseInsensitiveContains("from first principles"))
                XCTAssertTrue(problem.prompt.localizedCaseInsensitiveContains("einsum"))
                XCTAssertFalse(problem.referenceSolution.localizedCaseInsensitiveContains("einsum"))
                XCTAssertFalse(problem.referenceSolution.localizedCaseInsensitiveContains("torch"))
                continue
            }

            guard let solution = problem.productionSolution else {
                return XCTFail("Missing production solution: \(problem.id)")
            }
            XCTAssertFalse(solution.code.localizedCaseInsensitiveContains("einsum"), problem.id)
            XCTAssertFalse(solution.code.contains("from einops import"), problem.id)
            XCTAssertTrue(solution.code.contains("def \(problem.functionName)("), problem.id)
            XCTAssertTrue(solution.requirements.contains("PyTorch"), problem.id)
            XCTAssertEqual(solution.documentationURL.scheme, "https", problem.id)
            XCTAssertFalse(problem.referenceSolution.contains("einops"), "Offline oracle must remain executable: \(problem.id)")

            if expectedEinsumIDs.contains(problem.id) {
                let alternative = try XCTUnwrap(solution.einsumAlternative, problem.id)
                XCTAssertTrue(alternative.code.contains("from einops import einsum"), problem.id)
                XCTAssertTrue(alternative.code.contains("def \(problem.functionName)("), problem.id)
                XCTAssertEqual(alternative.documentationURL.scheme, "https", problem.id)
            } else {
                XCTAssertNil(solution.einsumAlternative, problem.id)
            }
        }
    }
}
