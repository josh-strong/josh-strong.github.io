import XCTest

@testable import CodeStreak

final class PythonRunnerTests: XCTestCase {
    func testEveryAnnotatedReferenceSolutionPassesEveryBuiltInTest() {
        for problem in Curriculum.allProblems {
            let report = PythonRunner.execute(problem: problem, source: problem.annotatedReferenceSolution)
            XCTAssertNil(report.errorMessage, "\(problem.id): \(report.errorMessage ?? "")")
            XCTAssertTrue(
                report.allPassed,
                "\(problem.id): \(report.results.filter { $0.outcome != .passed })"
            )
        }
    }

    func testNestedFloatingPointResultsUseATightRelativeTolerance() throws {
        let problem = try XCTUnwrap(Curriculum.problem(withID: "ml.stable-softmax"))
        let equivalentSource = """
        def stable_softmax(logits):
            import math
            maximum = max(logits)
            values = [math.exp(value - maximum) for value in logits]
            probabilities = [value / sum(values) for value in values]
            probabilities[0] += 0.00000005
            probabilities[-1] -= 0.00000005
            return probabilities
        """

        let report = PythonRunner.execute(problem: problem, source: equivalentSource)

        XCTAssertNil(report.errorMessage)
        XCTAssertTrue(report.allPassed)
    }

    func testMostFrequentValuesRejectsSortingCounterKeysByValue() throws {
        let problem = try XCTUnwrap(Curriculum.problem(withID: "arrays.top-frequent"))
        let source = """
        from collections import Counter
        def top_frequent(numbers, k):
            counter = list(sorted(Counter(numbers)))
            return counter[:k]
        """

        let report = PythonRunner.execute(problem: problem, source: source)

        XCTAssertFalse(report.allPassed)
        let challenge = try XCTUnwrap(report.results.first { $0.name.contains("Challenge") })
        XCTAssertEqual(challenge.outcome, .failed)
        XCTAssertTrue(challenge.input.contains("9"))
        XCTAssertEqual(challenge.expected, "[\n  9,\n  2\n]")
        XCTAssertEqual(challenge.actual, "[\n  1,\n  2\n]")
    }

    func testEveryExecutableAlternativePassesEveryBuiltInTest() {
        for problem in Curriculum.allProblems {
            for alternative in problem.solutionAlternatives {
                guard let code = alternative.code else { continue }

                let report = PythonRunner.execute(problem: problem, source: code)
                XCTAssertNil(
                    report.errorMessage,
                    "\(problem.id) / \(alternative.id): \(report.errorMessage ?? "")"
                )
                XCTAssertTrue(
                    report.allPassed,
                    "\(problem.id) / \(alternative.id): \(report.results.filter { $0.outcome != .passed })"
                )
            }
        }
    }

    func testSyntaxErrorIsReportedWithoutCrashing() throws {
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let report = PythonRunner.execute(problem: problem, source: "def broken(:\n    pass")

        XCTAssertFalse(report.allPassed)
        XCTAssertNotNil(report.errorMessage)
    }

    func testScratchpadCapturesPrintedOutputWithoutRunningProblemTests() {
        let report = PythonRunner.executeScratchpad(
            source: "values = [3, 1, 2]\nprint(sorted(values))\nprint(sum(values))"
        )

        XCTAssertTrue(report.succeeded, report.errorMessage ?? "")
        XCTAssertTrue(report.output.contains("[1, 2, 3]"))
        XCTAssertTrue(report.output.contains("6"))
    }

    func testScratchpadCapturesACommentFollowedByPrint() {
        let report = PythonRunner.executeScratchpad(
            source: "# Experiment here without running the problem tests.\nprint(\"wadadadada\")"
        )

        XCTAssertTrue(report.succeeded, report.errorMessage ?? "")
        XCTAssertEqual(report.output, "wadadadada\n")
    }

    func testScratchpadPreservesPrintedOutputBeforeAPythonError() {
        let report = PythonRunner.executeScratchpad(
            source: "print('before error')\nprint(1 / 0)"
        )

        XCTAssertFalse(report.succeeded)
        XCTAssertTrue(report.output.contains("before error"))
        XCTAssertTrue(report.errorMessage?.contains("ZeroDivisionError") == true)
    }

    func testDebugPrintInsideSubmittedFunctionDoesNotBreakItsReturnValue() throws {
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let report = PythonRunner.execute(
            problem: problem,
            source: "def \(problem.functionName)(numbers):\n    print(numbers)\n    return sum(n for n in numbers if n > 0)"
        )

        XCTAssertNil(report.errorMessage)
        XCTAssertTrue(report.allPassed)
    }

    func testWrongAnswerShowsExpectedAndActualValues() throws {
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let report = PythonRunner.execute(
            problem: problem,
            source: "def \(problem.functionName)(numbers):\n    return 999"
        )

        XCTAssertNil(report.errorMessage)
        XCTAssertEqual(report.results.first?.outcome, .failed)
        XCTAssertEqual(report.results.first?.actual, "999")
        XCTAssertTrue(report.results.first?.input.contains("numbers =") == true)
    }

    func testTargetPairFailureShowsEveryNamedInput() throws {
        let problem = try XCTUnwrap(Curriculum.problem(withID: "arrays.pair-indices"))
        let report = PythonRunner.execute(
            problem: problem,
            source: "def \(problem.functionName)(numbers, target):\n    return [-1, -1]"
        )

        let first = try XCTUnwrap(report.results.first)
        XCTAssertEqual(first.outcome, .failed)
        XCTAssertTrue(first.input.contains("numbers ="))
        XCTAssertTrue(first.input.contains("4"))
        XCTAssertTrue(first.input.contains("target = 11"))
        XCTAssertEqual(first.expected, "[\n  0,\n  1\n]")
        XCTAssertEqual(first.actual, "[\n  -1,\n  -1\n]")
    }

    func testTargetPairRejectsAWholeArrayLookupThatReusesTheCurrentIndex() throws {
        let problem = try XCTUnwrap(Curriculum.problem(withID: "arrays.pair-indices"))
        let unsafeSource = """
        def pair_indices(numbers, target):
            positions = {number: index for index, number in enumerate(numbers)}
            for index, number in enumerate(numbers):
                complement = target - number
                if complement in positions:
                    return [index, positions[complement]]
            return [-1, -1]
        """

        let report = PythonRunner.execute(problem: problem, source: unsafeSource)
        let sameIndexResult = try XCTUnwrap(report.results.first {
            $0.name == "same-index match is forbidden before a real pair"
        })

        XCTAssertEqual(sameIndexResult.outcome, .failed)
        XCTAssertEqual(sameIndexResult.expected, "[\n  1,\n  2\n]")
        XCTAssertEqual(sameIndexResult.actual, "[\n  0,\n  0\n]")
        XCTAssertFalse(report.allPassed)
    }

    func testSortedTargetPairRejectsPointersThatAreAllowedToMeet() throws {
        let problem = try XCTUnwrap(Curriculum.problem(withID: "pointers.sorted-pair"))
        let unsafeSource = """
        def sorted_pair(numbers, target):
            left, right = 0, len(numbers) - 1
            while left <= right:
                total = numbers[left] + numbers[right]
                if total == target:
                    return [left, right]
                if total < target:
                    left += 1
                else:
                    right -= 1
            return [-1, -1]
        """

        let report = PythonRunner.execute(problem: problem, source: unsafeSource)
        let meetingPointersResult = try XCTUnwrap(report.results.first {
            $0.name == "pointers must not meet at one half-target"
        })

        XCTAssertEqual(meetingPointersResult.outcome, .failed)
        XCTAssertEqual(meetingPointersResult.expected, "[\n  -1,\n  -1\n]")
        XCTAssertEqual(meetingPointersResult.actual, "[\n  1,\n  1\n]")
        XCTAssertFalse(report.allPassed)
    }

    func testChatGPTHandoffIncludesProblemDraftQuestionAndFailedEvidence() throws {
        let problem = try XCTUnwrap(Curriculum.problem(withID: "arrays.pair-indices"))
        let draft = "def \(problem.functionName)(numbers, target):\n    return [-1, -1]"
        let report = PythonRunner.execute(problem: problem, source: draft)

        let prompt = ChatGPTHandoffBuilder.prompt(
            problem: problem,
            draftCode: draft,
            notes: "Remember the complement.",
            includeNotes: false,
            report: report,
            question: "Why does my first check fail?"
        )

        XCTAssertTrue(prompt.contains(problem.title))
        XCTAssertTrue(prompt.contains(problem.prompt))
        XCTAssertTrue(prompt.contains(draft))
        XCTAssertTrue(prompt.contains("numbers ="))
        XCTAssertTrue(prompt.contains("target = 11"))
        XCTAssertTrue(prompt.contains("Expected return:"))
        XCTAssertTrue(prompt.contains("My return value:"))
        XCTAssertTrue(prompt.contains("Why does my first check fail?"))
        XCTAssertTrue(prompt.contains("Socratic Python tutor"))
        XCTAssertFalse(prompt.contains("Remember the complement."))
        XCTAssertFalse(prompt.contains(problem.referenceSolution))
    }

    func testChatGPTHandoffIncludesNotesOnlyWhenRequested() throws {
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let note = "I may be resetting the pointer too early."

        let withoutNotes = ChatGPTHandoffBuilder.prompt(
            problem: problem,
            draftCode: problem.starterCode,
            notes: note,
            includeNotes: false,
            report: nil,
            question: ""
        )
        let withNotes = ChatGPTHandoffBuilder.prompt(
            problem: problem,
            draftCode: problem.starterCode,
            notes: note,
            includeNotes: true,
            report: nil,
            question: ""
        )

        XCTAssertFalse(withoutNotes.contains(note))
        XCTAssertTrue(withNotes.contains(note))
        XCTAssertTrue(withoutNotes.contains(ChatGPTHandoffBuilder.defaultQuestion))
        XCTAssertTrue(withoutNotes.contains("I have not run the built-in tests in this session."))
    }

    func testChatGPTHandoffSummarizesPassingRun() throws {
        let problem = try XCTUnwrap(Curriculum.allProblems.first)
        let report = PythonRunner.execute(problem: problem, source: problem.referenceSolution)

        let prompt = ChatGPTHandoffBuilder.prompt(
            problem: problem,
            draftCode: problem.referenceSolution,
            notes: "",
            includeNotes: false,
            report: report,
            question: "Can this be simpler?"
        )

        XCTAssertTrue(prompt.contains("All \(problem.validationTests.count) built-in tests passed."))
        XCTAssertTrue(prompt.contains("Can this be simpler?"))
    }
}

final class PythonEditingTests: XCTestCase {
    func testPythonReferenceViewerHeightUsesLineCountAndCapsLongSolutions() {
        let shortSource = "def solve():\n    return 1"
        let mediumSource = (1...12).map { "value_\($0) = \($0)" }.joined(separator: "\n")
        let longSource = (1...80).map { "value_\($0) = \($0)" }.joined(separator: "\n")

        XCTAssertEqual(PythonLineNumbers.count(in: shortSource), 2)
        XCTAssertEqual(PythonLineNumbers.count(in: mediumSource), 12)
        XCTAssertEqual(PythonLineNumbers.count(in: longSource), 80)

        let shortHeight = PythonCodeViewerLayout.height(for: shortSource, fontSize: 14)
        let mediumHeight = PythonCodeViewerLayout.height(for: mediumSource, fontSize: 14)
        let longHeight = PythonCodeViewerLayout.height(for: longSource, fontSize: 14)

        XCTAssertGreaterThanOrEqual(shortHeight, 170)
        XCTAssertGreaterThan(mediumHeight, shortHeight)
        XCTAssertGreaterThan(longHeight, mediumHeight)
        XCTAssertLessThanOrEqual(longHeight, 520)
    }

    func testLineNumbersIncludeEmptyAndTrailingLinesUsingUTF16Offsets() {
        XCTAssertEqual(PythonLineNumbers.utf16LineStarts(in: ""), [0])
        XCTAssertEqual(PythonLineNumbers.count(in: "print('one')"), 1)
        XCTAssertEqual(PythonLineNumbers.utf16LineStarts(in: "🐍 = 1\nprint(🐍)\n"), [0, 7, 17])
        XCTAssertEqual(PythonLineNumbers.count(in: "first\n\nthird\n"), 4)
    }

    func testReturnIndentsAfterAColonBeforeAnInlineComment() {
        let source = "def solve():  # entry point"
        let edit = PythonEditing.newlineEdit(
            in: source,
            replacing: NSRange(location: source.utf16.count, length: 0)
        )

        XCTAssertEqual(applying(edit, to: source), source + "\n    ")
        XCTAssertEqual(edit.selectedRange.location, (source + "\n    ").utf16.count)
    }

    func testCommentEndingInAColonDoesNotOpenABlock() {
        let source = "# remember this:"
        let edit = PythonEditing.newlineEdit(
            in: source,
            replacing: NSRange(location: source.utf16.count, length: 0)
        )

        XCTAssertEqual(applying(edit, to: source), source + "\n")
    }

    func testReturnIndentsAnUnfinishedCollectionEvenAfterAnItem() {
        let source = "values = [1,"
        let edit = PythonEditing.newlineEdit(
            in: source,
            replacing: NSRange(location: source.utf16.count, length: 0)
        )

        XCTAssertEqual(applying(edit, to: source), source + "\n    ")
    }

    func testReturnOnWhitespaceOnlyLineClearsHiddenIndentation() {
        let source = "if ready:\n    "
        let edit = PythonEditing.newlineEdit(
            in: source,
            replacing: NSRange(location: source.utf16.count, length: 0)
        )

        XCTAssertEqual(applying(edit, to: source), "if ready:\n\n")
        XCTAssertEqual(edit.selectedRange, NSRange(location: "if ready:\n\n".utf16.count, length: 0))
    }

    func testTabUsesSpacesToReachTheNextFourColumnStop() throws {
        let source = "  return value"
        let edit = try XCTUnwrap(PythonEditing.indentationEdit(
            in: source,
            selection: NSRange(location: 2, length: 0),
            outdent: false
        ))

        XCTAssertEqual(applying(edit, to: source), "    return value")
        XCTAssertEqual(edit.selectedRange, NSRange(location: 4, length: 0))
    }

    func testSelectedLinesIndentAndOutdentTogether() throws {
        let source = "first\nsecond\nthird"
        let selection = NSRange(location: 0, length: "first\nsecond".utf16.count)
        let indent = try XCTUnwrap(PythonEditing.indentationEdit(
            in: source,
            selection: selection,
            outdent: false
        ))
        let indented = applying(indent, to: source)

        XCTAssertEqual(indented, "    first\n    second\nthird")

        let outdent = try XCTUnwrap(PythonEditing.indentationEdit(
            in: indented,
            selection: indent.selectedRange,
            outdent: true
        ))
        XCTAssertEqual(applying(outdent, to: indented), source)
    }

    func testClosingBracketAndBackspaceRemoveOneIndentationLevel() throws {
        let closingSource = "values = [\n    "
        let closing = try XCTUnwrap(PythonEditing.closingDelimiterEdit(
            in: closingSource,
            selection: NSRange(location: closingSource.utf16.count, length: 0),
            replacement: "]"
        ))
        XCTAssertEqual(applying(closing, to: closingSource), "values = [\n]")

        let deletionSource = "if ready:\n        "
        let deletion = try XCTUnwrap(PythonEditing.backwardDeletionEdit(
            in: deletionSource,
            selection: NSRange(location: deletionSource.utf16.count, length: 0)
        ))
        XCTAssertEqual(applying(deletion, to: deletionSource), "if ready:\n    ")
    }

    private func applying(_ edit: PythonTextEdit, to source: String) -> String {
        let value = NSMutableString(string: source)
        value.replaceCharacters(in: edit.range, with: edit.replacement)
        return value as String
    }
}
