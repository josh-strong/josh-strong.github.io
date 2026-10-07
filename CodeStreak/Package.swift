// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodeStreakLogic",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CodeStreakCore", targets: ["CodeStreakCore"])
    ],
    targets: [
        .target(
            name: "CodeStreakCore",
            path: "CodeStreak",
            exclude: [
                "App",
                "Assets.xcassets",
                "CodeStreak.entitlements",
                "Info.plist",
                "Models/CompletionRecord.swift",
                "Models/LearningProgressRecord.swift",
                "Models/ReminderSettings.swift",
                "Resources",
                "Views",
                "Services/CompletionService.swift",
                "Services/LearningProgressService.swift",
                "Services/NearbySyncService.swift",
                "Services/NotificationService.swift",
                "Services/PythonRunner.swift",
                "Services/SyncMergeService.swift",
                "Services/WidgetProgressExporter.swift",
                "Utilities/AppConstants.swift"
            ],
            sources: [
                "Models/AlgorithmProblem.swift",
                "Services/AdversarialTestCatalog.swift",
                "Services/Curriculum.swift",
                "Services/CurriculumPrerequisiteCatalog.swift",
                "Services/ExtendedCurriculum.swift",
                "Services/MasteryCurriculum.swift",
                "Services/MLInterviewCurriculum.swift",
                "Services/MLProductionSolutionCatalog.swift",
                "Services/SolutionComparisonCatalog.swift",
                "Services/TechniqueLatexCatalog.swift",
                "Services/TechniqueVisualizationCatalog.swift",
                "Services/LearningGuidance.swift",
                "Services/StreakCalculator.swift",
                "Services/WidgetProgressSnapshot.swift",
                "Utilities/CalendarDay.swift"
            ]
        ),
        .testTarget(
            name: "CodeStreakCoreTests",
            dependencies: ["CodeStreakCore"],
            path: "CodeStreakTests",
            exclude: [
                "CompletionServiceTests.swift",
                "LearningProgressServiceTests.swift",
                "PythonRunnerTests.swift",
                "SyncMergeServiceTests.swift"
            ],
            sources: ["CurriculumTests.swift", "StreakCalculatorTests.swift", "WidgetProgressSnapshotTests.swift"]
        )
    ]
)
