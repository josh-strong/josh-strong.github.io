import SwiftData
import XCTest

@testable import CodeStreak

@MainActor
final class CompletionServiceTests: XCTestCase {
    private let service = CompletionService()

    func testRepeatedCompletionDoesNotInsertDuplicate() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let calendar = makeCalendar()
        let date = makeDate(2026, 8, 4, calendar: calendar)

        try service.markCompleted(on: date, context: context, calendar: calendar)
        try service.markCompleted(on: date, context: context, calendar: calendar)

        let records = try context.fetch(FetchDescriptor<CompletionRecord>())
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.dayKey, "2026-08-04")
    }

    func testUndoRemovesOnlySelectedCalendarDay() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let calendar = makeCalendar()
        let yesterday = makeDate(2026, 8, 3, calendar: calendar)
        let today = makeDate(2026, 8, 4, calendar: calendar)

        try service.markCompleted(on: yesterday, context: context, calendar: calendar)
        try service.markCompleted(on: today, context: context, calendar: calendar)
        try service.removeCompletion(on: today, context: context, calendar: calendar)

        let records = try context.fetch(FetchDescriptor<CompletionRecord>())
        XCTAssertEqual(records.filter(\.isCompleted).map(\.dayKey), ["2026-08-03"])
        XCTAssertEqual(records.first(where: { $0.dayKey == "2026-08-04" })?.isCompleted, false)
    }

    func testIsCompletedIgnoresTimeOfDay() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let calendar = makeCalendar()
        let morning = makeDate(2026, 8, 4, hour: 7, calendar: calendar)
        let evening = makeDate(2026, 8, 4, hour: 22, calendar: calendar)

        try service.markCompleted(on: morning, context: context, calendar: calendar)
        let records = try context.fetch(FetchDescriptor<CompletionRecord>())

        XCTAssertTrue(service.isCompleted(on: evening, records: records, calendar: calendar))
    }

    func testMarkingAgainReactivatesTombstoneWithoutDuplicate() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let calendar = makeCalendar()
        let date = makeDate(2026, 8, 4, calendar: calendar)

        try service.markCompleted(on: date, context: context, calendar: calendar)
        try service.removeCompletion(on: date, context: context, calendar: calendar)
        try service.markCompleted(on: date, context: context, calendar: calendar)

        let records = try context.fetch(FetchDescriptor<CompletionRecord>())
        XCTAssertEqual(records.count, 1)
        XCTAssertTrue(try XCTUnwrap(records.first).isCompleted)
    }

    func testHistoricalCompletionUsesMutationTimeForSyncOrdering() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let calendar = makeCalendar()
        let historicalDate = makeDate(2020, 1, 2, calendar: calendar)
        let beforeMutation = Date()

        try service.markCompleted(on: historicalDate, context: context, calendar: calendar)
        let record = try XCTUnwrap(context.fetch(FetchDescriptor<CompletionRecord>()).first)

        XCTAssertEqual(record.completedAt, historicalDate)
        XCTAssertGreaterThanOrEqual(record.modifiedAt, beforeMutation)
    }

    private func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: CompletionRecord.self, configurations: configuration)
    }

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/London")!
        return calendar
    }

    private func makeDate(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int = 12,
        calendar: Calendar
    ) -> Date {
        try! XCTUnwrap(
            calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))
        )
    }
}
