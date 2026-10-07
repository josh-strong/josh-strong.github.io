import Foundation
@preconcurrency import JavaScriptCore

struct PythonTestResult: Identifiable, Equatable, Sendable {
    enum Outcome: Equatable, Sendable {
        case passed
        case failed
        case error
    }

    let id: Int
    let name: String
    let outcome: Outcome
    let input: String
    let expected: String
    let actual: String
    let message: String?
}

struct PythonRunReport: Equatable, Sendable {
    let results: [PythonTestResult]
    let errorMessage: String?
    let elapsedMilliseconds: Int

    var passedCount: Int { results.filter { $0.outcome == .passed }.count }
    var allPassed: Bool { errorMessage == nil && !results.isEmpty && passedCount == results.count }
}

struct PythonScratchpadReport: Equatable, Sendable {
    let output: String
    let errorMessage: String?
    let elapsedMilliseconds: Int

    var succeeded: Bool { errorMessage == nil }
}

enum PythonScratchpad {
    static let starterCode = """
    # Experiment here without running the problem tests.
    values = [3, 1, 2]
    print(values)
    """
}

struct ChatGPTHandoffBuilder {
    static let defaultQuestion = "Please review my approach, identify the first issue or weakness, and guide me with one question at a time."

    static func prompt(
        problem: AlgorithmProblem,
        draftCode: String,
        notes: String,
        includeNotes: Bool,
        report: PythonRunReport?,
        question: String
    ) -> String {
        let trimmedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDraft = draftCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let functionSignature = problem.starterCode
            .split(separator: "\n", omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? "def \(problem.functionName)(...):"

        var sections = [
            """
            I am learning data structures and algorithms in CodeStreak. Act as a Socratic Python tutor, not an answer generator.

            Respond to my question below. Unless I explicitly ask for a complete solution, begin with the most important diagnosis and one guiding question or small hint. Do not immediately replace my code with the final answer. Separate correctness, edge cases, time/space complexity, and Python-specific behaviour when they matter. Ground your feedback in the exact function contract and test evidence below.
            """,
            """
            ## Problem
            **\(problem.title)** · \(problem.difficulty.title)

            \(problem.prompt)

            Function contract: `\(functionSignature)`
            """
        ]

        if !problem.constraints.isEmpty {
            sections.append("## Constraints\n" + problem.constraints.map { "- \($0)" }.joined(separator: "\n"))
        }

        sections.append(
            """
            ## My current Python draft
            ```python
            \(trimmedDraft.isEmpty ? "# No draft yet" : trimmedDraft)
            ```
            """
        )

        sections.append("## Built-in test evidence\n\(testEvidence(from: report))")

        if includeNotes, !trimmedNotes.isEmpty {
            sections.append("## My learning notes\n\(trimmedNotes)")
        }

        sections.append("## My question\n\(trimmedQuestion.isEmpty ? defaultQuestion : trimmedQuestion)")
        return sections.joined(separator: "\n\n")
    }

    private static func testEvidence(from report: PythonRunReport?) -> String {
        guard let report else {
            return "I have not run the built-in tests in this session."
        }

        if let errorMessage = report.errorMessage {
            return "The runner stopped before completing the tests:\n```text\n\(errorMessage)\n```"
        }

        if report.allPassed {
            return "All \(report.results.count) built-in tests passed. Please still inspect the reasoning, edge cases, and complexity."
        }

        let unsuccessful = report.results.filter { $0.outcome != .passed }
        var evidence = "\(report.passedCount) of \(report.results.count) built-in tests passed. Here are the failed or errored checks:"

        for result in unsuccessful {
            evidence += """


            ### \(result.name)
            Input:
            ```text
            \(result.input)
            ```
            Expected return:
            ```text
            \(result.expected)
            ```
            My return value:
            ```text
            \(result.actual)
            ```
            """
            if let message = result.message, !message.isEmpty {
                evidence += "\nRunner note: \(message)"
            }
        }

        return evidence
    }
}

enum PythonRunnerError: LocalizedError {
    case sourceTooLarge
    case runtimeMissing
    case runtimeUnavailable
    case invalidHarnessResult

    var errorDescription: String? {
        switch self {
        case .sourceTooLarge: "The Python code is too large to run safely. Keep it below 50,000 characters."
        case .runtimeMissing: "The bundled offline Python runtime is missing from this build."
        case .runtimeUnavailable: "The on-device Python runtime could not start."
        case .invalidHarnessResult: "The Python test runner returned an unreadable result."
        }
    }
}

final class PythonRunner: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.codestreak.python-runner", qos: .userInitiated)

    func run(problem: AlgorithmProblem, source: String) async -> PythonRunReport {
        await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: Self.execute(problem: problem, source: source))
            }
        }
    }

    func runScratchpad(source: String) async -> PythonScratchpadReport {
        await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: Self.executeScratchpad(source: source))
            }
        }
    }

    static func execute(problem: AlgorithmProblem, source: String) -> PythonRunReport {
        let started = ContinuousClock.now

        do {
            guard source.count <= 50_000 else { throw PythonRunnerError.sourceTooLarge }
            guard let context = JSContext() else { throw PythonRunnerError.runtimeUnavailable }
            let validationTests = problem.validationTests

            var contextException: String?
            context.exceptionHandler = { _, exception in
                contextException = exception?.toString()
            }

            for resource in ["skulpt.min", "skulpt-stdlib"] {
                context.evaluateScript(try runtimeSource(named: resource))
                if let contextException { throw RunnerMessageError(message: contextException) }
            }

            let payload = try HarnessPayload(
                functionName: problem.functionName,
                source: source,
                referenceSource: problem.referenceSolution,
                tests: validationTests
            ).jsonLiteral()

            context.evaluateScript("""
            var __codestreakDone = false;
            var __codestreakFatal = null;
            var __codestreakResults = [];
            var __codestreakReferenceResults = [];
            function __codestreakRead(path) {
              if (Sk.builtinFiles === undefined || Sk.builtinFiles["files"][path] === undefined) {
                throw "Module not available offline: " + path;
              }
              return Sk.builtinFiles["files"][path];
            }
            var __codestreakPayload = \(payload);
            Sk.configure({
              // Debug prints are allowed in a submitted function, but test
              // correctness is based on its return value. Discard stdout here;
              // the dedicated scratchpad captures and displays it instead.
              output: function(text) {},
              read: __codestreakRead,
              __future__: Sk.python3,
              execLimit: 2500,
              yieldLimit: null
            });
            function __codestreakCall(fn, test) {
              var pythonArguments = Sk.ffi.remapToPy(test.arguments);
              var pythonResult = Sk.misceval.callsimArray(fn, pythonArguments.v);
              if (pythonResult && pythonResult.$isSuspension) {
                throw new Error("Async Python is not supported in algorithm tests.");
              }
              return Sk.ffi.remapToJs(pythonResult);
            }
            Sk.misceval.asyncToPromise(function() {
              return Sk.importMainWithBody("codestreak_reference", false, __codestreakPayload.referenceSource, true);
            }).then(function(referenceModule) {
              var referenceFn = referenceModule.$d[__codestreakPayload.functionName];
              if (referenceFn === undefined) {
                throw new Error("CodeStreak's reference function is missing.");
              }
              for (var i = 0; i < __codestreakPayload.tests.length; i++) {
                var referenceTest = __codestreakPayload.tests[i];
                if (!referenceTest.derivesExpectedFromReference) {
                  __codestreakReferenceResults.push({ expected: null, error: null });
                  continue;
                }
                try {
                  __codestreakReferenceResults.push({
                    expected: __codestreakCall(referenceFn, referenceTest),
                    error: null
                  });
                } catch (error) {
                  __codestreakReferenceResults.push({ expected: null, error: error.toString() });
                }
              }
              return Sk.misceval.asyncToPromise(function() {
                return Sk.importMainWithBody("codestreak_user", false, __codestreakPayload.source, true);
              });
            }).then(function(module) {
              var fn = module.$d[__codestreakPayload.functionName];
              if (fn === undefined) {
                throw new Error("Define a function named " + __codestreakPayload.functionName + " before running tests.");
              }
              for (var i = 0; i < __codestreakPayload.tests.length; i++) {
                var test = __codestreakPayload.tests[i];
                try {
                  __codestreakResults.push({
                    actual: __codestreakCall(fn, test),
                    error: null,
                    expected: __codestreakReferenceResults[i].expected,
                    expectedError: __codestreakReferenceResults[i].error
                  });
                } catch (error) {
                  __codestreakResults.push({
                    actual: null,
                    error: error.toString(),
                    expected: __codestreakReferenceResults[i].expected,
                    expectedError: __codestreakReferenceResults[i].error
                  });
                }
              }
              __codestreakDone = true;
            }).then(function() {
            }, function(error) {
              __codestreakFatal = error.toString();
              __codestreakDone = true;
            });
            """)

            if let contextException { throw RunnerMessageError(message: contextException) }
            guard context.objectForKeyedSubscript("__codestreakDone")?.toBool() == true else {
                throw PythonRunnerError.invalidHarnessResult
            }
            if let fatal = context.objectForKeyedSubscript("__codestreakFatal"), !fatal.isNull, !fatal.isUndefined {
                throw RunnerMessageError(message: fatal.toString())
            }

            guard let rawResults = context.objectForKeyedSubscript("__codestreakResults")?.toArray() as? [[String: Any]],
                  rawResults.count == validationTests.count else {
                throw PythonRunnerError.invalidHarnessResult
            }

            let results = try zip(validationTests.indices, zip(validationTests, rawResults)).map { index, pair in
                let (test, raw) = pair
                if let expectedError = raw["expectedError"] as? String {
                    return PythonTestResult(
                        id: index,
                        name: test.name,
                        outcome: .error,
                        input: inputDescription(for: test, problem: problem),
                        expected: "—",
                        actual: "—",
                        message: "CodeStreak's internal challenge answer failed: \(expectedError)"
                    )
                }

                let expectedObject: Any
                if test.derivesExpectedFromReference {
                    expectedObject = raw["expected"] ?? NSNull()
                } else {
                    expectedObject = try decodeJSON(test.expectedJSON)
                }
                let expectedCanonical = try canonicalJSON(expectedObject)
                let expectedDisplay = prettyJSON(expectedCanonical)
                if let error = raw["error"] as? String {
                    return PythonTestResult(
                        id: index,
                        name: test.name,
                        outcome: .error,
                        input: inputDescription(for: test, problem: problem),
                        expected: expectedDisplay,
                        actual: "—",
                        message: error
                    )
                }

                let actualObject = raw["actual"] ?? NSNull()
                let actualCanonical = try canonicalJSON(actualObject)
                let passed = jsonValuesEqual(expectedObject, actualObject)
                return PythonTestResult(
                    id: index,
                    name: test.name,
                    outcome: passed ? .passed : .failed,
                    input: inputDescription(for: test, problem: problem),
                    expected: expectedDisplay,
                    actual: prettyJSON(actualCanonical),
                    message: passed ? nil : "Expected and returned values differ. Trace your function with this exact input, then check what you return."
                )
            }

            return PythonRunReport(
                results: results,
                errorMessage: nil,
                elapsedMilliseconds: elapsedMilliseconds(since: started)
            )
        } catch {
            return PythonRunReport(
                results: [],
                errorMessage: error.localizedDescription,
                elapsedMilliseconds: elapsedMilliseconds(since: started)
            )
        }
    }

    static func executeScratchpad(source: String) -> PythonScratchpadReport {
        let started = ContinuousClock.now

        do {
            guard source.count <= 50_000 else { throw PythonRunnerError.sourceTooLarge }
            guard let context = JSContext() else { throw PythonRunnerError.runtimeUnavailable }

            var contextException: String?
            context.exceptionHandler = { _, exception in
                contextException = exception?.toString()
            }

            for resource in ["skulpt.min", "skulpt-stdlib"] {
                context.evaluateScript(try runtimeSource(named: resource))
                if let contextException { throw RunnerMessageError(message: contextException) }
            }

            let sourceLiteral = try JSONEncoder().encode(source)
            guard let encodedSource = String(data: sourceLiteral, encoding: .utf8) else {
                throw PythonRunnerError.invalidHarnessResult
            }

            context.evaluateScript("""
            var __codestreakScratchDone = false;
            var __codestreakScratchError = null;
            var __codestreakScratchOutput = "";
            function __codestreakScratchRead(path) {
              if (Sk.builtinFiles === undefined || Sk.builtinFiles["files"][path] === undefined) {
                throw "Module not available offline: " + path;
              }
              return Sk.builtinFiles["files"][path];
            }
            function __codestreakScratchWrite(text) {
              __codestreakScratchOutput += String(text);
              if (__codestreakScratchOutput.length > 100000) {
                throw new Error("Cell output exceeded 100,000 characters. Print fewer values and run it again.");
              }
            }
            Sk.configure({
              output: __codestreakScratchWrite,
              read: __codestreakScratchRead,
              __future__: Sk.python3,
              execLimit: 2500,
              yieldLimit: null
            });
            Sk.misceval.asyncToPromise(function() {
              return Sk.importMainWithBody("<scratchpad>", false, \(encodedSource), true);
            }).then(function() {
              __codestreakScratchDone = true;
            }, function(error) {
              __codestreakScratchError = error.toString();
              __codestreakScratchDone = true;
            });
            """)

            if let contextException { throw RunnerMessageError(message: contextException) }
            guard context.objectForKeyedSubscript("__codestreakScratchDone")?.toBool() == true else {
                throw PythonRunnerError.invalidHarnessResult
            }

            let output = context.objectForKeyedSubscript("__codestreakScratchOutput")?.toString() ?? ""
            let scratchError = context.objectForKeyedSubscript("__codestreakScratchError")
            let errorMessage: String?
            if let scratchError, !scratchError.isNull, !scratchError.isUndefined {
                errorMessage = scratchError.toString()
            } else {
                errorMessage = nil
            }

            return PythonScratchpadReport(
                output: output,
                errorMessage: errorMessage,
                elapsedMilliseconds: elapsedMilliseconds(since: started)
            )
        } catch {
            return PythonScratchpadReport(
                output: "",
                errorMessage: error.localizedDescription,
                elapsedMilliseconds: elapsedMilliseconds(since: started)
            )
        }
    }

    private static func runtimeSource(named name: String) throws -> String {
        let bundles = [Bundle.main, Bundle(for: RuntimeBundleMarker.self)]
        for bundle in bundles {
            if let url = bundle.url(forResource: name, withExtension: "js", subdirectory: "Skulpt") ??
                bundle.url(forResource: name, withExtension: "js") {
                return try String(contentsOf: url, encoding: .utf8)
            }
        }
        throw PythonRunnerError.runtimeMissing
    }

    private static func decodeJSON(_ json: String) throws -> Any {
        guard let data = json.data(using: .utf8) else { throw PythonRunnerError.invalidHarnessResult }
        return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
    }

    private static func canonicalJSON(_ object: Any) throws -> String {
        let normalized = normalizeJSONNumbers(object)
        guard JSONSerialization.isValidJSONObject(normalized) || normalized is NSNumber || normalized is NSString || normalized is NSNull else {
            throw PythonRunnerError.invalidHarnessResult
        }
        let data = try JSONSerialization.data(withJSONObject: normalized, options: [.fragmentsAllowed, .sortedKeys])
        guard let result = String(data: data, encoding: .utf8) else { throw PythonRunnerError.invalidHarnessResult }
        return result
    }

    private static func normalizeJSONNumbers(_ object: Any) -> Any {
        if let values = object as? [Any] {
            return values.map(normalizeJSONNumbers)
        }
        if let values = object as? [String: Any] {
            return values.mapValues(normalizeJSONNumbers)
        }
        if let number = object as? NSNumber,
           CFGetTypeID(number) != CFBooleanGetTypeID(),
           number.doubleValue == 0 {
            return NSNumber(value: 0)
        }
        return object
    }

    /// Numerical interview problems should accept equivalent floating-point
    /// implementations even when operation order changes the final bits.
    private static func jsonValuesEqual(_ expected: Any, _ actual: Any) -> Bool {
        if let expectedArray = expected as? [Any], let actualArray = actual as? [Any] {
            return expectedArray.count == actualArray.count
                && zip(expectedArray, actualArray).allSatisfy { pair in
                    jsonValuesEqual(pair.0, pair.1)
                }
        }
        if let expectedObject = expected as? [String: Any], let actualObject = actual as? [String: Any] {
            return expectedObject.keys == actualObject.keys
                && expectedObject.allSatisfy { key, value in
                    actualObject[key].map { jsonValuesEqual(value, $0) } ?? false
                }
        }
        if let expectedNumber = expected as? NSNumber, let actualNumber = actual as? NSNumber {
            let expectedIsBoolean = CFGetTypeID(expectedNumber) == CFBooleanGetTypeID()
            let actualIsBoolean = CFGetTypeID(actualNumber) == CFBooleanGetTypeID()
            if expectedIsBoolean || actualIsBoolean {
                return expectedIsBoolean && actualIsBoolean && expectedNumber.boolValue == actualNumber.boolValue
            }
            let left = expectedNumber.doubleValue
            let right = actualNumber.doubleValue
            guard left.isFinite, right.isFinite else { return left == right }
            let tolerance = 1e-6 * max(1, abs(left), abs(right))
            return abs(left - right) <= tolerance
        }
        if expected is NSNull, actual is NSNull { return true }
        if let expectedString = expected as? String, let actualString = actual as? String {
            return expectedString == actualString
        }
        return false
    }

    private static func prettyJSON(_ json: String) -> String {
        guard
            let data = json.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]),
            JSONSerialization.isValidJSONObject(object),
            let pretty = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
            let value = String(data: pretty, encoding: .utf8)
        else { return json }
        return value
    }

    private static func inputDescription(for test: AlgorithmTestCase, problem: AlgorithmProblem) -> String {
        guard
            let decoded = try? decodeJSON(test.argumentsJSON),
            let arguments = decoded as? [Any]
        else {
            return prettyJSON(test.argumentsJSON)
        }

        let names = parameterNames(for: problem)
        return arguments.enumerated().map { index, argument in
            let name = names.indices.contains(index) ? names[index] : "argument \(index + 1)"
            let rendered: String
            if let canonical = try? canonicalJSON(argument) {
                rendered = prettyJSON(canonical)
            } else {
                rendered = String(describing: argument)
            }
            return "\(name) = \(rendered)"
        }
        .joined(separator: "\n")
    }

    private static func parameterNames(for problem: AlgorithmProblem) -> [String] {
        let marker = "def \(problem.functionName)("
        guard let markerRange = problem.starterCode.range(of: marker) else { return [] }
        let remainder = problem.starterCode[markerRange.upperBound...]
        guard let closingParenthesis = remainder.firstIndex(of: ")") else { return [] }

        return remainder[..<closingParenthesis]
            .split(separator: ",")
            .map { parameter in
                parameter
                    .split(separator: "=", maxSplits: 1)[0]
                    .split(separator: ":", maxSplits: 1)[0]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
    }

    private static func elapsedMilliseconds(since instant: ContinuousClock.Instant) -> Int {
        let duration = instant.duration(to: ContinuousClock.now)
        return Int(duration.components.seconds * 1_000) + Int(duration.components.attoseconds / 1_000_000_000_000_000)
    }
}

private struct HarnessPayload: Encodable {
    struct Test: Encodable {
        let arguments: AnyEncodableJSON
        let derivesExpectedFromReference: Bool
    }

    let functionName: String
    let source: String
    let referenceSource: String
    let tests: [Test]

    init(
        functionName: String,
        source: String,
        referenceSource: String,
        tests: [AlgorithmTestCase]
    ) throws {
        self.functionName = functionName
        self.source = source
        self.referenceSource = referenceSource
        self.tests = try tests.map { test in
            guard let data = test.argumentsJSON.data(using: .utf8) else { throw PythonRunnerError.invalidHarnessResult }
            let object = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            return Test(
                arguments: AnyEncodableJSON(object),
                derivesExpectedFromReference: test.derivesExpectedFromReference
            )
        }
    }

    func jsonLiteral() throws -> String {
        let data = try JSONEncoder().encode(self)
        guard let value = String(data: data, encoding: .utf8) else { throw PythonRunnerError.invalidHarnessResult }
        return value
    }
}

private struct AnyEncodableJSON: Encodable {
    let value: Any

    init(_ value: Any) { self.value = value }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case is NSNull: try container.encodeNil()
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                try container.encode(number.boolValue)
            } else if number.doubleValue.rounded() == number.doubleValue {
                try container.encode(number.intValue)
            } else {
                try container.encode(number.doubleValue)
            }
        case let value as Bool: try container.encode(value)
        case let value as Int: try container.encode(value)
        case let value as Double: try container.encode(value)
        case let value as String: try container.encode(value)
        case let values as [Any]: try container.encode(values.map(AnyEncodableJSON.init))
        case let values as [String: Any]: try container.encode(values.mapValues(AnyEncodableJSON.init))
        default: throw PythonRunnerError.invalidHarnessResult
        }
    }
}

private final class RuntimeBundleMarker: NSObject {}

private struct RunnerMessageError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}
