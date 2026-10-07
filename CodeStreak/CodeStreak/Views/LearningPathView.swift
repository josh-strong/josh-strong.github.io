import SwiftData
import SwiftUI

struct LearningPathView: View {
    @Query private var progressRecords: [LearningProgressRecord]
    private let engine = LearningPlanEngine()

    private var plan: LearningPlanSnapshot {
        engine.snapshot(records: progressRecords)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                pathHeader
                blindPracticeCard
                mlInterviewLabCard

                ForEach(Array(Curriculum.modules.enumerated()), id: \.element.id) { moduleIndex, module in
                    ModulePathCard(
                        moduleNumber: moduleIndex + 1,
                        module: module,
                        plan: plan
                    )
                }
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Learning Path")
        .learningBackground()
    }

    private var blindPracticeCard: some View {
        let ready = Curriculum.readyBlindProblems(
            solvedIDs: plan.solvedIDs,
            accessibleIDs: plan.accessibleIDs
        )

        return Group {
            if ready.isEmpty {
                LearningCard {
                    HStack(alignment: .top, spacing: 12) {
                        LearningIcon(symbol: "eye.slash.fill")
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Blind Practice").appFont(.headline)
                            Text("Your first unlabeled check appears after you finish the teaching and practice problems before it.")
                                .appFont(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                NavigationLink {
                    BlindPracticeView()
                } label: {
                    LearningCard {
                        HStack(alignment: .top, spacing: 12) {
                            LearningIcon(symbol: "eye.slash.fill")
                            VStack(alignment: .leading, spacing: 5) {
                                Text("BLIND PRACTICE")
                                    .appFont(.caption2, weight: .bold)
                                    .foregroundStyle(.purple)
                                Text("Choose without a pattern label").appFont(.headline)
                                Text("\(ready.count) ready check\(ready.count == 1 ? "" : "s") mixed outside their module cards")
                                    .appFont(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var pathHeader: some View {
        let solvedCount = Curriculum.algorithmProblems.filter { plan.solvedIDs.contains($0.id) }.count
        return LearningCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    LearningIcon(symbol: "map.fill")
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Pattern-first curriculum").appFont(.title3, weight: .bold)
                        Text("\(solvedCount) of \(Curriculum.algorithmProblems.count) pattern problems complete")
                            .appFont(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                ProgressView(value: Double(solvedCount), total: Double(Curriculum.algorithmProblems.count))
                    .tint(AppTheme.accent)
                Text("The path unlocks one module at a time. Within your current module, choose the problems in any order and revisit earlier work whenever you like. The next module opens after every problem in the current one is solved.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)

                NavigationLink {
                    LearningGuideView()
                } label: {
                    Label("How to practise effectively", systemImage: "books.vertical.fill")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var mlInterviewLabCard: some View {
        let solvedCount = Curriculum.mlInterviewProblems.filter { plan.solvedIDs.contains($0.id) }.count
        return NavigationLink {
            MLInterviewLabView()
        } label: {
            LearningCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 13) {
                        LearningIcon(symbol: "atom")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PARALLEL INTERVIEW TRACK")
                                .appFont(.caption2, weight: .bold)
                                .foregroundStyle(AppTheme.accent)
                            Text("ML / Deep Learning Interview Lab")
                                .appFont(.headline)
                            Text("20 longer Python builds for research scientist and research engineer roles")
                                .appFont(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: Double(solvedCount), total: Double(Curriculum.mlInterviewProblems.count))
                        .tint(AppTheme.accent)
                    HStack {
                        Label("\(solvedCount)/\(Curriculum.mlInterviewProblems.count)", systemImage: "checkmark.circle.fill")
                        Spacer()
                        Text("Starts independently")
                    }
                    .appFont(.caption, weight: .semibold)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens the machine learning interview curriculum")
    }
}

private struct BlindPracticeView: View {
    @Query private var progressRecords: [LearningProgressRecord]
    private let engine = LearningPlanEngine()

    private var plan: LearningPlanSnapshot {
        engine.snapshot(records: progressRecords)
    }

    private var readyProblems: [AlgorithmProblem] {
        Curriculum.readyBlindProblems(
            solvedIDs: plan.solvedIDs,
            accessibleIDs: plan.accessibleIDs
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                LearningCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Pattern labels are off", systemImage: "eye.slash.fill")
                            .appFont(.title3, weight: .bold)
                            .foregroundStyle(.purple)
                        Text("These checks are removed from their module context. Start from the contract, constraints, slow method, and repeated work. If you reveal help, record the cue you missed and continue—supported learning still counts.")
                            .appFont(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                ForEach(readyProblems) { problem in
                    NavigationLink {
                        ProblemWorkspaceFlowView(initialProblem: problem)
                            .id(problem.id)
                    } label: {
                        let number = (Curriculum.algorithmProblems.firstIndex { $0.id == problem.id } ?? 0) + 1
                        ProblemRow(
                            number: number,
                            problem: problem,
                            state: plan.solvedIDs.contains(problem.id) ? .solved : .available,
                            learningMode: .blindAssessment
                        )
                        .padding(14)
                        .learningInset()
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Blind Practice")
        .learningBackground()
    }
}

private struct MLInterviewLabView: View {
    @Query private var progressRecords: [LearningProgressRecord]
    private let engine = LearningPlanEngine()

    private var plan: LearningPlanSnapshot {
        engine.snapshot(records: progressRecords)
    }

    private var solvedCount: Int {
        Curriculum.mlInterviewProblems.filter { plan.solvedIDs.contains($0.id) }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LearningCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            LearningIcon(symbol: "atom")
                            VStack(alignment: .leading, spacing: 3) {
                                Text("ML / Deep Learning Interview Lab").appFont(.title3, weight: .bold)
                                Text("\(solvedCount) of \(Curriculum.mlInterviewProblems.count) builds complete")
                                    .appFont(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        ProgressView(value: Double(solvedCount), total: Double(Curriculum.mlInterviewProblems.count))
                            .tint(AppTheme.accent)
                        Text("Advance through this lab alongside the algorithms path. Every build in the current lab set is available in any order; finish the whole set to open the next one. Solve with plain Python so the mechanics stay visible, then compare the reference with the framework versions.")
                            .appFont(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                interviewResearchCard

                ForEach(Array(Curriculum.mlInterviewModules.enumerated()), id: \.element.id) { moduleIndex, module in
                    ModulePathCard(moduleNumber: moduleIndex + 1, module: module, plan: plan)
                }
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("ML Interview Lab")
        .learningBackground()
    }

    private var interviewResearchCard: some View {
        LearningCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Why this curriculum", systemImage: "doc.text.magnifyingglass")
                    .appFont(.headline)
                Text("Current research-engineering guidance converges on two abilities: write reliable, tested code and translate mathematical model definitions into efficient implementations. The sets below deliberately alternate those skills.")
                    .appFont(.footnote)
                    .foregroundStyle(.secondary)

                DisclosureGroup("Research and role sources") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(MLInterviewCurriculum.researchSources) { source in
                            Link(destination: source.url) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(source.title).appFont(.subheadline, weight: .semibold)
                                        Image(systemName: "arrow.up.right.square")
                                    }
                                    Text(source.authorsAndYear)
                                        .appFont(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(source.takeaway)
                                        .appFont(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 10)
                }
                .appFont(.subheadline, weight: .semibold)
                .tint(AppTheme.accent)
            }
        }
    }
}

private struct ModulePathCard: View {
    let moduleNumber: Int
    let module: CurriculumModule
    let plan: LearningPlanSnapshot

    @State private var expanded: Bool

    init(moduleNumber: Int, module: CurriculumModule, plan: LearningPlanSnapshot) {
        self.moduleNumber = moduleNumber
        self.module = module
        self.plan = plan
        let nextID = module.id.hasPrefix("ml-") ? plan.nextMLProblemID : plan.nextProblemID
        let containsCurrent = module.problems.contains { $0.id == nextID }
        _expanded = State(initialValue: containsCurrent || moduleNumber == 1)
    }

    private var solvedCount: Int {
        module.problems.filter { plan.solvedIDs.contains($0.id) }.count
    }

    var body: some View {
        LearningCard {
            DisclosureGroup(isExpanded: $expanded) {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Algorithm course", systemImage: "graduationcap.fill")
                            .appFont(.subheadline, weight: .bold)

                        Text(module.lesson.mentalModel)
                            .appFont(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Learn before solving")
                            .appFont(.caption, weight: .bold)
                            .foregroundStyle(AppTheme.accent)
                        ForEach(module.course.techniques.map(\.name), id: \.self) { name in
                            Label(name, systemImage: "book.closed.fill")
                                .appFont(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        NavigationLink {
                            PatternLessonView(module: module)
                        } label: {
                            Label("Learn the \(module.title) techniques", systemImage: "book.pages.fill")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)
                    }

                    Divider()

                    ForEach(Array(module.problems.enumerated()), id: \.element.id) { localIndex, problem in
                        let globalIndex: Int = if module.id.hasPrefix("ml-") {
                            (Curriculum.mlInterviewProblems.firstIndex { $0.id == problem.id } ?? 0) + 1
                        } else {
                            (Curriculum.algorithmProblems.firstIndex { $0.id == problem.id } ?? 0) + 1
                        }
                        let state = state(for: problem)

                        if plan.accessibleIDs.contains(problem.id) {
                            NavigationLink {
                                ProblemWorkspaceFlowView(initialProblem: problem)
                                    .id(problem.id)
                            } label: {
                                ProblemRow(
                                    number: globalIndex,
                                    problem: problem,
                                    state: state,
                                    learningMode: module.learningPlacement(for: problem.id).mode
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            ProblemRow(
                                number: globalIndex,
                                problem: problem,
                                state: .locked,
                                learningMode: module.learningPlacement(for: problem.id).mode
                            )
                        }

                        if localIndex < module.problems.count - 1 { Divider().padding(.leading, 48) }
                    }
                }
                .padding(.top, 14)
            } label: {
                HStack(spacing: 12) {
                    LearningIcon(symbol: module.symbol)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(module.id.hasPrefix("ml-") ? "LAB SET" : "MODULE") \(moduleNumber)")
                            .appFont(.caption2, weight: .bold)
                            .foregroundStyle(.secondary)
                        Text(module.title).appFont(.headline)
                        Text(module.summary)
                            .appFont(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    Text("\(solvedCount)/\(module.problems.count)")
                        .appFont(.subheadline, weight: .bold)
                        .foregroundStyle(solvedCount == module.problems.count ? .green : AppTheme.accent)
                }
            }
            .tint(.primary)
        }
    }

    private func state(for problem: AlgorithmProblem) -> ProblemRow.State {
        if plan.solvedIDs.contains(problem.id) { return .solved }
        let nextID = module.id.hasPrefix("ml-") ? plan.nextMLProblemID : plan.nextProblemID
        if nextID == problem.id { return .current }
        if plan.accessibleIDs.contains(problem.id) { return .available }
        return .locked
    }

}
