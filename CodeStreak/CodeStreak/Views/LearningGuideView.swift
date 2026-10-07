import SwiftUI

struct LearningGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                guideHeader
                beginnerRoute
                dailyLoop
                patternRecognition
                hintLadder
                reviewSystem
                notesTemplate
                research
            }
            .frame(maxWidth: 800, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Learning Guide")
        .learningBackground()
    }

    private var guideHeader: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    LearningIcon(symbol: "brain.head.profile.fill")
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Learn patterns, not answers")
                            .appFont(.title2, weight: .bold)
                        Text("A research-informed system for algorithm practice")
                            .appFont(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Text("No computer-science background is assumed. The app must first teach what a set, pointer, window, stack, queue, search, or dynamic program actually is. Only then should you be asked to recognize and apply it.")
                    .appFont(.body)

                Text("The studies below examine learning and programming education rather than this app or LeetCode directly. The routines here are practical applications of that evidence, not a promise that one schedule fits everyone.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var beginnerRoute: some View {
        GuideSection(
            title: "The route from mathematics to algorithms",
            subtitle: "Technique names are conclusions to understand—not vocabulary you were supposed to arrive knowing.",
            symbol: "graduationcap.fill"
        ) {
            VStack(alignment: .leading, spacing: 15) {
                GuideStepRow(number: 1, title: "Definition", detail: "Read the data structure as a mathematical object: a set, mapping, ordered frontier, recurrence, or invariant-preserving state.")
                GuideStepRow(number: 2, title: "When it applies", detail: "Check the assumptions that make each update safe. A sorted order, contiguity, monotonic condition, or repeated state is evidence—not merely a keyword.")
                GuideStepRow(number: 3, title: "Micro-drill", detail: "Trace one update by hand. If you cannot predict the state after that update, return to the definition before attempting a full problem.")
                GuideStepRow(number: 4, title: "Guided application", detail: "Use the named candidates and explain which one removes the slow approach's repeated work.")
                GuideStepRow(number: 5, title: "Blind assessment", detail: "At the module end, pattern labels disappear. Derive the method from the contract, constraints, and work being repeated.")

                Label("Open a module's Algorithm course before its first problem.", systemImage: "book.pages.fill")
                    .appFont(.subheadline, weight: .semibold)
                    .foregroundStyle(AppTheme.accent)
            }
        }
    }

    private var dailyLoop: some View {
        GuideSection(
            title: "The 30-minute problem loop",
            subtitle: "One focused attempt followed by feedback is more useful than an hour of directionless code.",
            symbol: "arrow.triangle.2.circlepath"
        ) {
            VStack(alignment: .leading, spacing: 15) {
                GuideStepRow(number: 1, title: "Understand · 0–3 min", detail: "Restate the input and output. Read the constraints. On guided problems, review the named techniques; on blind checks, propose candidates from techniques already taught.")
                GuideStepRow(number: 2, title: "Model · 3–8 min", detail: "Write the brute-force idea, its cost, the state you need, and one invariant. Do this before polishing Python syntax.")
                GuideStepRow(number: 3, title: "Build · 8–20 min", detail: "Implement the smallest complete approach. Trace a normal case and at least one boundary case by hand.")
                GuideStepRow(number: 4, title: "Diagnose · 20–25 min", detail: "Run the tests. Compare the exact named inputs, expected values, and your return values. Classify the miss: recognition, logic, boundary, complexity, or Python.")
                GuideStepRow(number: 5, title: "Explain · 25–30 min", detail: "After solving or studying the reference, close it. Explain why the invariant proves correctness and record the cue you want to notice next time.")
            }
        }
    }

    private var patternRecognition: some View {
        GuideSection(
            title: "Train the decision before the implementation",
            subtitle: "Pattern recognition is trained only after the relevant tools have been explicitly taught.",
            symbol: "square.grid.2x2.fill"
        ) {
            VStack(alignment: .leading, spacing: 13) {
                GuideIdeaRow(
                    title: "Start blocked, then mix",
                    detail: "Learn a new set with a short run of related problems so its invariant becomes visible. Then let due reviews mix old sets; choosing the pattern is part of the practice."
                )
                GuideIdeaRow(
                    title: "Predict before revealing",
                    detail: "Before opening hints, write: likely pattern, state, invariant, target complexity, and the edge case most likely to break the approach."
                )
                GuideIdeaRow(
                    title: "Contrast close neighbors",
                    detail: "Ask why this is sliding window rather than two pointers, BFS rather than DFS, greedy rather than DP, or a heap rather than sorting once."
                )
                GuideIdeaRow(
                    title: "Vary the surface story",
                    detail: "Transfer practice must change the actual contract or constraints—not just the title. Use scheduled reviews when the goal is to retrieve the same problem again."
                )
            }
        }
    }

    private var hintLadder: some View {
        GuideSection(
            title: "Use help without giving away the learning",
            subtitle: "Hints are a ladder. Take only the next rung, then resume retrieval.",
            symbol: "lightbulb.fill"
        ) {
            VStack(alignment: .leading, spacing: 13) {
                GuideStepRow(number: 1, title: "Clarify", detail: "Re-read the contract, examples, constraints, and test-case names. Create your own tiny example.")
                GuideStepRow(number: 2, title: "Expose the brute force", detail: "Describe the obviously correct slow solution and locate the repeated work.")
                GuideStepRow(number: 3, title: "Reveal one hint", detail: "Pause after one hint and turn it into your own invariant or next code step before asking for more.")
                GuideStepRow(number: 4, title: "Study the reference actively", detail: "After a genuine attempt, predict each next line, compare it with your draft, and explain every data-structure operation.")
                GuideStepRow(number: 5, title: "Rebuild later", detail: "The next day, start from blank starter code. A solution you can reconstruct is more valuable than one that merely looks familiar.")
            }
        }
    }

    private var reviewSystem: some View {
        GuideSection(
            title: "A sustainable review rhythm",
            subtitle: "Consistency means returning at useful intervals, not protecting a streak with exhausted late-night grinding.",
            symbol: "calendar.badge.clock"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    ForEach(["1d", "3d", "7d", "14d", "30d", "60d"], id: \.self) { interval in
                        Text(interval)
                            .appFont(.caption, weight: .bold)
                            .foregroundStyle(AppTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .learningInset(cornerRadius: 10)
                    }
                }

                Text("CodeStreak schedules approximately these intervals after successful recall. If a review fails, diagnose it and rebuild sooner. If it is effortless, move on; difficulty during retrieval is useful, but endless repetition is not.")
                    .appFont(.subheadline)
                    .foregroundStyle(.secondary)

                Label("Aim for 1–2 new problems per day, then complete due reviews before adding more.", systemImage: "checkmark.seal.fill")
                    .appFont(.subheadline, weight: .medium)
                    .foregroundStyle(AppTheme.accent)
            }
        }
    }

    private var notesTemplate: some View {
        GuideSection(
            title: "Keep an error log that changes behavior",
            subtitle: "Transcribing code is weak notes. Record the decision you want future-you to make.",
            symbol: "note.text"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                NotesPrompt(label: "Cue", prompt: "What words, constraints, or structure should trigger this pattern?")
                NotesPrompt(label: "Invariant", prompt: "What stays true after each iteration or recursive return?")
                NotesPrompt(label: "Miss", prompt: "Was the error recognition, logic, boundary, complexity, or Python?")
                NotesPrompt(label: "Fix", prompt: "What exact check or question will prevent the same miss?")
                NotesPrompt(label: "Explain", prompt: "Why is the final complexity valid, and why is the algorithm correct?")
            }
        }
    }

    private var research: some View {
        GuideSection(
            title: "Research behind the system",
            subtitle: "Open any source to read the paper record or publication page.",
            symbol: "books.vertical.fill"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(LearningGuidance.researchSources) { source in
                    Link(destination: source.url) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .appFont(.headline)
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(source.title)
                                    .appFont(.subheadline, weight: .bold)
                                    .foregroundStyle(.primary)
                                Text(source.authorsAndYear)
                                    .appFont(.caption, weight: .bold)
                                    .foregroundStyle(AppTheme.accent)
                                Text(source.takeaway)
                                    .appFont(.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 4)
                            Image(systemName: "arrow.up.right")
                                .appFont(.caption, weight: .bold)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(14)
                        .learningInset()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct PatternLessonView: View {
    let module: CurriculumModule
    var focusedTechniqueIDs: [String] = []

    private var lesson: PatternLesson { module.lesson }
    private var course: ModuleCourse { module.course }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    lessonHeader

                    LessonSection(title: "Your route through this module", symbol: "map.fill") {
                        VStack(alignment: .leading, spacing: 14) {
                            GuideStepRow(number: 1, title: "Learn the tools", detail: "Read what each algorithm does, when its assumptions hold, and the invariant that makes it correct.")
                            GuideStepRow(number: 2, title: "Do the tiny drills", detail: "Answer from the definition before revealing the hint or answer. No full program is required.")
                            GuideStepRow(number: 3, title: "Guided → practice", detail: "Early problems name the available techniques; later practice asks you to choose and adapt one.")
                            GuideStepRow(number: 4, title: "Blind check", detail: "The final problems hide the module pattern. Diagnose the problem before opening any hint or reference.")
                        }
                    }

                    LessonSection(title: "Prerequisites", symbol: "checklist") {
                        LessonBulletList(items: course.prerequisites, symbol: "checkmark.circle.fill", tint: .green)
                    }

                    ForEach(Array(course.techniques.enumerated()), id: \.element.id) { index, technique in
                        TechniqueLessonCard(
                            number: index + 1,
                            technique: technique,
                            isProblemPrerequisite: focusedTechniqueIDs.contains(technique.id)
                        )
                        .id(technique.id)
                    }

                    LessonSection(title: "Ask these questions first", symbol: "questionmark.bubble.fill") {
                        LessonBulletList(items: lesson.recognitionQuestions, symbol: "sparkle", tint: AppTheme.accent)
                    }

                    LessonSection(title: "A reliable playbook", symbol: "list.number") {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(Array(lesson.strategySteps.enumerated()), id: \.offset) { index, step in
                                GuideStepRow(number: index + 1, title: step, detail: nil)
                            }
                        }
                    }

                    LessonSection(title: "Common traps", symbol: "exclamationmark.triangle.fill") {
                        LessonBulletList(items: lesson.commonPitfalls, symbol: "exclamationmark.circle.fill", tint: .orange)
                    }

                    LearningCard {
                        VStack(alignment: .leading, spacing: 9) {
                            Label("Complexity target", systemImage: "gauge.with.dots.needle.50percent")
                                .appFont(.headline)
                            Text(lesson.complexityTarget)
                                .appFont(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    LearningCard {
                        VStack(alignment: .leading, spacing: 9) {
                            Label("Retrieval check", systemImage: "brain.fill")
                                .appFont(.headline)
                            Text("Before opening the next problem, hide this page and say the mental model, two recognition questions, and the invariant you expect to maintain.")
                                .appFont(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: 760, alignment: .leading)
                .padding()
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                guard let firstTechniqueID = focusedTechniqueIDs.first else { return }
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(firstTechniqueID, anchor: .top)
                    }
                }
            }
        }
        .navigationTitle(module.title)
        .learningBackground()
    }

    private var lessonHeader: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    LearningIcon(symbol: module.symbol)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("ALGORITHM COURSE")
                            .appFont(.caption2, weight: .bold)
                            .foregroundStyle(AppTheme.accent)
                        Text(module.title)
                            .appFont(.title2, weight: .bold)
                    }
                }
                Text(module.summary)
                    .appFont(.subheadline)
                    .foregroundStyle(.secondary)
                Text(lesson.mentalModel)
                    .appFont(.body, weight: .medium)

                Label("No computer-science vocabulary is assumed here.", systemImage: "person.fill.checkmark")
                    .appFont(.footnote, weight: .semibold)
                    .foregroundStyle(AppTheme.accent)
            }
        }
    }
}

private struct TechniqueLessonCard: View {
    let number: Int
    let technique: AlgorithmTechnique
    let isProblemPrerequisite: Bool

    var body: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Text("\(number)")
                        .appFont(.caption, weight: .bold)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(AppTheme.accent, in: Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text(isProblemPrerequisite ? "REQUIRED FOR THIS PROBLEM" : "TECHNIQUE")
                            .appFont(.caption2, weight: .bold)
                            .foregroundStyle(AppTheme.accent)
                        Text(technique.name).appFont(.title3, weight: .bold)
                    }
                }

                Text(technique.plainLanguageMeaning).appFont(.body)

                VStack(alignment: .leading, spacing: 7) {
                    Label("Mathematical view", systemImage: "function")
                        .appFont(.caption, weight: .bold)
                        .foregroundStyle(AppTheme.accent)
                    if let latex = technique.latexFormula {
                        LatexMathView(
                            latex: latex,
                            accessibilityDescription: technique.mathematicalView
                        )
                    }
                    Text(technique.mathematicalView)
                        .appFont(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .learningInset(cornerRadius: 10)

                TechniqueVisualizationView(technique: technique)

                VStack(alignment: .leading, spacing: 9) {
                    Text("Use it when…")
                        .appFont(.caption, weight: .bold)
                        .foregroundStyle(.green)
                    LessonBulletList(items: technique.useWhen, symbol: "checkmark.circle.fill", tint: .green)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Do not reach for it automatically")
                        .appFont(.caption, weight: .bold)
                        .foregroundStyle(.orange)
                    Text(technique.doNotUseWhen)
                        .appFont(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Label("Invariant to say out loud", systemImage: "equal.circle.fill")
                        .appFont(.caption, weight: .bold)
                        .foregroundStyle(AppTheme.accent)
                    Text(technique.invariant)
                        .appFont(.subheadline, weight: .medium)
                }

                DisclosureGroup("Python skeleton") {
                    PythonCodeViewer(source: technique.pythonTemplate)
                        .padding(.top, 10)
                }
                .appFont(.subheadline, weight: .semibold)
                .tint(AppTheme.accent)

                TechniqueDrillView(technique: technique)
            }
        }
    }
}

private struct TechniqueDrillView: View {
    let technique: AlgorithmTechnique

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Two-minute technique drill", systemImage: "stopwatch.fill")
                .appFont(.subheadline, weight: .bold)
            Text(technique.drillPrompt).appFont(.subheadline)

            DisclosureGroup("Need one hint?") {
                Text(technique.drillHint)
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 7)
            }
            DisclosureGroup("Check the answer") {
                Text(technique.drillAnswer)
                    .appFont(.footnote, weight: .medium)
                    .padding(.top, 7)
            }
        }
        .padding(13)
        .background(AppTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .tint(AppTheme.accent)
    }
}

private struct GuideSection<Content: View>: View {
    let title: String
    let subtitle: String
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 11) {
                    Image(systemName: symbol)
                        .appFont(.headline)
                        .foregroundStyle(AppTheme.accent)
                        .frame(width: 26)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).appFont(.headline)
                        Text(subtitle)
                            .appFont(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Divider()
                content
            }
        }
    }
}

private struct LessonSection<Content: View>: View {
    let title: String
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 15) {
                Label(title, systemImage: symbol).appFont(.headline)
                content
            }
        }
    }
}

private struct GuideStepRow: View {
    let number: Int
    let title: String
    let detail: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .appFont(.caption, weight: .bold)
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(AppTheme.accent, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title).appFont(.subheadline, weight: .semibold)
                if let detail {
                    Text(detail)
                        .appFont(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct GuideIdeaRow: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "diamond.fill")
                .appFont(fixedSize: 8)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 20, height: 20)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).appFont(.subheadline, weight: .semibold)
                Text(detail).appFont(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}

private struct NotesPrompt: View {
    let label: String
    let prompt: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(label.uppercased())
                .appFont(.caption2, weight: .bold)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 58, alignment: .leading)
            Text(prompt)
                .appFont(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 3)
    }
}

private struct LessonBulletList: View {
    let items: [String]
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            ForEach(items, id: \.self) { item in
                Label {
                    Text(item)
                        .appFont(.subheadline)
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: symbol)
                        .foregroundStyle(tint)
                }
            }
        }
    }
}
