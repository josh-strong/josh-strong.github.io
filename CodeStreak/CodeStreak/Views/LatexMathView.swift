import SwiftUI
import SwiftMath

/// A native, offline LaTeX formula that works on both app platforms.
/// Horizontal scrolling preserves large formulae instead of shrinking them to
/// illegibility on an iPhone.
struct LatexMathView: View {
    let latex: String
    let accessibilityDescription: String

    @Environment(\.appFontScale) private var appFontScale

    private var resolvedFontSize: CGFloat { 22 * appFontScale }

    init(latex: String, accessibilityDescription: String? = nil) {
        self.latex = latex
        self.accessibilityDescription = accessibilityDescription ?? latex
    }

    var body: some View {
        ScrollView(.horizontal) {
            PlatformLatexLabel(latex: latex, fontSize: resolvedFontSize)
                .fixedSize(horizontal: true, vertical: true)
        }
        .frame(minHeight: resolvedFontSize * 1.65)
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }
}

#if os(iOS)
private struct PlatformLatexLabel: UIViewRepresentable {
    let latex: String
    let fontSize: CGFloat

    func makeUIView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ label: MTMathUILabel, context: Context) {
        label.latex = latex
        label.fontSize = fontSize
        label.textColor = .label
        label.labelMode = .display
        label.contentInsets = UIEdgeInsets(top: 6, left: 2, bottom: 6, right: 2)
        label.invalidateIntrinsicContentSize()
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: MTMathUILabel,
        context: Context
    ) -> CGSize? {
        let intrinsic = uiView.intrinsicContentSize
        return CGSize(
            width: ceil(max(intrinsic.width, 1)),
            height: ceil(max(intrinsic.height, fontSize * 1.65))
        )
    }
}
#elseif os(macOS)
private struct PlatformLatexLabel: NSViewRepresentable {
    let latex: String
    let fontSize: CGFloat

    func makeNSView(context: Context) -> MTMathUILabel {
        let label = MTMathUILabel()
        label.wantsLayer = true
        label.layer?.backgroundColor = NSColor.clear.cgColor
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func updateNSView(_ label: MTMathUILabel, context: Context) {
        label.latex = latex
        label.fontSize = fontSize
        label.textColor = .labelColor
        label.labelMode = .display
        label.contentInsets = NSEdgeInsets(top: 6, left: 2, bottom: 6, right: 2)
        label.invalidateIntrinsicContentSize()
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: MTMathUILabel,
        context: Context
    ) -> CGSize? {
        // MTMathUILabel is an NSView on macOS. SwiftMath implements
        // `fittingSize` there, not `intrinsicContentSize`; asking for the
        // latter returns NSView.noIntrinsicMetric and collapses the equation.
        nsView.layoutSubtreeIfNeeded()
        let fitting = nsView.fittingSize
        return CGSize(
            width: ceil(max(fitting.width, 1)),
            height: ceil(max(fitting.height, fontSize * 1.65))
        )
    }
}
#endif
