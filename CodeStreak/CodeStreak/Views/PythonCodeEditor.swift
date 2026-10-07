import SwiftUI

#if os(iOS)
import UIKit
private typealias PlatformColor = UIColor
private typealias PlatformFont = UIFont
#elseif os(macOS)
import AppKit
private typealias PlatformColor = NSColor
private typealias PlatformFont = NSFont
#endif

@MainActor
struct PythonCodeEditor: View {
    @Binding var text: String
    let isEditable: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.appFontScale) private var appFontScale

    init(text: Binding<String>, isEditable: Bool = true) {
        _text = text
        self.isEditable = isEditable
    }

    private var fontSize: CGFloat {
#if os(macOS)
        14 * appFontScale
#else
        AppTextSizeController.codeFontSize(for: dynamicTypeSize)
#endif
    }

    var body: some View {
#if os(iOS)
        IOSPythonTextView(text: $text, fontSize: fontSize, isEditable: isEditable)
#else
        MacPythonTextView(text: $text, fontSize: fontSize, isEditable: isEditable)
#endif
    }
}

/// A selectable, read-only Python surface that deliberately shares the editor's
/// syntax colors, line-number gutter, font scaling, and scrolling behavior.
@MainActor
struct PythonCodeViewer: View {
    let source: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.appFontScale) private var appFontScale

    private var fontSize: CGFloat {
#if os(macOS)
        14 * appFontScale
#else
        AppTextSizeController.codeFontSize(for: dynamicTypeSize)
#endif
    }

    var body: some View {
        PythonCodeEditor(text: .constant(source), isEditable: false)
            .frame(height: PythonCodeViewerLayout.height(for: source, fontSize: fontSize))
    }
}

enum PythonCodeViewerLayout {
    static func height(for source: String, fontSize: CGFloat) -> CGFloat {
        let visibleLineCount = min(max(PythonLineNumbers.count(in: source), 6), 22)
        let estimatedLineHeight = max(fontSize * 1.48, 20)
        return min(max(CGFloat(visibleLineCount) * estimatedLineHeight + 28, 170), 520)
    }
}

private enum PythonHighlightKind {
    case keyword
    case builtin
    case function
    case string
    case number
    case comment
    case decorator
    case punctuation
}

@MainActor
private enum PythonSyntaxHighlighter {
    private static let keywords: Set<String> = [
        "and", "as", "assert", "async", "await", "break", "case", "class", "continue",
        "def", "del", "elif", "else", "except", "False", "finally", "for", "from",
        "global", "if", "import", "in", "is", "lambda", "match", "None", "nonlocal",
        "not", "or", "pass", "raise", "return", "True", "try", "while", "with", "yield"
    ]

    private static let builtins: Set<String> = [
        "abs", "all", "any", "bin", "bool", "chr", "dict", "enumerate", "filter", "float",
        "int", "len", "list", "map", "max", "min", "open", "ord", "pow", "print", "range",
        "reversed", "round", "set", "sorted", "str", "sum", "tuple", "type", "zip"
    ]

    static func apply(to storage: NSTextStorage, font: PlatformFont) {
        let source = storage.string as NSString
        let fullRange = NSRange(location: 0, length: source.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.defaultTabInterval = ("    " as NSString).size(
            withAttributes: [.font: font]
        ).width
        paragraphStyle.tabStops = []

        storage.beginEditing()
        storage.setAttributes(
            [
                .font: font,
                .foregroundColor: color(red: 0.84, green: 0.87, blue: 0.93),
                .paragraphStyle: paragraphStyle
            ],
            range: fullRange
        )

        var index = 0
        var expectsDeclarationName = false

        while index < source.length {
            let character = source.character(at: index)

            if character == 35 { // # comment
                let start = index
                while index < source.length && source.character(at: index) != 10 { index += 1 }
                style(.comment, range: NSRange(location: start, length: index - start), in: storage)
                expectsDeclarationName = false
                continue
            }

            if character == 34 || character == 39 { // string literal
                let start = index
                let quote = character
                let isTriple = index + 2 < source.length
                    && source.character(at: index + 1) == quote
                    && source.character(at: index + 2) == quote
                index += isTriple ? 3 : 1

                while index < source.length {
                    if source.character(at: index) == 92 { // escaped character
                        index = min(index + 2, source.length)
                        continue
                    }
                    if isTriple {
                        if index + 2 < source.length
                            && source.character(at: index) == quote
                            && source.character(at: index + 1) == quote
                            && source.character(at: index + 2) == quote {
                            index += 3
                            break
                        }
                    } else if source.character(at: index) == quote {
                        index += 1
                        break
                    }
                    index += 1
                }

                style(.string, range: NSRange(location: start, length: index - start), in: storage)
                continue
            }

            if character == 64 { // decorator
                let start = index
                index += 1
                while index < source.length {
                    let next = source.character(at: index)
                    guard isIdentifierCharacter(next) || next == 46 else { break }
                    index += 1
                }
                style(.decorator, range: NSRange(location: start, length: index - start), in: storage)
                continue
            }

            if isDigit(character) || (character == 46 && index + 1 < source.length && isDigit(source.character(at: index + 1))) {
                let start = index
                index += 1
                while index < source.length {
                    let next = source.character(at: index)
                    guard isIdentifierCharacter(next) || next == 46 else { break }
                    index += 1
                }
                style(.number, range: NSRange(location: start, length: index - start), in: storage)
                continue
            }

            if isIdentifierStart(character) {
                let start = index
                index += 1
                while index < source.length && isIdentifierCharacter(source.character(at: index)) { index += 1 }
                let word = source.substring(with: NSRange(location: start, length: index - start))
                let range = NSRange(location: start, length: index - start)

                if expectsDeclarationName {
                    style(.function, range: range, in: storage)
                    expectsDeclarationName = false
                } else if keywords.contains(word) {
                    style(.keyword, range: range, in: storage)
                    expectsDeclarationName = word == "def" || word == "class"
                } else if builtins.contains(word) {
                    style(.builtin, range: range, in: storage)
                } else if nextNonWhitespaceCharacter(in: source, after: index) == 40 {
                    style(.function, range: range, in: storage)
                }
                continue
            }

            if "+-*/%=<>!&|^~:.,()[]{}".utf16.contains(character) {
                style(.punctuation, range: NSRange(location: index, length: 1), in: storage)
            } else if character == 10 {
                expectsDeclarationName = false
            }
            index += 1
        }

        storage.endEditing()
    }

    private static func style(_ kind: PythonHighlightKind, range: NSRange, in storage: NSTextStorage) {
        storage.addAttribute(.foregroundColor, value: color(for: kind), range: range)
    }

    private static func color(for kind: PythonHighlightKind) -> PlatformColor {
        switch kind {
        case .keyword: color(red: 0.78, green: 0.54, blue: 0.94)
        case .builtin: color(red: 0.35, green: 0.78, blue: 0.91)
        case .function: color(red: 0.93, green: 0.82, blue: 0.47)
        case .string: color(red: 0.89, green: 0.57, blue: 0.43)
        case .number: color(red: 0.69, green: 0.83, blue: 0.65)
        case .comment: color(red: 0.42, green: 0.64, blue: 0.43)
        case .decorator: color(red: 0.45, green: 0.76, blue: 0.73)
        case .punctuation: color(red: 0.64, green: 0.70, blue: 0.82)
        }
    }

    private static func color(red: CGFloat, green: CGFloat, blue: CGFloat) -> PlatformColor {
        PlatformColor(red: red, green: green, blue: blue, alpha: 1)
    }

    private static func isDigit(_ character: unichar) -> Bool {
        character >= 48 && character <= 57
    }

    private static func isIdentifierStart(_ character: unichar) -> Bool {
        (character >= 65 && character <= 90) || (character >= 97 && character <= 122) || character == 95
    }

    private static func isIdentifierCharacter(_ character: unichar) -> Bool {
        isIdentifierStart(character) || isDigit(character)
    }

    private static func nextNonWhitespaceCharacter(in source: NSString, after index: Int) -> unichar? {
        var cursor = index
        while cursor < source.length {
            let character = source.character(at: cursor)
            if character != 32 && character != 9 && character != 10 && character != 13 { return character }
            cursor += 1
        }
        return nil
    }
}

struct PythonTextEdit: Equatable, Sendable {
    let range: NSRange
    let replacement: String
    let selectedRange: NSRange
}

enum PythonEditing {
    static let indentation = "    "

    static func newlineEdit(in source: String, replacing requestedRange: NSRange) -> PythonTextEdit {
        let text = source as NSString
        let range = safeRange(requestedRange, length: text.length)
        let safeLocation = range.location
        let searchRange = NSRange(location: 0, length: safeLocation)
        let previousNewline = text.range(of: "\n", options: .backwards, range: searchRange)
        let lineStart = previousNewline.location == NSNotFound ? 0 : previousNewline.location + 1
        let line = text.substring(with: NSRange(location: lineStart, length: safeLocation - lineStart))
        let leadingWhitespace = String(line.prefix { $0 == " " || $0 == "\t" })

        // Pressing Return on an indentation-only line should create a truly
        // blank line and return to column zero, instead of accumulating hidden
        // spaces that make the next block difficult to reason about.
        if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let replacementRange = NSRange(
                location: lineStart,
                length: NSMaxRange(range) - lineStart
            )
            return PythonTextEdit(
                range: replacementRange,
                replacement: "\n",
                selectedRange: NSRange(location: lineStart + 1, length: 0)
            )
        }

        let code = codeBeforeComment(in: line)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let opensBlock = code.hasSuffix(":")
            || hasUnclosedDelimiter(in: code)
            || code.hasSuffix("\\")
        let normalizedIndentation = leadingWhitespace.replacingOccurrences(of: "\t", with: indentation)
        let replacement = "\n" + normalizedIndentation + (opensBlock ? indentation : "")
        return PythonTextEdit(
            range: range,
            replacement: replacement,
            selectedRange: NSRange(location: range.location + replacement.utf16.count, length: 0)
        )
    }

    static func indentationEdit(
        in source: String,
        selection requestedSelection: NSRange,
        outdent: Bool
    ) -> PythonTextEdit? {
        let text = source as NSString
        let selection = safeRange(requestedSelection, length: text.length)

        if selection.length == 0, !outdent {
            let lineStart = startOfLine(in: text, at: selection.location)
            let column = selection.location - lineStart
            let spaces = indentation.count - (column % indentation.count)
            let replacement = String(repeating: " ", count: spaces)
            return PythonTextEdit(
                range: selection,
                replacement: replacement,
                selectedRange: NSRange(location: selection.location + spaces, length: 0)
            )
        }

        let lastSelectedLocation = selection.length > 0
            ? max(selection.location, NSMaxRange(selection) - 1)
            : selection.location
        let firstLineStart = startOfLine(in: text, at: selection.location)
        let finalLineRange = text.lineRange(
            for: NSRange(location: lastSelectedLocation, length: 0)
        )
        let lineRange = NSRange(
            location: firstLineStart,
            length: NSMaxRange(finalLineRange) - firstLineStart
        )

        var operations: [(location: Int, removed: Int, inserted: String)] = []
        var cursor = firstLineStart
        let rangeEnd = NSMaxRange(lineRange)
        while cursor < rangeEnd {
            if outdent {
                let removal = indentationRemovalLength(in: text, at: cursor, before: rangeEnd)
                if removal > 0 {
                    operations.append((cursor, removal, ""))
                }
            } else {
                operations.append((cursor, 0, indentation))
            }

            let currentLineRange = text.lineRange(for: NSRange(location: cursor, length: 0))
            let next = NSMaxRange(currentLineRange)
            guard next > cursor else { break }
            cursor = next
        }

        guard !operations.isEmpty else { return nil }
        let replacement = NSMutableString(string: text.substring(with: lineRange))
        for operation in operations.reversed() {
            replacement.replaceCharacters(
                in: NSRange(
                    location: operation.location - lineRange.location,
                    length: operation.removed
                ),
                with: operation.inserted
            )
        }

        let mappedStart = mappedPosition(
            selection.location,
            through: operations,
            includeInsertionAtPosition: false
        )
        let mappedEnd = mappedPosition(
            NSMaxRange(selection),
            through: operations,
            includeInsertionAtPosition: selection.length > 0
        )
        return PythonTextEdit(
            range: lineRange,
            replacement: replacement as String,
            selectedRange: NSRange(
                location: mappedStart,
                length: max(mappedEnd - mappedStart, 0)
            )
        )
    }

    static func closingDelimiterEdit(
        in source: String,
        selection requestedSelection: NSRange,
        replacement: String
    ) -> PythonTextEdit? {
        guard [")", "]", "}"].contains(replacement) else { return nil }
        let text = source as NSString
        let selection = safeRange(requestedSelection, length: text.length)
        let lineStart = startOfLine(in: text, at: selection.location)
        let prefixRange = NSRange(location: lineStart, length: selection.location - lineStart)
        let prefix = text.substring(with: prefixRange)
        guard !prefix.isEmpty,
              prefix.allSatisfy({ $0 == " " || $0 == "\t" }) else { return nil }

        let removal: Int
        if prefix.hasSuffix("\t") {
            removal = 1
        } else {
            removal = min(indentation.count, prefix.reversed().prefix { $0 == " " }.count)
        }
        guard removal > 0 else { return nil }
        let editRange = NSRange(
            location: selection.location - removal,
            length: removal + selection.length
        )
        return PythonTextEdit(
            range: editRange,
            replacement: replacement,
            selectedRange: NSRange(location: editRange.location + replacement.utf16.count, length: 0)
        )
    }

    static func backwardDeletionEdit(
        in source: String,
        selection requestedSelection: NSRange
    ) -> PythonTextEdit? {
        let text = source as NSString
        let selection = safeRange(requestedSelection, length: text.length)
        guard selection.length == 0, selection.location > 0 else { return nil }
        let lineStart = startOfLine(in: text, at: selection.location)
        guard selection.location > lineStart else { return nil }
        let prefix = text.substring(
            with: NSRange(location: lineStart, length: selection.location - lineStart)
        )
        guard prefix.allSatisfy({ $0 == " " || $0 == "\t" }) else { return nil }

        let removal: Int
        if prefix.hasSuffix("\t") {
            removal = 1
        } else {
            let column = selection.location - lineStart
            removal = column % indentation.count == 0
                ? min(indentation.count, prefix.count)
                : column % indentation.count
        }
        guard removal > 0 else { return nil }
        let editRange = NSRange(location: selection.location - removal, length: removal)
        return PythonTextEdit(
            range: editRange,
            replacement: "",
            selectedRange: NSRange(location: editRange.location, length: 0)
        )
    }

    private static func safeRange(_ range: NSRange, length: Int) -> NSRange {
        let location = range.location == NSNotFound ? length : min(max(range.location, 0), length)
        let requestedLength = range.length == NSNotFound ? 0 : max(range.length, 0)
        return NSRange(location: location, length: min(requestedLength, length - location))
    }

    private static func startOfLine(in text: NSString, at location: Int) -> Int {
        let searchRange = NSRange(location: 0, length: min(max(location, 0), text.length))
        let newline = text.range(of: "\n", options: .backwards, range: searchRange)
        return newline.location == NSNotFound ? 0 : newline.location + 1
    }

    private static func indentationRemovalLength(in text: NSString, at location: Int, before end: Int) -> Int {
        guard location < min(text.length, end) else { return 0 }
        if text.character(at: location) == 9 { return 1 }
        var count = 0
        while location + count < min(text.length, end),
              count < indentation.count,
              text.character(at: location + count) == 32 {
            count += 1
        }
        return count
    }

    private static func mappedPosition(
        _ position: Int,
        through operations: [(location: Int, removed: Int, inserted: String)],
        includeInsertionAtPosition: Bool
    ) -> Int {
        var delta = 0
        for operation in operations {
            if operation.removed > 0,
               position > operation.location,
               position < operation.location + operation.removed {
                return operation.location + delta
            }
            if position > operation.location + operation.removed
                || (position == operation.location + operation.removed
                    && (operation.removed > 0 || includeInsertionAtPosition)) {
                delta += operation.inserted.utf16.count - operation.removed
            } else if position == operation.location,
                      operation.removed == 0,
                      includeInsertionAtPosition {
                delta += operation.inserted.utf16.count
            }
        }
        return position + delta
    }

    private static func codeBeforeComment(in line: String) -> String {
        var quote: Character?
        var escaped = false
        for index in line.indices {
            let character = line[index]
            if escaped {
                escaped = false
                continue
            }
            if character == "\\", quote != nil {
                escaped = true
                continue
            }
            if character == "\"" || character == "'" {
                if quote == character {
                    quote = nil
                } else if quote == nil {
                    quote = character
                }
                continue
            }
            if character == "#", quote == nil {
                return String(line[..<index])
            }
        }
        return line
    }

    private static func hasUnclosedDelimiter(in code: String) -> Bool {
        var stack: [Character] = []
        var quote: Character?
        var escaped = false

        for character in code {
            if escaped {
                escaped = false
                continue
            }
            if character == "\\", quote != nil {
                escaped = true
                continue
            }
            if character == "\"" || character == "'" {
                if quote == character {
                    quote = nil
                } else if quote == nil {
                    quote = character
                }
                continue
            }
            guard quote == nil else { continue }

            switch character {
            case "(", "[", "{":
                stack.append(character)
            case ")":
                if stack.last == "(" { stack.removeLast() }
            case "]":
                if stack.last == "[" { stack.removeLast() }
            case "}":
                if stack.last == "{" { stack.removeLast() }
            default:
                break
            }
        }
        return !stack.isEmpty
    }
}

enum PythonLineNumbers {
    static func utf16LineStarts(in source: String) -> [Int] {
        let text = source as NSString
        var starts = [0]
        guard text.length > 0 else { return starts }
        for index in 0..<text.length where text.character(at: index) == 10 {
            starts.append(index + 1)
        }
        return starts
    }

    static func count(in source: String) -> Int {
        utf16LineStarts(in: source).count
    }
}

#if os(iOS)
@MainActor
private final class IOSPythonEditorContainerView: UIView {
    let textView = UITextView()
    let lineNumberView = IOSPythonLineNumberView()
    private var gutterWidthConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.075, green: 0.085, blue: 0.11, alpha: 1)
        layer.cornerRadius = 12
        clipsToBounds = true

        lineNumberView.textView = textView
        lineNumberView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineNumberView)
        addSubview(textView)

        gutterWidthConstraint = lineNumberView.widthAnchor.constraint(equalToConstant: 42)
        NSLayoutConstraint.activate([
            lineNumberView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineNumberView.topAnchor.constraint(equalTo: topAnchor),
            lineNumberView.bottomAnchor.constraint(equalTo: bottomAnchor),
            gutterWidthConstraint,
            textView.leadingAnchor.constraint(equalTo: lineNumberView.trailingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }

    func refreshLineNumbers(fontSize: CGFloat) {
        lineNumberView.fontSize = fontSize
        let digits = max(String(PythonLineNumbers.count(in: textView.text)).count, 2)
        let font = UIFont.monospacedDigitSystemFont(ofSize: max(fontSize - 2, 10), weight: .regular)
        let digitWidth = (String(repeating: "8", count: digits) as NSString).size(
            withAttributes: [.font: font]
        ).width
        gutterWidthConstraint.constant = max(38, ceil(digitWidth) + 16)
        lineNumberView.setNeedsDisplay()
    }
}

@MainActor
private final class IOSPythonLineNumberView: UIView {
    weak var textView: UITextView?
    var fontSize: CGFloat = 14

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.058, green: 0.066, blue: 0.087, alpha: 1)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
    }

    required init?(coder: NSCoder) { nil }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let textView else { return }
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        layoutManager.ensureLayout(for: textContainer)
        let starts = PythonLineNumbers.utf16LineStarts(in: textView.text)
        let font = UIFont.monospacedDigitSystemFont(ofSize: max(fontSize - 2, 10), weight: .regular)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(red: 0.42, green: 0.47, blue: 0.58, alpha: 1),
            .paragraphStyle: paragraph
        ]

        for (offset, characterIndex) in starts.enumerated() {
            let fragment: CGRect
            if characterIndex < (textView.text as NSString).length {
                let glyphIndex = layoutManager.glyphIndexForCharacter(at: characterIndex)
                fragment = layoutManager.lineFragmentUsedRect(forGlyphAt: glyphIndex, effectiveRange: nil)
            } else {
                fragment = layoutManager.extraLineFragmentUsedRect
            }
            let y = fragment.minY + textView.textContainerInset.top - textView.contentOffset.y
            let height = max(fragment.height, font.lineHeight)
            guard y + height >= rect.minY, y <= rect.maxY else { continue }
            (String(offset + 1) as NSString).draw(
                in: CGRect(x: 3, y: y, width: bounds.width - 11, height: height),
                withAttributes: attributes
            )
        }

        UIColor(red: 0.18, green: 0.20, blue: 0.26, alpha: 1).setFill()
        UIRectFill(CGRect(x: bounds.maxX - 1, y: rect.minY, width: 1, height: rect.height))
    }
}

@MainActor
private struct IOSPythonTextView: UIViewRepresentable {
    @Binding var text: String
    let fontSize: CGFloat
    let isEditable: Bool

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> IOSPythonEditorContainerView {
        let container = IOSPythonEditorContainerView()
        let textView = container.textView
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 9, bottom: 14, right: 12)
        textView.font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.spellCheckingType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.keyboardType = .asciiCapable
        textView.alwaysBounceVertical = true
        if isEditable {
            let keyboardToolbar = UIToolbar()
            keyboardToolbar.sizeToFit()
            let outdentButton = UIBarButtonItem(
                title: "Outdent",
                style: .plain,
                target: context.coordinator,
                action: #selector(Coordinator.outdentSelection)
            )
            let indentButton = UIBarButtonItem(
                title: "Indent",
                style: .plain,
                target: context.coordinator,
                action: #selector(Coordinator.indentSelection)
            )
            keyboardToolbar.items = [
                outdentButton,
                UIBarButtonItem(systemItem: .flexibleSpace),
                indentButton
            ]
            textView.inputAccessoryView = keyboardToolbar
        }
        context.coordinator.container = container
        context.coordinator.textView = textView
        context.coordinator.replaceText(in: textView, with: text)
        return container
    }

    func updateUIView(_ container: IOSPythonEditorContainerView, context: Context) {
        context.coordinator.parent = self
        let textView = container.textView
        textView.isEditable = isEditable
        textView.isSelectable = true
        if textView.text != text {
            context.coordinator.replaceText(in: textView, with: text)
        } else {
            context.coordinator.refreshStyle(in: textView)
        }
        container.refreshLineNumbers(fontSize: fontSize)
    }

    @MainActor
    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: IOSPythonTextView
        weak var container: IOSPythonEditorContainerView?
        weak var textView: UITextView?
        private var isApplyingChanges = false

        init(parent: IOSPythonTextView) { self.parent = parent }

        func textViewDidChange(_ textView: UITextView) {
            guard !isApplyingChanges else { return }
            parent.text = textView.text
            highlight(textView)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            container?.lineNumberView.setNeedsDisplay()
        }

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText replacement: String
        ) -> Bool {
            if replacement == "\n" {
                apply(PythonEditing.newlineEdit(in: textView.text, replacing: range), to: textView)
                return false
            }
            if replacement == "\t",
               let edit = PythonEditing.indentationEdit(
                    in: textView.text,
                    selection: range,
                    outdent: false
               ) {
                apply(edit, to: textView)
                return false
            }
            if let edit = PythonEditing.closingDelimiterEdit(
                in: textView.text,
                selection: range,
                replacement: replacement
            ) {
                apply(edit, to: textView)
                return false
            }
            if replacement.isEmpty,
               range.length == 1,
               textView.selectedRange.length == 0,
               let edit = PythonEditing.backwardDeletionEdit(
                    in: textView.text,
                    selection: NSRange(location: NSMaxRange(range), length: 0)
               ) {
                apply(edit, to: textView)
                return false
            }
            return true
        }

        @objc func indentSelection() {
            guard let textView,
                  let edit = PythonEditing.indentationEdit(
                    in: textView.text,
                    selection: textView.selectedRange,
                    outdent: false
                  ) else { return }
            apply(edit, to: textView)
        }

        @objc func outdentSelection() {
            guard let textView,
                  let edit = PythonEditing.indentationEdit(
                    in: textView.text,
                    selection: textView.selectedRange,
                    outdent: true
                  ) else { return }
            apply(edit, to: textView)
        }

        private func apply(_ edit: PythonTextEdit, to textView: UITextView) {
            isApplyingChanges = true
            textView.textStorage.replaceCharacters(in: edit.range, with: edit.replacement)
            textView.selectedRange = edit.selectedRange
            isApplyingChanges = false
            parent.text = textView.text
            highlight(textView)
        }

        func replaceText(in textView: UITextView, with source: String) {
            isApplyingChanges = true
            textView.text = source
            isApplyingChanges = false
            highlight(textView)
        }

        func refreshStyle(in textView: UITextView) {
            let currentSize = textView.font?.pointSize ?? 0
            guard abs(currentSize - parent.fontSize) > 0.1 else {
                container?.lineNumberView.setNeedsDisplay()
                return
            }
            highlight(textView)
        }

        private func highlight(_ textView: UITextView) {
            let selection = textView.selectedRange
            let offset = textView.contentOffset
            textView.font = .monospacedSystemFont(ofSize: parent.fontSize, weight: .regular)
            PythonSyntaxHighlighter.apply(
                to: textView.textStorage,
                font: .monospacedSystemFont(ofSize: parent.fontSize, weight: .regular)
            )
            textView.typingAttributes = [
                .font: UIFont.monospacedSystemFont(ofSize: parent.fontSize, weight: .regular),
                .foregroundColor: UIColor(red: 0.84, green: 0.87, blue: 0.93, alpha: 1)
            ]
            textView.selectedRange = selection
            textView.setContentOffset(offset, animated: false)
            container?.refreshLineNumbers(fontSize: parent.fontSize)
        }
    }
}
#elseif os(macOS)
@MainActor
private final class MacPythonEditorContainerView: NSView {
    let scrollView = NSScrollView()
    let textView = NSTextView()
    let lineNumberView = MacPythonLineNumberView()
    private var gutterWidthConstraint: NSLayoutConstraint!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor(red: 0.075, green: 0.085, blue: 0.11, alpha: 1).cgColor
        layer?.cornerRadius = 12
        layer?.masksToBounds = true

        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.documentView = textView
        scrollView.contentView.postsBoundsChangedNotifications = true
        lineNumberView.textView = textView

        lineNumberView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineNumberView)
        addSubview(scrollView)
        gutterWidthConstraint = lineNumberView.widthAnchor.constraint(equalToConstant: 42)
        NSLayoutConstraint.activate([
            lineNumberView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineNumberView.topAnchor.constraint(equalTo: topAnchor),
            lineNumberView.bottomAnchor.constraint(equalTo: bottomAnchor),
            gutterWidthConstraint,
            scrollView.leadingAnchor.constraint(equalTo: lineNumberView.trailingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }

    func refreshLineNumbers(fontSize: CGFloat) {
        lineNumberView.fontSize = fontSize
        let digits = max(String(PythonLineNumbers.count(in: textView.string)).count, 2)
        let font = NSFont.monospacedDigitSystemFont(ofSize: max(fontSize - 2, 10), weight: .regular)
        let digitWidth = (String(repeating: "8", count: digits) as NSString).size(
            withAttributes: [.font: font]
        ).width
        gutterWidthConstraint.constant = max(38, ceil(digitWidth) + 16)
        lineNumberView.needsDisplay = true
    }
}

@MainActor
private final class MacPythonLineNumberView: NSView {
    weak var textView: NSTextView?
    var fontSize: CGFloat = 14
    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        NSColor(red: 0.058, green: 0.066, blue: 0.087, alpha: 1).setFill()
        dirtyRect.fill()
        guard let textView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else { return }
        layoutManager.ensureLayout(for: textContainer)
        let starts = PythonLineNumbers.utf16LineStarts(in: textView.string)
        let font = NSFont.monospacedDigitSystemFont(ofSize: max(fontSize - 2, 10), weight: .regular)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(red: 0.42, green: 0.47, blue: 0.58, alpha: 1),
            .paragraphStyle: paragraph
        ]
        let textLength = (textView.string as NSString).length
        let origin = textView.textContainerOrigin
        let visibleRect = textView.visibleRect

        for (offset, characterIndex) in starts.enumerated() {
            let fragment: NSRect
            if characterIndex < textLength {
                let glyphIndex = layoutManager.glyphIndexForCharacter(at: characterIndex)
                fragment = layoutManager.lineFragmentUsedRect(forGlyphAt: glyphIndex, effectiveRange: nil)
            } else {
                fragment = layoutManager.extraLineFragmentUsedRect
            }
            let y = fragment.minY + origin.y - visibleRect.minY
            let height = max(fragment.height, font.ascender - font.descender)
            guard y + height >= dirtyRect.minY, y <= dirtyRect.maxY else { continue }
            (String(offset + 1) as NSString).draw(
                in: NSRect(x: 3, y: y, width: bounds.width - 11, height: height),
                withAttributes: attributes
            )
        }

        NSColor(red: 0.18, green: 0.20, blue: 0.26, alpha: 1).setFill()
        NSRect(x: bounds.maxX - 1, y: dirtyRect.minY, width: 1, height: dirtyRect.height).fill()
    }
}

@MainActor
private struct MacPythonTextView: NSViewRepresentable {
    @Binding var text: String
    let fontSize: CGFloat
    let isEditable: Bool

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeNSView(context: Context) -> MacPythonEditorContainerView {
        let container = MacPythonEditorContainerView()
        let textView = container.textView
        textView.delegate = context.coordinator
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = isEditable
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 9, height: 14)
        textView.font = .monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = NSSize(width: 0, height: 300)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        context.coordinator.container = container
        context.coordinator.observeScrolling(in: container)
        context.coordinator.replaceText(in: textView, with: text)
        return container
    }

    func updateNSView(_ container: MacPythonEditorContainerView, context: Context) {
        context.coordinator.parent = self
        let textView = container.textView
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.allowsUndo = isEditable
        if textView.string != text {
            context.coordinator.replaceText(in: textView, with: text)
        } else {
            context.coordinator.refreshStyle(in: textView)
        }
        container.refreshLineNumbers(fontSize: fontSize)
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacPythonTextView
        weak var container: MacPythonEditorContainerView?
        private var isApplyingChanges = false

        init(parent: MacPythonTextView) { self.parent = parent }

        func observeScrolling(in container: MacPythonEditorContainerView) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(scrollBoundsDidChange),
                name: NSView.boundsDidChangeNotification,
                object: container.scrollView.contentView
            )
        }

        @objc private func scrollBoundsDidChange() {
            container?.lineNumberView.needsDisplay = true
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        func textDidChange(_ notification: Notification) {
            guard !isApplyingChanges, let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            highlight(textView)
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            let selection = textView.selectedRange()
            let edit: PythonTextEdit?
            switch commandSelector {
            case #selector(NSResponder.insertNewline(_:)):
                edit = PythonEditing.newlineEdit(in: textView.string, replacing: selection)
            case #selector(NSResponder.insertTab(_:)):
                edit = PythonEditing.indentationEdit(
                    in: textView.string,
                    selection: selection,
                    outdent: false
                )
            case #selector(NSResponder.insertBacktab(_:)):
                edit = PythonEditing.indentationEdit(
                    in: textView.string,
                    selection: selection,
                    outdent: true
                )
            case #selector(NSResponder.deleteBackward(_:)):
                edit = PythonEditing.backwardDeletionEdit(
                    in: textView.string,
                    selection: selection
                )
            default:
                return false
            }
            guard let edit else { return false }
            apply(edit, to: textView)
            return true
        }

        func textView(
            _ textView: NSTextView,
            shouldChangeTextIn affectedCharRange: NSRange,
            replacementString: String?
        ) -> Bool {
            guard let replacementString,
                  let edit = PythonEditing.closingDelimiterEdit(
                    in: textView.string,
                    selection: affectedCharRange,
                    replacement: replacementString
                  ) else { return true }
            apply(edit, to: textView)
            return false
        }

        private func apply(_ edit: PythonTextEdit, to textView: NSTextView) {
            isApplyingChanges = true
            textView.textStorage?.replaceCharacters(in: edit.range, with: edit.replacement)
            textView.setSelectedRange(edit.selectedRange)
            isApplyingChanges = false
            parent.text = textView.string
            highlight(textView)
        }

        func replaceText(in textView: NSTextView, with source: String) {
            isApplyingChanges = true
            textView.string = source
            isApplyingChanges = false
            highlight(textView)
        }

        func refreshStyle(in textView: NSTextView) {
            let currentSize = textView.font?.pointSize ?? 0
            guard abs(currentSize - parent.fontSize) > 0.1 else {
                container?.lineNumberView.needsDisplay = true
                return
            }
            highlight(textView)
        }

        private func highlight(_ textView: NSTextView) {
            guard let storage = textView.textStorage else { return }
            let selection = textView.selectedRanges
            textView.font = .monospacedSystemFont(ofSize: parent.fontSize, weight: .regular)
            PythonSyntaxHighlighter.apply(
                to: storage,
                font: .monospacedSystemFont(ofSize: parent.fontSize, weight: .regular)
            )
            textView.typingAttributes = [
                .font: NSFont.monospacedSystemFont(ofSize: parent.fontSize, weight: .regular),
                .foregroundColor: NSColor(red: 0.84, green: 0.87, blue: 0.93, alpha: 1)
            ]
            textView.selectedRanges = selection
            container?.refreshLineNumbers(fontSize: parent.fontSize)
        }
    }
}
#endif
