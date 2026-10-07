import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum AppAppearance {
    static let darkModeEnabledKey = "appDarkModeEnabled"
}

@MainActor
final class AppTextSizeController: ObservableObject {
    static let storageKey = "appTextSizeOffset"

    @Published private(set) var offset: Int

    private let defaults: UserDefaults
    private let minimumOffset = -5
    private let maximumOffset = 5

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        offset = min(max(defaults.integer(forKey: Self.storageKey), minimumOffset), maximumOffset)
    }

    var displayName: String {
        switch offset {
        case ..<0: "Smaller \(abs(offset))"
        case 1...: "Larger \(offset)"
        default: "System default"
        }
    }

    var canIncrease: Bool { offset < maximumOffset }
    var canDecrease: Bool { offset > minimumOffset }
    var canReset: Bool { offset != 0 }

    var scaleFactor: CGFloat {
        switch offset {
        case ...(-5): 0.72
        case -4: 0.78
        case -3: 0.84
        case -2: 0.90
        case -1: 0.95
        case 1: 1.10
        case 2: 1.21
        case 3: 1.34
        case 4: 1.48
        case 5...: 1.64
        default: 1
        }
    }

    func increase() { setOffset(offset + 1) }
    func decrease() { setOffset(offset - 1) }
    func reset() { setOffset(0) }

    func resolvedSize(from systemSize: DynamicTypeSize) -> DynamicTypeSize {
        let sizes: [DynamicTypeSize] = [
            .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge,
            .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5
        ]
        let systemIndex = sizes.firstIndex(of: systemSize) ?? 3
        let resolvedIndex = min(max(systemIndex + offset, 0), sizes.count - 1)
        return sizes[resolvedIndex]
    }

    static func codeFontSize(for size: DynamicTypeSize) -> CGFloat {
        switch size {
        case .xSmall: 11
        case .small: 12
        case .medium: 13
        case .large: 14
        case .xLarge: 16
        case .xxLarge: 18
        case .xxxLarge: 20
        case .accessibility1: 23
        case .accessibility2: 26
        case .accessibility3: 29
        case .accessibility4: 32
        case .accessibility5: 36
        @unknown default: 14
        }
    }

    private func setOffset(_ newValue: Int) {
        let clamped = min(max(newValue, minimumOffset), maximumOffset)
        guard clamped != offset else { return }
        offset = clamped
        defaults.set(clamped, forKey: Self.storageKey)
    }
}

private struct AppFontScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1
}

extension EnvironmentValues {
    var appFontScale: CGFloat {
        get { self[AppFontScaleKey.self] }
        set { self[AppFontScaleKey.self] = newValue }
    }
}

enum AppTextStyle {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption
    case caption2

    var swiftUIStyle: Font.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption
        case .caption2: .caption2
        }
    }

    var defaultWeight: Font.Weight {
        self == .headline ? .semibold : .regular
    }

#if os(macOS)
    var macPointSize: CGFloat {
        let style: NSFont.TextStyle = switch self {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .body: .body
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        }
        return NSFont.preferredFont(forTextStyle: style).pointSize
    }
#endif
}

private struct AppTextSizeModifier: ViewModifier {
    @ObservedObject var controller: AppTextSizeController
    @Environment(\.dynamicTypeSize) private var systemTextSize

    @ViewBuilder
    func body(content: Content) -> some View {
#if os(macOS)
        content
            .environment(\.appFontScale, controller.scaleFactor)
            .font(.system(size: AppTextStyle.body.macPointSize * controller.scaleFactor))
#else
        content.dynamicTypeSize(controller.resolvedSize(from: systemTextSize))
            .environment(\.appFontScale, controller.scaleFactor)
#endif
    }
}

private struct AppFontModifier: ViewModifier {
    @Environment(\.appFontScale) private var scale

    let style: AppTextStyle?
    let fixedSize: CGFloat?
    let weight: Font.Weight?
    let design: Font.Design
    let monospacedDigits: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        let font = resolvedFont
        if monospacedDigits {
            content.font(font).monospacedDigit()
        } else {
            content.font(font)
        }
    }

    private var resolvedFont: Font {
        if let fixedSize {
            return .system(size: fixedSize * scale, weight: weight ?? .regular, design: design)
        }

        let style = style ?? .body
#if os(macOS)
        return .system(
            size: style.macPointSize * scale,
            weight: weight ?? style.defaultWeight,
            design: design
        )
#else
        return .system(
            style.swiftUIStyle,
            design: design,
            weight: weight ?? style.defaultWeight
        )
#endif
    }
}

enum AppTheme {
    static let accent = Color(red: 0.31, green: 0.36, blue: 0.86)
    static let codeBackground = Color(red: 0.075, green: 0.085, blue: 0.11)
    static let codeForeground = Color(red: 0.86, green: 0.90, blue: 0.98)
    static let cardRadius: CGFloat = 18

    static var pageBackground: Color {
#if os(iOS)
        Color(uiColor: .systemGroupedBackground)
#else
        Color(nsColor: .windowBackgroundColor)
#endif
    }

    static var surface: Color {
#if os(iOS)
        Color(uiColor: .secondarySystemGroupedBackground)
#else
        Color(nsColor: .controlBackgroundColor)
#endif
    }

    static var secondarySurface: Color {
#if os(iOS)
        Color(uiColor: .tertiarySystemGroupedBackground)
#else
        Color.primary.opacity(0.045)
#endif
    }
}

struct LearningCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.07))
            }
            .shadow(color: .black.opacity(0.035), radius: 10, y: 3)
    }
}

struct LearningIcon: View {
    let symbol: String
    var colors: [Color] = [AppTheme.accent]

    var body: some View {
        Image(systemName: symbol)
            .appFont(fixedSize: 17, weight: .semibold)
            .foregroundStyle(tint)
            .frame(width: 44, height: 44)
            .background(tint.opacity(0.11), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(tint.opacity(0.12))
            }
            .accessibilityHidden(true)
    }

    private var tint: Color { colors.first ?? AppTheme.accent }
}

struct DifficultyBadge: View {
    let difficulty: ProblemDifficulty

    var body: some View {
        Text(difficulty.title)
            .appFont(.caption2, weight: .bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(color)
            .background(color.opacity(0.12), in: Capsule())
    }

    private var color: Color {
        switch difficulty {
        case .easy: .green
        case .medium: .orange
        case .hard: .pink
        }
    }
}

struct ProblemRow: View {
    let number: Int
    let problem: AlgorithmProblem
    let state: State
    let learningMode: ProblemLearningMode

    enum State {
        case solved
        case current
        case available
        case locked
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(state == .locked ? 0.08 : 0.14))
                    .frame(width: 36, height: 36)
                if state == .solved {
                    Image(systemName: "checkmark").appFont(.subheadline, weight: .bold).foregroundStyle(.green)
                } else if state == .locked {
                    Image(systemName: "lock.fill").appFont(.caption).foregroundStyle(.tertiary)
                } else {
                    Text("\(number)").appFont(.caption, weight: .bold).foregroundStyle(AppTheme.accent)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(problem.title)
                    .appFont(.subheadline, weight: .semibold)
                    .foregroundStyle(state == .locked ? .secondary : .primary)
                HStack(spacing: 7) {
                    DifficultyBadge(difficulty: problem.difficulty)
                    Label(learningMode.shortTitle, systemImage: learningMode.symbol)
                        .appFont(.caption2, weight: .semibold)
                        .foregroundStyle(learningMode == .blindAssessment ? .purple : AppTheme.accent)
                    Label("\(problem.estimatedMinutes) min", systemImage: "clock")
                        .appFont(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if state != .locked {
                HStack(spacing: 6) {
                    if state == .current {
                        Text("Suggested")
                            .appFont(.caption2, weight: .bold)
                            .foregroundStyle(AppTheme.accent)
                    }
                    Image(systemName: "chevron.right")
                        .appFont(.caption, weight: .bold)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var iconColor: Color {
        switch state {
        case .solved: .green
        case .current: AppTheme.accent
        case .available: AppTheme.accent
        case .locked: .gray
        }
    }
}

extension View {
    func appTextSizing(_ controller: AppTextSizeController) -> some View {
        modifier(AppTextSizeModifier(controller: controller))
    }

    func appFont(
        _ style: AppTextStyle,
        weight: Font.Weight? = nil,
        design: Font.Design = .default,
        monospacedDigits: Bool = false
    ) -> some View {
        modifier(
            AppFontModifier(
                style: style,
                fixedSize: nil,
                weight: weight,
                design: design,
                monospacedDigits: monospacedDigits
            )
        )
    }

    func appFont(
        fixedSize: CGFloat,
        weight: Font.Weight? = nil,
        design: Font.Design = .default,
        monospacedDigits: Bool = false
    ) -> some View {
        modifier(
            AppFontModifier(
                style: nil,
                fixedSize: fixedSize,
                weight: weight,
                design: design,
                monospacedDigits: monospacedDigits
            )
        )
    }

    func learningBackground() -> some View {
        background { AppTheme.pageBackground.ignoresSafeArea() }
    }

    func learningInset(cornerRadius: CGFloat = 12) -> some View {
        background(
            AppTheme.secondarySurface,
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }
}
