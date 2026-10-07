import SwiftUI

struct CompletionButton: View {
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(
                isCompleted ? "Completed today" : "Complete 15 minutes today",
                systemImage: isCompleted ? "checkmark.circle.fill" : "circle"
            )
            .appFont(.headline)
            .frame(maxWidth: .infinity, minHeight: 34)
            .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isCompleted)
        .accessibilityHint(
            isCompleted
                ? "Today’s practice is recorded"
                : "Marks today’s LeetCode practice complete"
        )
    }
}
