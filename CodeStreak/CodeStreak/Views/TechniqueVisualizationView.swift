import SwiftUI

struct TechniqueVisualizationView: View {
    let technique: AlgorithmTechnique

    var body: some View {
        if let spec = technique.visualization {
            VStack(alignment: .leading, spacing: 11) {
                Label("Picture the invariant", systemImage: "square.3.layers.3d.top.filled")
                    .appFont(.caption, weight: .bold)
                    .foregroundStyle(AppTheme.accent)

                Text(spec.title)
                    .appFont(.subheadline, weight: .semibold)

                TechniqueDiagram(kind: spec.kind)
                    .frame(maxWidth: .infinity)

                Label(spec.takeaway, systemImage: "eye.fill")
                    .appFont(.footnote, weight: .medium)
                    .foregroundStyle(.secondary)
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.accent.opacity(0.055), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(AppTheme.accent.opacity(0.14))
            }
            .accessibilityElement(children: .contain)
        }
    }
}

private struct TechniqueDiagram: View {
    let kind: TechniqueVisualKind

    @ViewBuilder
    var body: some View {
        switch kind {
        case .sequence(let cells):
            SequenceDiagram(cells: cells)
        case .flow(let stages):
            FlowDiagram(stages: stages)
        case .stack(let cells, let isQueue):
            StackQueueDiagram(cells: cells, isQueue: isQueue)
        case .graph(let nodes, let edges):
            GraphDiagram(nodes: nodes, edges: edges)
        case .intervals(let intervals):
            IntervalDiagram(intervals: intervals)
        case .matrix(let rows):
            MatrixDiagram(rows: rows)
        }
    }
}

private struct SequenceDiagram: View {
    let cells: [TechniqueVisualCell]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 5) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                    VisualCell(cell: cell)
                }
            }
            .padding(.horizontal, 1)
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel(cells.map { [$0.label, $0.note].compactMap { $0 }.joined(separator: ", ") }.joined(separator: "; "))
    }
}

private struct FlowDiagram: View {
    let stages: [TechniqueVisualStage]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(Array(stages.enumerated()), id: \.offset) { index, stage in
                    VStack(spacing: 3) {
                        Text(stage.label)
                            .appFont(.caption, weight: .bold)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        if let detail = stage.detail {
                            Text(detail)
                                .appFont(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(minWidth: 72, minHeight: 48)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 6)
                    .background(stage.role.softFill, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(stage.role.stroke, lineWidth: stage.role == .neutral ? 1 : 1.5)
                    }

                    if index < stages.count - 1 {
                        Image(systemName: "arrow.right")
                            .appFont(.caption, weight: .bold)
                            .foregroundStyle(AppTheme.accent)
                            .accessibilityHidden(true)
                    }
                }
            }
            .padding(.horizontal, 1)
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel(stages.map { [$0.label, $0.detail].compactMap { $0 }.joined(separator: ", ") }.joined(separator: " then "))
    }
}

private struct StackQueueDiagram: View {
    let cells: [TechniqueVisualCell]
    let isQueue: Bool

    @ViewBuilder
    var body: some View {
        if isQueue {
            HStack(spacing: 6) {
                Image(systemName: "arrow.left")
                    .foregroundStyle(AppTheme.accent)
                    .accessibilityHidden(true)
                ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                    VisualCell(cell: cell, compact: true)
                }
                Image(systemName: "arrow.left")
                    .foregroundStyle(AppTheme.accent)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Queue from front to back: \(cells.map(\.label).joined(separator: ", "))")
        } else {
            HStack(alignment: .center, spacing: 14) {
                VStack(spacing: 4) {
                    Text("TOP")
                        .appFont(.caption2, weight: .bold)
                        .foregroundStyle(AppTheme.accent)
                    ForEach(Array(cells.reversed().enumerated()), id: \.offset) { _, cell in
                        VisualCell(cell: cell, compact: true)
                    }
                    Rectangle()
                        .fill(Color.secondary.opacity(0.45))
                        .frame(width: 88, height: 2)
                }

                Image(systemName: "arrow.down")
                    .appFont(.title3, weight: .semibold)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Stack from bottom to top: \(cells.map(\.label).joined(separator: ", "))")
        }
    }
}

private struct GraphDiagram: View {
    let nodes: [TechniqueVisualNode]
    let edges: [TechniqueVisualEdge]

    @Environment(\.appFontScale) private var appFontScale

    var body: some View {
        Canvas { context, size in
            let nodeHeight = min(38 * appFontScale, 49)
            let widthForLabel: (String) -> CGFloat = { label in
                min(max(42 * appFontScale, CGFloat(label.count) * 6.6 * appFontScale + 15), 88)
            }
            let sizeByID = Dictionary(uniqueKeysWithValues: nodes.map { node in
                (node.id, CGSize(width: widthForLabel(node.label), height: nodeHeight))
            })
            let pointByID = Dictionary(uniqueKeysWithValues: nodes.map { node in
                let nodeSize = sizeByID[node.id] ?? CGSize(width: nodeHeight, height: nodeHeight)
                let halfWidth = nodeSize.width / 2 + 2
                let halfHeight = nodeSize.height / 2 + 2
                return (
                    node.id,
                    CGPoint(
                        x: min(max(node.x * size.width, halfWidth), size.width - halfWidth),
                        y: min(max(node.y * size.height, halfHeight), size.height - halfHeight)
                    )
                )
            })

            for edge in edges {
                guard let start = pointByID[edge.from], let end = pointByID[edge.to] else { continue }
                let vector = CGVector(dx: end.x - start.x, dy: end.y - start.y)
                let length = max(hypot(vector.dx, vector.dy), 1)
                let unit = CGVector(dx: vector.dx / length, dy: vector.dy / length)
                let fromSize = sizeByID[edge.from] ?? CGSize(width: nodeHeight, height: nodeHeight)
                let toSize = sizeByID[edge.to] ?? CGSize(width: nodeHeight, height: nodeHeight)
                let startInset = capsuleEdgeInset(size: fromSize, direction: unit)
                let endInset = capsuleEdgeInset(size: toSize, direction: unit)
                let lineStart = CGPoint(x: start.x + unit.dx * startInset, y: start.y + unit.dy * startInset)
                let lineEnd = CGPoint(x: end.x - unit.dx * endInset, y: end.y - unit.dy * endInset)

                var path = Path()
                path.move(to: lineStart)
                path.addLine(to: lineEnd)
                context.stroke(path, with: .color(edge.role.stroke), lineWidth: edge.role == .neutral ? 1.5 : 2.3)

                if edge.isDirected {
                    let arrowLength: CGFloat = 7
                    let perpendicular = CGVector(dx: -unit.dy, dy: unit.dx)
                    var arrow = Path()
                    arrow.move(to: lineEnd)
                    arrow.addLine(to: CGPoint(
                        x: lineEnd.x - unit.dx * arrowLength + perpendicular.dx * 4,
                        y: lineEnd.y - unit.dy * arrowLength + perpendicular.dy * 4
                    ))
                    arrow.move(to: lineEnd)
                    arrow.addLine(to: CGPoint(
                        x: lineEnd.x - unit.dx * arrowLength - perpendicular.dx * 4,
                        y: lineEnd.y - unit.dy * arrowLength - perpendicular.dy * 4
                    ))
                    context.stroke(arrow, with: .color(edge.role.stroke), lineWidth: 1.7)
                }

                if let label = edge.label {
                    let midpoint = CGPoint(
                        x: (lineStart.x + lineEnd.x) / 2,
                        y: (lineStart.y + lineEnd.y) / 2 - 9
                    )
                    context.draw(
                        context.resolve(
                            Text(label)
                                .font(.system(size: min(10 * appFontScale, 14), weight: .medium))
                                .foregroundStyle(edge.role.stroke)
                        ),
                        at: midpoint,
                        anchor: .center
                    )
                }
            }

            for node in nodes {
                guard let center = pointByID[node.id] else { continue }
                let nodeSize = sizeByID[node.id] ?? CGSize(width: nodeHeight, height: nodeHeight)
                let rect = CGRect(
                    x: center.x - nodeSize.width / 2,
                    y: center.y - nodeSize.height / 2,
                    width: nodeSize.width,
                    height: nodeSize.height
                )
                let nodePath = Path(roundedRect: rect, cornerRadius: nodeSize.height / 2)
                context.fill(nodePath, with: .color(node.role.softFill))
                context.stroke(
                    nodePath,
                    with: .color(node.role.stroke),
                    lineWidth: node.role == .neutral ? 1.3 : 2
                )
                context.draw(
                    context.resolve(
                        Text(node.label)
                            .font(.system(size: min(11 * appFontScale, 15), weight: .semibold))
                            .foregroundStyle(node.role.foreground)
                    ),
                    at: center,
                    anchor: .center
                )
            }
        }
        .frame(height: 176 * min(appFontScale, 1.3))
        .accessibilityLabel(
            "Nodes: \(nodes.map(\.label).joined(separator: ", ")). Connections: " +
            edges.map { "\($0.from) to \($0.to)\($0.label.map { ", \($0)" } ?? "")" }.joined(separator: "; ")
        )
    }

    /// Finds where a center-to-center edge meets the boundary of a capsule.
    /// This keeps arrows out of both short circular and longer labelled nodes.
    private func capsuleEdgeInset(size: CGSize, direction: CGVector) -> CGFloat {
        let horizontal = abs(direction.dx) / max(size.width / 2, 1)
        let vertical = abs(direction.dy) / max(size.height / 2, 1)
        return 1 / max(horizontal, vertical, 0.001)
    }
}

private struct IntervalDiagram: View {
    let intervals: [TechniqueVisualInterval]

    var body: some View {
        VStack(spacing: 7) {
            ForEach(intervals) { interval in
                HStack(spacing: 8) {
                    Text(interval.label)
                        .appFont(.caption2, weight: .semibold)
                        .foregroundStyle(interval.role.foreground)
                        .frame(width: 68, alignment: .trailing)

                    GeometryReader { proxy in
                        let width = proxy.size.width
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.secondary.opacity(0.12))
                                .frame(height: 3)
                            Capsule()
                                .fill(interval.role.stroke)
                                .frame(
                                    width: max((interval.end - interval.start) * width, 4),
                                    height: 13
                                )
                                .offset(x: interval.start * width)
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .frame(height: 18)
                }
            }
        }
        .accessibilityLabel(intervals.map { "\($0.label), from \($0.start) to \($0.end)" }.joined(separator: "; "))
    }
}

private struct MatrixDiagram: View {
    let rows: [[TechniqueVisualCell]]

    var body: some View {
        ScrollView(.horizontal) {
            VStack(spacing: 4) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 4) {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                            VisualCell(cell: cell, compact: true)
                        }
                    }
                }
            }
            .padding(.horizontal, 1)
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel(rows.flatMap { $0 }.map(\.label).joined(separator: ", "))
    }
}

private struct VisualCell: View {
    let cell: TechniqueVisualCell
    var compact = false

    var body: some View {
        VStack(spacing: 3) {
            Text(cell.label)
                .appFont(compact ? .caption : .footnote, weight: .bold)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            if let note = cell.note {
                Text(note)
                    .appFont(.caption2, weight: .medium)
                    .foregroundStyle(cell.role.foreground)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(minWidth: compact ? 52 : 58, minHeight: compact ? 34 : 44)
        .padding(.horizontal, compact ? 5 : 7)
        .padding(.vertical, 5)
        .background(cell.role.softFill, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(cell.role.stroke, lineWidth: cell.role == .neutral ? 1 : 1.5)
        }
    }
}

private extension TechniqueVisualRole {
    var stroke: Color {
        switch self {
        case .neutral: .secondary.opacity(0.38)
        case .active: AppTheme.accent
        case .candidate: .orange
        case .resolved: .green
        case .warning: .red.opacity(0.82)
        }
    }

    var softFill: Color {
        switch self {
        case .neutral: .secondary.opacity(0.075)
        case .active: AppTheme.accent.opacity(0.15)
        case .candidate: .orange.opacity(0.14)
        case .resolved: .green.opacity(0.13)
        case .warning: .red.opacity(0.12)
        }
    }

    var foreground: Color {
        switch self {
        case .neutral: .primary
        case .active: AppTheme.accent
        case .candidate: .orange
        case .resolved: .green
        case .warning: .red
        }
    }
}
