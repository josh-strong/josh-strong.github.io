import Foundation
import SwiftData

@MainActor
protocol CompletionServicing {
    func isCompleted(on date: Date, records: [CompletionRecord], calendar: Calendar) -> Bool
    func markCompleted(on date: Date, context: ModelContext, calendar: Calendar) throws
    func removeCompletion(on date: Date, context: ModelContext, calendar: Calendar) throws
}

@MainActor
struct CompletionService: CompletionServicing {
    func isCompleted(
        on date: Date,
        records: [CompletionRecord],
        calendar: Calendar
    ) -> Bool {
        let key = CalendarDay(date: date, calendar: calendar).key
        return records.contains { $0.dayKey == key && $0.isCompleted }
    }

    func markCompleted(
        on date: Date,
        context: ModelContext,
        calendar: Calendar
    ) throws {
        let dayKey = CalendarDay(date: date, calendar: calendar).key
        let mutationDate = Date()
        var descriptor = FetchDescriptor<CompletionRecord>(
            predicate: #Predicate { $0.dayKey == dayKey }
        )
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            guard !existing.isCompleted else { return }
            existing.completedAt = date
            existing.isCompleted = true
            existing.modifiedAt = mutationDate
            existing.modifiedBy = DeviceIdentity.id
        } else {
            context.insert(
                CompletionRecord(
                    dayKey: dayKey,
                    completedAt: date,
                    modifiedAt: mutationDate,
                    modifiedBy: DeviceIdentity.id
                )
            )
        }
        do {
            try context.save()
            WidgetProgressExporter.refresh(context: context, now: mutationDate)
        } catch {
            context.rollback()
            throw error
        }
    }

    func removeCompletion(
        on date: Date,
        context: ModelContext,
        calendar: Calendar
    ) throws {
        let dayKey = CalendarDay(date: date, calendar: calendar).key
        let mutationDate = Date()
        let descriptor = FetchDescriptor<CompletionRecord>(
            predicate: #Predicate { $0.dayKey == dayKey }
        )

        let records = try context.fetch(descriptor)
        guard !records.isEmpty else { return }

        for record in records {
            record.isCompleted = false
            record.modifiedAt = mutationDate
            record.modifiedBy = DeviceIdentity.id
        }
        do {
            try context.save()
            WidgetProgressExporter.refresh(context: context, now: mutationDate)
        } catch {
            context.rollback()
            throw error
        }
    }
}

@MainActor
enum DeviceIdentity {
    private static let identifierKey = "nearbySyncDeviceIdentifier"

    static var id: String {
        if let existing = UserDefaults.standard.string(forKey: identifierKey) {
            return existing
        }

        let identifier = UUID().uuidString.lowercased()
        UserDefaults.standard.set(identifier, forKey: identifierKey)
        return identifier
    }
}
