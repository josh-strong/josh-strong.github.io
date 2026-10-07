import Foundation
import SwiftData
import SwiftUI

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

struct ProblemWorkspaceFlowView: View {
    @State private var currentProblem: AlgorithmProblem

    init(initialProblem: AlgorithmProblem) {
        _currentProblem = State(initialValue: initialProblem)
    }

    var body: some View {
        ProblemWorkspaceView(problem: currentProblem) { nextProblem in
            currentProblem = nextProblem
        }
        .id(currentProblem.id)
    }
}

struct ProblemWorkspaceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @Query private var progressRecords: [LearningProgressRecord]

    let problem: AlgorithmProblem
    let onAdvance: ((AlgorithmProblem) -> Void)?

    private var curriculumModule: CurriculumModule? {
        Curriculum.module(containing: problem.id)
    }

    private var learningPlacement: ProblemLearningPlacement? {
        curriculumModule?.learningPlacement(for: problem.id)
    }

    init(problem: AlgorithmProblem, onAdvance: ((AlgorithmProblem) -> Void)? = nil) {
        self.problem = problem
        self.onAdvance = onAdvance
    }

    @State private var progressRecord: LearningProgressRecord?
    @State private var loadedProblemID: String?
    @State private var draftCode = ""
    @State private var notes = ""
    @State private var scratchpadCode = PythonScratchpad.starterCode
    @State private var runReport: PythonRunReport?
    @State private var scratchpadReport: PythonScratchpadReport?
    @State private var scratchpadReportSource: String?
    @State private var isScratchpadExpanded = false
    @State private var isRunning = false
    @State private var isRunningScratchpad = false
    @State private var hasLoaded = false
    @State private var showingReferenceConfirmation = false
    @State private var showingResetConfirmation = false
    @State private var showingScratchpadResetConfirmation = false
    @State private var showingTimerResetConfirmation = false
    @State private var milestoneMessage: String?
    @State private var suggestedNextProblem: AlgorithmProblem?
    @State private var errorMessage: String?
    @State private var saveTask: Task<Void, Never>?
    @State private var referenceJump = 0
    @State private var timerStartedAt: Date?
    @State private var showingChatGPTHandoff = false
    @State private var handoffQuestion = ""
    @State private var isUpdatingReviewFlag = false
    @State private var reminderRefreshTask: Task<Void, Never>?

    private let runner = PythonRunner()
    private let progressService = LearningProgressService()
    private let completionService = CompletionService()
    private let notificationService = NotificationService()
    private let planEngine = LearningPlanEngine()
    private let calendar = Calendar.autoupdatingCurrent

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    problemHeader
                    learningStageCard
                    patternPrimerCard
                    problemStatement
                    editorCard
                    scratchpadCard
                    resultsCard
                    hintsCard
                    notesCard
                    referenceCard
                    solutionAlternativesCard
                }
                .frame(maxWidth: 900, alignment: .leading)
                .padding()
                .frame(maxWidth: .infinity)
            }
            .onChange(of: referenceJump) { _, _ in
                withAnimation { proxy.scrollTo("reference", anchor: .top) }
            }
        }
        .navigationTitle(problem.title)
        .learningBackground()
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if let module = Curriculum.module(containing: problem.id), onAdvance != nil {
                    let plan = planEngine.snapshot(records: progressRecords)
                    Menu("Module problems", systemImage: "list.number") {
                        ForEach(module.problems.filter { plan.accessibleIDs.contains($0.id) }) { candidate in
                            Button {
                                onAdvance?(candidate)
                            } label: {
                                Label(
                                    candidate.title,
                                    systemImage: moduleProblemSymbol(
                                        for: candidate,
                                        solvedIDs: plan.solvedIDs
                                    )
                                )
                            }
                            .disabled(candidate.id == problem.id)
                        }
                    }
                    .accessibilityHint("Switches to any available problem in this module")
                }
                Button("Reset", systemImage: "arrow.counterclockwise") {
                    showingResetConfirmation = true
                }
                .disabled(isRunning || !workspaceMatchesDisplayedProblem)
                Button("Reference", systemImage: "book.closed.fill") {
                    if progressRecord?.referenceViewed == true {
                        scrollReferenceIntoView()
                    } else {
                        showingReferenceConfirmation = true
                    }
                }
                .disabled(!workspaceMatchesDisplayedProblem)
            }
        }
        .task(id: problem.id) { loadProgress() }
        .onChange(of: draftCode) { _, _ in
            if workspaceMatchesDisplayedProblem { runReport = nil }
            scheduleSave()
        }
        .onChange(of: notes) { _, _ in scheduleSave() }
        .onChange(of: scratchpadCode) { _, _ in scheduleSave() }
        .onChange(of: progressRecord?.modifiedAt) { _, _ in
            adoptExternallyMergedProgress()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { pauseStudyTimer() }
        }
        .onDisappear {
            pauseStudyTimer()
            saveTask?.cancel()
            saveNow()
        }
        .sheet(isPresented: $showingChatGPTHandoff) {
            ChatGPTHandoffView(
                problem: problem,
                draftCode: draftCode,
                notes: notes,
                report: runReport,
                question: $handoffQuestion
            ) { prompt in
                performChatGPTHandoff(with: prompt)
            }
        }
        .confirmationDialog("Reveal the reference solution?", isPresented: $showingReferenceConfirmation) {
            Button("Reveal solution") { revealReference() }
            Button("Keep trying", role: .cancel) {}
        } message: {
            Text("Try to explain your current approach first. Comparing after an attempt builds stronger recall than passively reading.")
        }
        .confirmationDialog("Reset your draft?", isPresented: $showingResetConfirmation) {
            Button("Reset to starter code", role: .destructive) {
                draftCode = problem.starterCode
                runReport = nil
                saveNow()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your notes and attempt history will be kept.")
        }
        .confirmationDialog("Reset the scratchpad cell?", isPresented: $showingScratchpadResetConfirmation) {
            Button("Reset scratchpad", role: .destructive) {
                scratchpadCode = PythonScratchpad.starterCode
                scratchpadReport = nil
                scratchpadReportSource = nil
                saveNow()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This only clears your experimental cell. Your solution, notes, and attempt history will be kept.")
        }
        .confirmationDialog("Reset time for this problem?", isPresented: $showingTimerResetConfirmation) {
            Button("Reset tracked time", role: .destructive) { resetStudyTimer() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears the cumulative timer for this problem. Your code, notes, and attempts will not change.")
        }
        .alert("Nice work", isPresented: milestoneIsPresented) {
            if let suggestedNextProblem, onAdvance != nil {
                Button("Suggested problem") {
                    milestoneMessage = nil
                    self.suggestedNextProblem = nil
                    onAdvance?(suggestedNextProblem)
                }
                Button("Stay here", role: .cancel) {
                    milestoneMessage = nil
                    self.suggestedNextProblem = nil
                }
            } else {
                Button("Continue", role: .cancel) {
                    milestoneMessage = nil
                    suggestedNextProblem = nil
                }
            }
        } message: {
            Text(milestoneMessage ?? "All tests passed.")
        }
        .alert("Something went wrong", isPresented: errorIsPresented) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private var problemHeader: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        if let module = curriculumModule {
                            let placement = module.learningPlacement(for: problem.id)
                            Label(
                                placement.mode == .blindAssessment ? "Blind module check" : module.title,
                                systemImage: placement.mode == .blindAssessment ? placement.mode.symbol : module.symbol
                            )
                                .appFont(.caption, weight: .bold)
                                .foregroundStyle(placement.mode == .blindAssessment ? .purple : AppTheme.accent)
                        }
                        Text(problem.title).appFont(.title, weight: .bold)
                    }
                    Spacer()
                    DifficultyBadge(difficulty: problem.difficulty)
                }

                Text(problem.whyItMatters)
                    .appFont(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 14) {
                    Label("\(problem.estimatedMinutes) min", systemImage: "clock")
                    if let record = progressRecord {
                        Label("\(record.attemptCount) attempt\(record.attemptCount == 1 ? "" : "s")", systemImage: "arrow.triangle.2.circlepath")
                        if record.isSolved { Label("Solved", systemImage: "checkmark.seal.fill").foregroundStyle(.green) }
                    }
                }
                .appFont(.caption)
                .foregroundStyle(.secondary)

                studyTimer
                reviewFlagPanel
            }
        }
    }

    @ViewBuilder
    private var reviewFlagPanel: some View {
        if let record = progressRecord {
            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 10) {
                    Image(systemName: record.isFlaggedForReview ? "flag.fill" : "flag")
                        .foregroundStyle(record.isFlaggedForReview ? .orange : AppTheme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.isFlaggedForReview ? "Flagged for a focused revisit" : "Worth revisiting?")
                            .appFont(.subheadline, weight: .bold)
                        if let reviewAt = record.flaggedReviewAt, record.isFlaggedForReview {
                            Text(reviewAt <= Date() ? "Due now" : "Reminder \(reviewAt.formatted(date: .abbreviated, time: .shortened))")
                                .appFont(.caption)
                                .foregroundStyle(reviewAt <= Date() ? .orange : .secondary)
                        } else {
                            Text("Flag difficult ideas or anything you want to remember.")
                                .appFont(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    if isUpdatingReviewFlag {
                        ProgressView().controlSize(.small)
                    } else if record.isFlaggedForReview {
                        Menu {
                            Button("Reviewed — remind me later", systemImage: "checkmark.circle") {
                                Task { await completeFlaggedReview() }
                            }
                            Button("Remove flag", systemImage: "flag.slash", role: .destructive) {
                                Task { await clearReviewFlag() }
                            }
                        } label: {
                            Label("Flag options", systemImage: "ellipsis.circle")
                        }
                    } else {
                        Button {
                            Task { await flagForReview() }
                        } label: {
                            Label("Flag", systemImage: "flag.fill")
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                    }
                }

                if record.isFlaggedForReview {
                    let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
                    Text(trimmedNotes.isEmpty
                         ? "Add what confused you in Learning notes below; it will appear with the reminder."
                         : "Reminder note: \(trimmedNotes)")
                        .appFont(.caption)
                        .foregroundStyle(trimmedNotes.isEmpty ? Color.secondary : Color.primary)
                        .lineLimit(3)
                }
            }
            .padding(10)
            .background(Color.orange.opacity(0.07), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.orange.opacity(record.isFlaggedForReview ? 0.28 : 0.12))
            }
        }
    }

    private var studyTimer: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let seconds = displayedStudySeconds(at: context.date)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 9) {
                    Image(systemName: timerStartedAt == nil ? "timer" : "timer.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Time on this problem")
                            .appFont(.caption2, weight: .bold)
                            .foregroundStyle(.secondary)
                        Text(formattedStudyTime(seconds))
                            .appFont(.title3, weight: .bold, design: .monospaced)
                            .contentTransition(.numericText())
                    }
                    Spacer()
                    Button {
                        if timerStartedAt == nil {
                            startStudyTimer()
                        } else {
                            pauseStudyTimer(at: context.date)
                        }
                    } label: {
                        Label(
                            timerStartedAt == nil ? "Start" : "Pause",
                            systemImage: timerStartedAt == nil ? "play.fill" : "pause.fill"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(!workspaceMatchesDisplayedProblem)

                    Button {
                        showingTimerResetConfirmation = true
                    } label: {
                        Label("Reset timer", systemImage: "arrow.counterclockwise")
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(timerStartedAt != nil || seconds == 0)
                    .accessibilityHint("Clears the cumulative time for this problem")
                }

                Text(timerStartedAt == nil
                     ? "Paused · \(focusGuidance(after: seconds / 60))"
                     : "Tracking now · \(focusGuidance(after: seconds / 60))")
                    .appFont(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .learningInset(cornerRadius: 10)
        }
    }

    @ViewBuilder
    private var learningStageCard: some View {
        if let placement = learningPlacement {
            LearningCard {
                VStack(alignment: .leading, spacing: 13) {
                    HStack(alignment: .top, spacing: 11) {
                        Image(systemName: placement.mode.symbol)
                            .appFont(.headline)
                            .foregroundStyle(placement.mode == .blindAssessment ? .purple : AppTheme.accent)
                            .frame(width: 26)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(placement.mode.title).appFont(.headline)
                            Text(placement.mode.explanation)
                                .appFont(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if placement.mode == .blindAssessment {
                        Label(
                            "Technique names and the pattern primer are hidden. Opening a hint or the reference turns this into a supported attempt—and that is still useful learning.",
                            systemImage: "eye.slash"
                        )
                        .appFont(.footnote, weight: .medium)
                        .foregroundStyle(.purple)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Knowledge required")
                                .appFont(.caption, weight: .bold)
                                .foregroundStyle(AppTheme.accent)
                            ForEach(ProblemPrerequisiteCatalog.techniqueIDs(for: problem.id), id: \.self) { techniqueID in
                                if let technique = ModuleTeachingCatalog.technique(for: techniqueID),
                                   let teachingModuleID = ModuleTeachingCatalog.moduleID(containingTechniqueID: techniqueID),
                                   let teachingModule = Curriculum.allModules.first(where: { $0.id == teachingModuleID }) {
                                    let isTargetAlgorithm = ProblemPrerequisiteCatalog
                                        .directTechniqueIDs(for: problem.id)
                                        .contains(techniqueID)
                                    NavigationLink {
                                        PatternLessonView(
                                            module: teachingModule,
                                            focusedTechniqueIDs: [techniqueID]
                                        )
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle")
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(technique.name)
                                                Text(isTargetAlgorithm ? "TARGET ALGORITHM" : "FOUNDATION")
                                                    .appFont(.caption2, weight: .bold)
                                                    .foregroundStyle(isTargetAlgorithm ? AppTheme.accent : Color.secondary)
                                            }
                                            Spacer()
                                            Text(teachingModule.title)
                                                .appFont(.caption2)
                                                .foregroundStyle(.tertiary)
                                            Image(systemName: "chevron.right")
                                                .appFont(.caption2, weight: .bold)
                                        }
                                        .appFont(.footnote)
                                        .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    if !placement.recommendedProblemIDs.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recommended earlier problems")
                                .appFont(.caption, weight: .bold)
                                .foregroundStyle(.secondary)
                            ForEach(Array(placement.recommendedProblemIDs.suffix(3)), id: \.self) { prerequisiteID in
                                if let prerequisite = Curriculum.problem(withID: prerequisiteID) {
                                    let solved = progressRecords.contains {
                                        $0.problemID == prerequisiteID && $0.isSolved
                                    }
                                    Label(
                                        prerequisite.title,
                                        systemImage: solved ? "checkmark.circle.fill" : "circle"
                                    )
                                    .appFont(.footnote)
                                    .foregroundStyle(solved ? .green : .secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var patternPrimerCard: some View {
        if let module = curriculumModule, let placement = learningPlacement {
            LearningCard {
                VStack(alignment: .leading, spacing: 13) {
                    if placement.mode == .blindAssessment {
                        Label("Choose the pattern", systemImage: "questionmark.diamond.fill")
                            .appFont(.headline)
                            .foregroundStyle(.purple)
                        Text("Start from the contract and constraints. Write a direct approach, locate its repeated work, and ask which previously learned state could remove it. The module name is intentionally withheld here.")
                            .appFont(.subheadline)

                        VStack(alignment: .leading, spacing: 7) {
                            Text("Before coding, write:")
                                .appFont(.caption, weight: .bold)
                                .foregroundStyle(.purple)
                            Label("The slow method and its complexity", systemImage: "1.circle")
                            Label("The repeated work", systemImage: "2.circle")
                            Label("A candidate state and invariant", systemImage: "3.circle")
                        }
                        .appFont(.footnote)
                        .foregroundStyle(.secondary)
                    } else {
                        HStack(alignment: .top, spacing: 11) {
                            Image(systemName: "scope")
                                .appFont(.headline)
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 26)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pattern lens · \(module.title)")
                                    .appFont(.headline)
                                Text("Use this to form a hypothesis—not as permission to skip the proof.")
                                    .appFont(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Text(module.lesson.mentalModel)
                            .appFont(.subheadline)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Before you code, ask:")
                                .appFont(.caption, weight: .bold)
                                .foregroundStyle(AppTheme.accent)
                            ForEach(Array(module.lesson.recognitionQuestions.prefix(2)), id: \.self) { question in
                                Label(question, systemImage: "questionmark.circle")
                                    .appFont(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Label(module.lesson.complexityTarget, systemImage: "gauge.with.dots.needle.50percent")
                            .appFont(.footnote, weight: .medium)
                            .foregroundStyle(.secondary)

                        NavigationLink {
                            PatternLessonView(module: module)
                        } label: {
                            Label("Open the full \(module.title) course", systemImage: "book.pages.fill")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }

    private var problemStatement: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("Problem", systemImage: "doc.text.fill").appFont(.headline)
                Text(problem.prompt).appFont(.body)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Read this precisely", systemImage: "text.magnifyingglass")
                        .appFont(.subheadline, weight: .bold)
                        .foregroundStyle(AppTheme.accent)

                    ForEach(problem.readingNotes) { note in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(note.term)
                                .appFont(.footnote, weight: .bold)
                            Text(note.explanation)
                                .appFont(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.accent.opacity(0.065), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(AppTheme.accent.opacity(0.14))
                }

                if !problem.examples.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Examples").appFont(.subheadline, weight: .bold)
                        ForEach(Array(problem.examples.enumerated()), id: \.offset) { index, example in
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Example \(index + 1)").appFont(.caption, weight: .bold).foregroundStyle(.secondary)
                                if problem.tests.indices.contains(index) {
                                    namedArguments(for: problem.tests[index])
                                } else {
                                    Text("Arguments: \(example.input)").appFont(.footnote, design: .monospaced)
                                }
                                Text("Expected return: \(example.output)")
                                    .appFont(.footnote, weight: .medium, design: .monospaced)
                                if let explanation = example.explanation {
                                    Text(explanation).appFont(.footnote).foregroundStyle(.secondary)
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .learningInset()
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Constraints").appFont(.subheadline, weight: .bold)
                    ForEach(problem.constraints, id: \.self) { constraint in
                        Label(constraint, systemImage: "circle.fill")
                            .appFont(.footnote)
                            .foregroundStyle(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Function contract").appFont(.subheadline, weight: .bold)
                    Text(functionSignature)
                        .appFont(.footnote, weight: .medium, design: .monospaced)
                        .foregroundStyle(AppTheme.codeForeground)
                        .textSelection(.enabled)
                        .padding(11)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.codeBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text("The runner calls this function with the named arguments shown above. Return the requested Python value—do not read input or print the answer. Expand the checks below to inspect every graded case before coding.")
                        .appFont(.footnote)
                        .foregroundStyle(.secondary)
                }

                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 7) {
                        ForEach(Array(problem.validationTests.enumerated()), id: \.offset) { index, test in
                            VStack(alignment: .leading, spacing: 7) {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("\(index + 1)")
                                        .appFont(.caption2, weight: .bold)
                                        .foregroundStyle(AppTheme.accent)
                                        .frame(width: 22, height: 22)
                                        .background(AppTheme.accent.opacity(0.1), in: Circle())
                                    Text(test.name)
                                        .appFont(.footnote, weight: .medium)
                                    Spacer()
                                }
                                namedArguments(for: test)
                                    .padding(.leading, 30)
                                Text(
                                    test.derivesExpectedFromReference
                                        ? "Expected return: verified against the bundled reference when run"
                                        : "Expected return: \(test.expectedJSON)"
                                )
                                    .appFont(.caption, weight: .medium, design: .monospaced)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 30)
                            }
                            .padding(.vertical, 3)
                        }
                    }
                    .padding(.top, 9)
                } label: {
                    Label("What the \(problem.validationTests.count) built-in checks cover", systemImage: "checklist")
                        .appFont(.subheadline, weight: .bold)
                }
                .tint(.primary)
            }
        }
    }

    private var functionSignature: String {
        problem.starterCode
            .split(separator: "\n", omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? "def \(problem.functionName)(...):"
    }

    @ViewBuilder
    private func namedArguments(for test: AlgorithmTestCase) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(problem.displayedArguments(for: test)) { argument in
                Text("\(argument.name) = \(argument.value)")
                    .appFont(.caption, design: .monospaced)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var editorCard: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Your Python solution", systemImage: "chevron.left.forwardslash.chevron.right")
                        .appFont(.headline)
                    Spacer()
                    Label("Python 3 · live syntax", systemImage: "paintbrush.pointed.fill")
                        .appFont(.caption, weight: .medium)
                        .foregroundStyle(AppTheme.accent)
                }

                PythonCodeEditor(text: $draftCode)
                    .frame(minHeight: 300)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.white.opacity(0.08))
                    }
                    .accessibilityLabel("Python solution editor")

                HStack {
                    Text("Define `\(problem.functionName)` and return the requested value.")
                        .appFont(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        Task { await runTests() }
                    } label: {
                        if isRunning {
                            ProgressView().controlSize(.small)
                        } else {
                            Label("Run \(problem.validationTests.count) tests", systemImage: "play.fill")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(isRunning || isRunningScratchpad || !workspaceMatchesDisplayedProblem)
                    .keyboardShortcut("r", modifiers: [.command])
                }

                Divider()

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: 12) {
                        chatGPTHandoffDescription
                        Spacer(minLength: 8)
                        chatGPTHandoffButton
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        chatGPTHandoffDescription
                        chatGPTHandoffButton
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private var scratchpadCard: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    Label("Python scratchpad", systemImage: "rectangle.and.pencil.and.ellipsis")
                        .appFont(.headline)
                    Spacer()
                    scratchpadExpansionButton
                }

                Text("Experiment with values, loops, helper functions, or pieces of your idea. Use `print(...)` to inspect results. Running this cell never runs the built-in tests or records an attempt.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)

                PythonCodeEditor(text: $scratchpadCode)
                    .frame(height: scratchpadEditorHeight)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(.white.opacity(0.08))
                    }
                    .accessibilityLabel("Python scratchpad editor")
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: isScratchpadExpanded)

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        scratchpadResetButton
                        Spacer()
                        scratchpadRunButton
                    }

                    VStack(spacing: 10) {
                        scratchpadRunButton
                            .frame(maxWidth: .infinity)
                        scratchpadResetButton
                            .frame(maxWidth: .infinity)
                    }
                }

                Divider()
                scratchpadOutput
            }
        }
    }

    private var scratchpadExpansionButton: some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.22)) {
                isScratchpadExpanded.toggle()
            }
        } label: {
            Label(
                isScratchpadExpanded ? "Collapse" : "Expand",
                systemImage: isScratchpadExpanded
                    ? "arrow.down.right.and.arrow.up.left"
                    : "arrow.up.left.and.arrow.down.right"
            )
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .accessibilityHint(
            isScratchpadExpanded
                ? "Makes the Python scratchpad editor shorter"
                : "Makes the Python scratchpad editor taller"
        )
    }

    private var scratchpadEditorHeight: CGFloat {
#if os(macOS)
        isScratchpadExpanded ? 560 : 220
#else
        isScratchpadExpanded ? 480 : 220
#endif
    }

    private var scratchpadResetButton: some View {
        Button {
            showingScratchpadResetConfirmation = true
        } label: {
            Label("Reset cell", systemImage: "arrow.counterclockwise")
        }
        .buttonStyle(.bordered)
        .disabled(isRunningScratchpad || !workspaceMatchesDisplayedProblem)
    }

    private var scratchpadRunButton: some View {
        Button {
            Task { await runScratchpad() }
        } label: {
            if isRunningScratchpad {
                HStack(spacing: 8) {
                    ProgressView().controlSize(.small)
                    Text("Running cell…")
                }
            } else {
                Label("Run cell", systemImage: "play.fill")
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(
            isRunning
                || isRunningScratchpad
                || scratchpadCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || !workspaceMatchesDisplayedProblem
        )
        .keyboardShortcut("r", modifiers: [.command, .shift])
    }

    @ViewBuilder
    private var scratchpadOutput: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Label("Cell output", systemImage: "terminal.fill")
                    .appFont(.subheadline, weight: .bold)
                Spacer()
                if let scratchpadReport {
                    Text("\(scratchpadReport.elapsedMilliseconds) ms")
                        .appFont(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let scratchpadReport {
                if scratchpadOutputIsStale {
                    Label(
                        "Code changed since this output. Run the cell again to refresh it.",
                        systemImage: "clock.arrow.circlepath"
                    )
                    .appFont(.caption, weight: .semibold)
                    .foregroundStyle(.orange)
                }

                if !scratchpadReport.output.isEmpty {
                    // The output panel has a permanently dark code background. An
                    // adaptive primary colour becomes black in light mode, making
                    // otherwise valid print output look blank.
                    scratchpadOutputText(scratchpadReport.output, color: AppTheme.codeForeground)
                }

                if let error = scratchpadReport.errorMessage {
                    Label("Python error", systemImage: "exclamationmark.triangle.fill")
                        .appFont(.caption, weight: .bold)
                        .foregroundStyle(.red)
                    scratchpadOutputText(error, color: .red)
                } else if scratchpadReport.output.isEmpty {
                    Text("The cell finished without printed output. Add `print(...)` to inspect a value.")
                        .appFont(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Run the cell to see printed values or Python errors here.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var scratchpadOutputIsStale: Bool {
        guard scratchpadReport != nil, let scratchpadReportSource else { return false }
        return scratchpadReportSource != scratchpadCode
    }

    private func scratchpadOutputText(_ text: String, color: Color) -> some View {
        ScrollView([.horizontal, .vertical]) {
            Text(text)
                .appFont(.footnote, design: .monospaced)
                .foregroundStyle(color)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(11)
        }
        .frame(maxHeight: 220)
        .background(AppTheme.codeBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var chatGPTHandoffDescription: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Talk through your approach")
                .appFont(.subheadline, weight: .bold)
            Text("Copies this problem, your draft, and test evidence. No API key or API billing.")
                .appFont(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var chatGPTHandoffButton: some View {
        Button {
            showingChatGPTHandoff = true
        } label: {
            Label("Discuss in ChatGPT", systemImage: "bubble.left.and.text.bubble.right.fill")
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(!workspaceMatchesDisplayedProblem)
    }

    @ViewBuilder
    private var resultsCard: some View {
        if let report = runReport {
            LearningCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(
                            report.allPassed ? "All tests passed" : "Test results",
                            systemImage: report.allPassed ? "checkmark.circle.fill" : "xmark.circle.fill"
                        )
                        .appFont(.headline)
                        .foregroundStyle(report.allPassed ? .green : .primary)
                        Spacer()
                        Text("\(report.passedCount)/\(report.results.count) · \(report.elapsedMilliseconds) ms")
                            .appFont(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let error = report.errorMessage {
                        Text(error)
                            .appFont(.footnote, design: .monospaced)
                            .foregroundStyle(.red)
                    }

                    if report.allPassed {
                        Label(
                            "Correctness checks passed. Now compare your approach with the target \(problem.timeComplexity) time and \(problem.spaceComplexity) space—tests alone cannot prove complexity.",
                            systemImage: "gauge.with.dots.needle.67percent"
                        )
                        .appFont(.footnote, weight: .medium)
                        .foregroundStyle(AppTheme.accent)
                    }

                    ForEach(report.results) { result in
                        TestResultRow(result: result)
                    }
                }
            }
        }
    }

    private var hintsCard: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Progressive hints", systemImage: "lightbulb.fill").appFont(.headline)
                    Spacer()
                    Text("\(min(progressRecord?.hintsRevealed ?? 0, problem.hints.count))/\(problem.hints.count)")
                        .appFont(.caption, weight: .bold)
                        .foregroundStyle(.secondary)
                }

                Text(learningPlacement?.mode == .blindAssessment
                     ? "A hint ends the blind portion of this attempt. That is not failure—record what cue you missed, then continue with one hint at a time."
                     : "Use one hint at a time. Pause and retrieve the next step yourself before revealing more.")
                    .appFont(.footnote)
                    .foregroundStyle(learningPlacement?.mode == .blindAssessment ? .purple : .secondary)

                let revealed = min(progressRecord?.hintsRevealed ?? 0, problem.hints.count)
                ForEach(0..<revealed, id: \.self) { index in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1)").appFont(.caption, weight: .bold).foregroundStyle(.orange)
                            .frame(width: 24, height: 24)
                            .background(Color.orange.opacity(0.13), in: Circle())
                        Text(problem.hints[index]).appFont(.subheadline)
                    }
                }

                if revealed < problem.hints.count {
                    Button {
                        revealNextHint()
                    } label: {
                        Label(revealed == 0 ? "Reveal first hint" : "Reveal another hint", systemImage: "lightbulb")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var notesCard: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 10) {
                Label("Learning notes", systemImage: "note.text").appFont(.headline)
                Text("Write the invariant, the mistake you made, and the cue that should trigger this pattern next time.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)
                TextEditor(text: $notes)
                    .appFont(.body)
                    .scrollContentBackground(.hidden)
                    .padding(9)
                    .frame(minHeight: 140)
                    .learningInset()
                    .overlay {
                        if notes.isEmpty {
                            Text("My approach…\nThe key invariant…\nNext time I will recognize…")
                                .appFont(.body)
                                .foregroundStyle(.tertiary)
                                .padding(15)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
    }

    private var referenceCard: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 13) {
                Label(
                    problem.productionSolution == nil ? "Reference solution" : "Reference & framework comparisons",
                    systemImage: "book.closed.fill"
                )
                .appFont(.headline)

                if progressRecord?.referenceViewed == true {
                    Text(problem.solutionExplanation)
                        .appFont(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        Label(problem.timeComplexity, systemImage: "timer")
                        Label(problem.spaceComplexity, systemImage: "memorychip")
                    }
                    .appFont(.caption, weight: .bold)
                    .foregroundStyle(AppTheme.accent)

                    if let production = problem.productionSolution {
                        VStack(alignment: .leading, spacing: 9) {
                            Label(production.title, systemImage: "bolt.horizontal.circle.fill")
                                .appFont(.subheadline, weight: .bold)
                                .foregroundStyle(AppTheme.accent)
                            Text(production.summary)
                                .appFont(.footnote)
                                .foregroundStyle(.secondary)
                            Label(production.requirements, systemImage: "shippingbox.fill")
                                .appFont(.caption, weight: .semibold)
                            Text(production.runtimeNote)
                                .appFont(.caption)
                                .foregroundStyle(.secondary)
                            Link(destination: production.documentationURL) {
                                Label(production.documentationLabel, systemImage: "arrow.up.right.square")
                            }
                            .appFont(.caption, weight: .semibold)
                        }
                        .padding(12)
                        .learningInset()

                        solutionCodeBlock(production.code)

                        if let einsum = production.einsumAlternative {
                            VStack(alignment: .leading, spacing: 9) {
                                Label(einsum.title, systemImage: "function")
                                    .appFont(.subheadline, weight: .bold)
                                    .foregroundStyle(AppTheme.accent)
                                Text(einsum.summary)
                                    .appFont(.footnote)
                                    .foregroundStyle(.secondary)
                                Label(einsum.requirements, systemImage: "shippingbox.fill")
                                    .appFont(.caption, weight: .semibold)
                                Link(destination: einsum.documentationURL) {
                                    Label("Open the official einops guide", systemImage: "arrow.up.right.square")
                                }
                                .appFont(.caption, weight: .semibold)
                            }
                            .padding(12)
                            .learningInset()

                            solutionCodeBlock(einsum.code)
                        }

                        DisclosureGroup("Offline executable oracle") {
                            VStack(alignment: .leading, spacing: 9) {
                                Text("CodeStreak uses this dependency-free version to calculate expected values locally on your Mac or iPhone. It follows the same equations as the framework comparisons above.")
                                    .appFont(.caption)
                                    .foregroundStyle(.secondary)
                                solutionCodeBlock(problem.annotatedReferenceSolution)
                            }
                            .padding(.top, 10)
                        }
                        .appFont(.subheadline, weight: .semibold)
                        .tint(AppTheme.accent)
                    } else {
                        solutionCodeBlock(problem.annotatedReferenceSolution)
                    }

                    Text("Compare this with your draft. In your notes, explain why the invariant makes the complexity possible.")
                        .appFont(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("The reference stays behind a deliberate reveal so you attempt retrieval before recognition.")
                        .appFont(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Reveal reference solution") { showingReferenceConfirmation = true }
                        .buttonStyle(.bordered)
                }
            }
        }
        .id("reference")
    }

    private func solutionCodeBlock(_ source: String) -> some View {
        PythonCodeViewer(source: source)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.white.opacity(0.08))
            }
            .accessibilityLabel("Read-only Python reference code")
    }

    @ViewBuilder
    private var solutionAlternativesCard: some View {
        if progressRecord?.referenceViewed == true {
            LearningCard {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 5) {
                        Label("Other valid approaches", systemImage: "arrow.triangle.branch")
                            .appFont(.headline)
                        Text("Optimal is not one piece of code. Compare asymptotic cost, constant overhead, memory, early exits, readability, and how well each idea generalizes.")
                            .appFont(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(problem.solutionAlternatives) { alternative in
                        SolutionAlternativeView(alternative: alternative)
                    }

                    Label(
                        "Learning move: explain which approach you would choose under different constraints before moving on.",
                        systemImage: "brain.head.profile"
                    )
                    .appFont(.footnote, weight: .medium)
                    .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }

    private var milestoneIsPresented: Binding<Bool> {
        Binding(get: { milestoneMessage != nil }, set: { if !$0 { milestoneMessage = nil } })
    }

    private var errorIsPresented: Binding<Bool> {
        Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
    }

    @MainActor
    private func loadProgress() {
        saveTask?.cancel()
        persistLoadedWorkspace()
        pauseStudyTimer()

        hasLoaded = false
        progressRecord = nil
        loadedProblemID = nil
        draftCode = problem.starterCode
        notes = ""
        scratchpadCode = PythonScratchpad.starterCode
        runReport = nil
        scratchpadReport = nil
        scratchpadReportSource = nil
        isScratchpadExpanded = false
        handoffQuestion = ""

        do {
            let record = try progressService.record(for: problem, context: modelContext)
            progressRecord = record
            loadedProblemID = record.problemID
            draftCode = record.draftCode
            notes = record.notes
            scratchpadCode = record.scratchpadCode.isEmpty ? PythonScratchpad.starterCode : record.scratchpadCode
            hasLoaded = true
            refreshPendingProblemReminder()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func scheduleSave() {
        guard workspaceMatchesDisplayedProblem else { return }
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(500))
            } catch {
                return
            }
            saveNow()
        }
    }

    private func saveNow() {
        guard workspaceMatchesDisplayedProblem, let progressRecord, let loadedProblemID else { return }
        do {
            try progressService.saveDraft(
                progressRecord,
                forProblemID: loadedProblemID,
                code: draftCode,
                notes: notes,
                scratchpadCode: scratchpadCode,
                context: modelContext
            )
            refreshPendingProblemReminder()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func flagForReview() async {
        guard workspaceMatchesDisplayedProblem, let progressRecord else { return }
        isUpdatingReviewFlag = true
        defer { isUpdatingReviewFlag = false }
        saveNow()
        reminderRefreshTask?.cancel()
        await reminderRefreshTask?.value
        do {
            let reviewAt = try progressService.flagForReview(
                progressRecord,
                calendar: calendar,
                context: modelContext
            )
            _ = try await notificationService.scheduleProblemReminder(
                problemID: problem.id,
                title: problem.title,
                notes: notes,
                at: reviewAt
            )
        } catch {
            if progressRecord.isFlaggedForReview {
                errorMessage = "This problem is flagged and will appear in CodeStreak when due, but the system notification could not be scheduled. \(error.localizedDescription)"
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }

    @MainActor
    private func completeFlaggedReview() async {
        guard workspaceMatchesDisplayedProblem, let progressRecord else { return }
        isUpdatingReviewFlag = true
        defer { isUpdatingReviewFlag = false }
        saveNow()
        reminderRefreshTask?.cancel()
        await reminderRefreshTask?.value
        do {
            guard let reviewAt = try progressService.completeFlaggedReview(
                progressRecord,
                calendar: calendar,
                context: modelContext
            ) else { return }
            _ = try await notificationService.scheduleProblemReminder(
                problemID: problem.id,
                title: problem.title,
                notes: notes,
                at: reviewAt
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func clearReviewFlag() async {
        guard workspaceMatchesDisplayedProblem, let progressRecord else { return }
        isUpdatingReviewFlag = true
        defer { isUpdatingReviewFlag = false }
        reminderRefreshTask?.cancel()
        await reminderRefreshTask?.value
        do {
            try progressService.clearReviewFlag(progressRecord, context: modelContext)
            notificationService.cancelProblemReminder(problemID: problem.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshPendingProblemReminder() {
        guard let progressRecord,
              progressRecord.isFlaggedForReview,
              let reviewAt = progressRecord.flaggedReviewAt,
              reviewAt.timeIntervalSinceNow > 60 else { return }
        let previousTask = reminderRefreshTask
        previousTask?.cancel()
        let problemID = problem.id
        let title = problem.title
        let currentNotes = notes
        reminderRefreshTask = Task { @MainActor in
            await previousTask?.value
            guard !Task.isCancelled else { return }
            _ = try? await notificationService.scheduleProblemReminder(
                problemID: problemID,
                title: title,
                notes: currentNotes,
                at: reviewAt,
                requestAuthorization: false
            )
        }
    }

    private var workspaceMatchesDisplayedProblem: Bool {
        hasLoaded && loadedProblemID == problem.id && progressRecord?.problemID == problem.id
    }

    private func persistLoadedWorkspace() {
        guard hasLoaded, let progressRecord, let loadedProblemID,
              progressRecord.problemID == loadedProblemID else { return }
        do {
            try progressService.saveDraft(
                progressRecord,
                forProblemID: loadedProblemID,
                code: draftCode,
                notes: notes,
                scratchpadCode: scratchpadCode,
                context: modelContext
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func adoptExternallyMergedProgress() {
        guard workspaceMatchesDisplayedProblem,
              let progressRecord,
              progressRecord.modifiedBy != DeviceIdentity.id else { return }

        // Nearby sync mutates the SwiftData model directly. Keep the open
        // editor aligned with the winning record so its stale @State copy
        // cannot overwrite the just-synced draft when this view disappears.
        saveTask?.cancel()
        draftCode = progressRecord.draftCode
        notes = progressRecord.notes
        scratchpadCode = progressRecord.scratchpadCode.isEmpty
            ? PythonScratchpad.starterCode
            : progressRecord.scratchpadCode
        runReport = nil
        scratchpadReport = nil
        scratchpadReportSource = nil
        if progressRecord.isFlaggedForReview {
            refreshPendingProblemReminder()
        } else {
            reminderRefreshTask?.cancel()
            notificationService.cancelProblemReminder(problemID: problem.id)
        }
    }

    @MainActor
    private func runTests() async {
        guard workspaceMatchesDisplayedProblem, !isRunningScratchpad, let progressRecord else { return }
        let runningProblem = problem
        let runningProblemID = problem.id
        let source = draftCode
        saveTask?.cancel()
        saveNow()
        isRunning = true
        defer { isRunning = false }

        let report = await runner.run(problem: runningProblem, source: source)
        guard loadedProblemID == runningProblemID,
              problem.id == runningProblemID,
              self.progressRecord?.problemID == runningProblemID else { return }
        guard draftCode == source else {
            errorMessage = "Your code changed while the tests were running. Run the tests again to check the current draft."
            return
        }
        runReport = report

        do {
            let milestone = try progressService.recordRun(
                progressRecord,
                passed: report.allPassed,
                context: modelContext
            )
            if report.allPassed {
                try completionService.markCompleted(on: .now, context: modelContext, calendar: calendar)
                switch milestone {
                case .firstSolve:
                    let updatedPlan = planEngine.snapshot(records: progressRecords)
                    suggestedNextProblem = recommendedProblem(
                        forTrackContaining: runningProblemID,
                        plan: updatedPlan
                    )
                    milestoneMessage = firstSolveMessage(
                        for: runningProblem,
                        plan: updatedPlan,
                        hasSuggestedProblem: suggestedNextProblem != nil
                    )
                case let .reviewCompleted(level):
                    suggestedNextProblem = nil
                    milestoneMessage = "Review passed from memory. Your review level is now \(level)."
                case .attemptRecorded:
                    suggestedNextProblem = nil
                    milestoneMessage = "All tests passed again. Keep your explanation concise and move forward when ready."
                }
#if os(iOS)
                if !reduceMotion { UINotificationFeedbackGenerator().notificationOccurred(.success) }
#endif
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func runScratchpad() async {
        guard workspaceMatchesDisplayedProblem, !isRunning else { return }
        let runningProblemID = problem.id
        let source = scratchpadCode
        guard !source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        saveTask?.cancel()
        saveNow()
        isRunningScratchpad = true
        defer { isRunningScratchpad = false }

        let report = await runner.runScratchpad(source: source)
        guard loadedProblemID == runningProblemID,
              problem.id == runningProblemID,
              progressRecord?.problemID == runningProblemID else { return }
        guard scratchpadCode == source else {
            errorMessage = "The scratchpad changed while the cell was running. Run the cell again to see output from the current code."
            return
        }
        scratchpadReportSource = source
        scratchpadReport = report
    }

    private func revealNextHint() {
        guard workspaceMatchesDisplayedProblem, let progressRecord else { return }
        do {
            try progressService.revealNextHint(progressRecord, maximum: problem.hints.count, context: modelContext)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func revealReference() {
        guard workspaceMatchesDisplayedProblem, let progressRecord else { return }
        do {
            try progressService.markReferenceViewed(progressRecord, context: modelContext)
            referenceJump += 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func scrollReferenceIntoView() {
        referenceJump += 1
    }

    private func startStudyTimer(at date: Date = .now) {
        guard workspaceMatchesDisplayedProblem, timerStartedAt == nil else { return }
        timerStartedAt = date
    }

    private func pauseStudyTimer(at date: Date = .now) {
        guard let startedAt = timerStartedAt, let progressRecord else { return }
        let elapsed = max(Int(date.timeIntervalSince(startedAt)), 0)
        guard elapsed > 0 else {
            timerStartedAt = nil
            return
        }

        do {
            try progressService.addStudyTime(
                progressRecord,
                seconds: elapsed,
                at: date,
                context: modelContext
            )
            timerStartedAt = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetStudyTimer() {
        guard workspaceMatchesDisplayedProblem, timerStartedAt == nil, let progressRecord else { return }
        do {
            try progressService.resetStudyTime(progressRecord, context: modelContext)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func displayedStudySeconds(at date: Date) -> Int {
        let saved = max(progressRecord?.timeSpentSeconds ?? 0, 0)
        guard let timerStartedAt else { return saved }
        let elapsed = max(Int(date.timeIntervalSince(timerStartedAt)), 0)
        let (total, overflowed) = saved.addingReportingOverflow(elapsed)
        return overflowed ? Int.max : total
    }

    private func formattedStudyTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func focusGuidance(after minutes: Int) -> String {
        if minutes < 10 { return "Try independently; write the brute-force idea first." }
        if minutes < 20 { return "State the invariant, then reveal one hint if needed." }
        return "Compare the reference, then explain it without copying."
    }

    private func recommendedProblem(
        forTrackContaining problemID: String,
        plan: LearningPlanSnapshot
    ) -> AlgorithmProblem? {
        let recommendedID = problemID.hasPrefix("ml.")
            ? plan.nextMLProblemID
            : plan.nextProblemID
        return recommendedID.flatMap { Curriculum.problem(withID: $0) }
    }

    private func moduleProblemSymbol(
        for candidate: AlgorithmProblem,
        solvedIDs: Set<String>
    ) -> String {
        if candidate.id == problem.id { return "circle.inset.filled" }
        if solvedIDs.contains(candidate.id) { return "checkmark.circle.fill" }
        return "circle"
    }

    private func firstSolveMessage(
        for solvedProblem: AlgorithmProblem,
        plan: LearningPlanSnapshot,
        hasSuggestedProblem: Bool
    ) -> String {
        guard let module = Curriculum.module(containing: solvedProblem.id) else {
            return "All tests passed. This problem will return for review tomorrow."
        }

        let remainingCount = module.problems.filter { !plan.solvedIDs.contains($0.id) }.count
        if remainingCount > 0 {
            let noun = remainingCount == 1 ? "problem remains" : "problems remain"
            return "All tests passed. \(remainingCount) \(noun) in \(module.title). Choose any of them next or revisit earlier work. This problem will return for review tomorrow."
        }

        if hasSuggestedProblem {
            return "Module complete—every problem in \(module.title) is solved. The next module is now unlocked, and this problem will return for review tomorrow."
        }
        return "Track complete—every problem in this curriculum is solved. This problem will return for spaced review tomorrow."
    }

    private func performChatGPTHandoff(with prompt: String) {
        guard copyToClipboard(prompt) else {
            errorMessage = "CodeStreak could not copy the ChatGPT prompt. Please check clipboard access and try again."
            return
        }

        showingChatGPTHandoff = false
        guard let chatGPTURL = URL(string: "https://chatgpt.com/") else { return }

        // Keep this completion-free. On macOS, SwiftUI can invoke OpenURLAction's
        // completion on a Launch Services queue, where touching @State would violate
        // the main-actor isolation required by SwiftUI and crash under Swift 6.
        openURL(chatGPTURL)
    }

    private func copyToClipboard(_ text: String) -> Bool {
#if os(iOS)
        UIPasteboard.general.string = text
        return true
#elseif os(macOS)
        NSPasteboard.general.clearContents()
        return NSPasteboard.general.setString(text, forType: .string)
#endif
    }
}

private struct ChatGPTHandoffView: View {
    @Environment(\.dismiss) private var dismiss

    let problem: AlgorithmProblem
    let draftCode: String
    let notes: String
    let report: PythonRunReport?
    @Binding var question: String
    let onHandoff: (String) -> Void

    @State private var includeNotes = false
    @State private var showingPreview = false

    private var prompt: String {
        ChatGPTHandoffBuilder.prompt(
            problem: problem,
            draftCode: draftCode,
            notes: notes,
            includeNotes: includeNotes,
            report: report,
            question: question
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 7) {
                        Label("Learn with ChatGPT", systemImage: "sparkles")
                            .appFont(.title2, weight: .bold)
                            .foregroundStyle(AppTheme.accent)
                        Text("CodeStreak will copy a prepared learning prompt and open ChatGPT. Nothing is sent automatically—paste it into your ChatGPT conversation when it opens.")
                            .appFont(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("What would you like help with?")
                            .appFont(.headline)
                        TextEditor(text: $question)
                            .appFont(.body)
                            .scrollContentBackground(.hidden)
                            .padding(9)
                            .frame(minHeight: 120)
                            .learningInset()
                            .overlay {
                                if question.isEmpty {
                                    Text("For example: Why does this fail the duplicate-values test? Give me a hint, not the full solution.")
                                        .appFont(.body)
                                        .foregroundStyle(.tertiary)
                                        .padding(15)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .allowsHitTesting(false)
                                }
                            }
                    }

                    VStack(alignment: .leading, spacing: 11) {
                        Label("Included context", systemImage: "doc.on.clipboard.fill")
                            .appFont(.headline)
                        handoffContextRow("Problem and function contract", symbol: "doc.text.fill")
                        handoffContextRow("Your current Python draft", symbol: "chevron.left.forwardslash.chevron.right")
                        handoffContextRow(testContextSummary, symbol: "checklist")

                        Toggle("Include my learning notes", isOn: $includeNotes)
                            .appFont(.subheadline)
                            .disabled(notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Your notes are empty, so they will not be copied.")
                                .appFont(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(14)
                    .learningInset(cornerRadius: 13)

                    DisclosureGroup(isExpanded: $showingPreview) {
                        ScrollView([.horizontal, .vertical]) {
                            Text(prompt)
                                .appFont(.caption, design: .monospaced)
                                .foregroundStyle(AppTheme.codeForeground)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                        }
                        .frame(maxHeight: 260)
                        .background(AppTheme.codeBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding(.top, 8)
                    } label: {
                        Label("Preview what will be copied", systemImage: "eye.fill")
                            .appFont(.subheadline, weight: .bold)
                    }
                    .tint(.primary)

                    Button {
                        onHandoff(prompt)
                    } label: {
                        Label("Copy & Open ChatGPT", systemImage: "arrow.up.forward.app.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Text("After ChatGPT opens, paste with Command–V on Mac or tap the message box and choose Paste on iPhone.")
                        .appFont(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            }
            .learningBackground()
            .navigationTitle("Discuss \(problem.title)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
#if os(macOS)
        .frame(minWidth: 560, idealWidth: 620, minHeight: 620, idealHeight: 720)
#endif
    }

    private var testContextSummary: String {
        guard let report else { return "No test run yet" }
        if report.errorMessage != nil { return "Current Python runner error" }
        if report.allPassed { return "All \(report.results.count) tests passed" }
        return "\(report.results.count - report.passedCount) failed test\(report.results.count - report.passedCount == 1 ? "" : "s") with inputs and outputs"
    }

    private func handoffContextRow(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .appFont(.subheadline)
            .foregroundStyle(.secondary)
    }
}

private struct SolutionAlternativeView: View {
    let alternative: SolutionAlternative

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(alternative.kind.rawValue)
                    .appFont(.caption2, weight: .bold)
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.accent.opacity(0.11), in: Capsule())
                Text(alternative.title)
                    .appFont(.subheadline, weight: .bold)
            }

            Text(alternative.summary)
                .appFont(.subheadline)

            HStack(spacing: 15) {
                Label(alternative.timeComplexity, systemImage: "timer")
                Label(alternative.spaceComplexity, systemImage: "memorychip")
            }
            .appFont(.caption, weight: .bold)
            .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                comparisonLine(
                    title: "Best when",
                    text: alternative.bestWhen,
                    symbol: "checkmark.circle.fill",
                    color: .green
                )
                comparisonLine(
                    title: "Trade-off",
                    text: alternative.tradeoff,
                    symbol: "arrow.left.arrow.right.circle.fill",
                    color: .orange
                )
            }

            if let code = alternative.code {
                ScrollView(.horizontal) {
                    Text(code)
                        .appFont(fixedSize: 13, design: .monospaced)
                        .foregroundStyle(AppTheme.codeForeground)
                        .textSelection(.enabled)
                        .padding(13)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.codeBackground, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
        }
        .padding(13)
        .learningInset(cornerRadius: 13)
    }

    private func comparisonLine(title: String, text: String, symbol: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(color)
            Text("**\(title):** \(text)")
                .appFont(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct TestResultRow: View {
    let result: PythonTestResult
    @State private var isExpanded: Bool

    init(result: PythonTestResult) {
        self.result = result
        _isExpanded = State(initialValue: result.outcome != .passed)
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 10) {
                ResultValueBlock(title: "Input", value: result.input, tint: AppTheme.accent)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 10)], alignment: .leading, spacing: 10) {
                    ResultValueBlock(title: "Expected", value: result.expected, tint: .green)
                    ResultValueBlock(title: "Your return value", value: result.actual, tint: color)
                }

                if let message = result.message {
                    Label(message, systemImage: result.outcome == .error ? "ladybug.fill" : "lightbulb.fill")
                        .appFont(.caption)
                        .foregroundStyle(color)
                }
            }
            .padding(.top, 10)
        } label: {
            HStack(spacing: 8) {
                Label(result.name, systemImage: symbol)
                    .appFont(.subheadline, weight: .medium)
                    .foregroundStyle(color)
                Spacer()
                Text(outcomeTitle)
                    .appFont(.caption2, weight: .bold)
                    .foregroundStyle(color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.11), in: Capsule())
            }
        }
        .tint(.primary)
        .onChange(of: result.outcome) { _, outcome in
            if outcome != .passed { isExpanded = true }
        }
    }

    private var symbol: String {
        switch result.outcome {
        case .passed: "checkmark.circle.fill"
        case .failed: "xmark.circle.fill"
        case .error: "exclamationmark.triangle.fill"
        }
    }

    private var color: Color {
        switch result.outcome {
        case .passed: .green
        case .failed: .red
        case .error: .orange
        }
    }

    private var outcomeTitle: String {
        switch result.outcome {
        case .passed: "Passed"
        case .failed: "Failed"
        case .error: "Python error"
        }
    }
}

private struct ResultValueBlock: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .appFont(.caption, weight: .bold)
                .foregroundStyle(tint)
            Text(value)
                .appFont(.caption, design: .monospaced)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.055), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(tint.opacity(0.12))
        }
    }
}
