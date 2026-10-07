import Foundation
import SwiftData

@Model
final class CompletionRecord {
    @Attribute(.unique) var dayKey: String
    var completedAt: Date
    var isCompleted: Bool = true
    var modifiedAt: Date = Date.distantPast
    var modifiedBy: String = ""

    init(
        dayKey: String,
        completedAt: Date,
        isCompleted: Bool = true,
        modifiedAt: Date? = nil,
        modifiedBy: String = ""
    ) {
        self.dayKey = dayKey
        self.completedAt = completedAt
        self.isCompleted = isCompleted
        self.modifiedAt = modifiedAt ?? completedAt
        self.modifiedBy = modifiedBy
    }
}
