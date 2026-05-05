import AppKit
import CodeEditor
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var editorState: EditorState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Picker("语言", selection: $editorState.selectedSampleID) {
                    ForEach(editorState.samples) { sample in
                        Text(sample.title).tag(sample.id)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 180)
                .onChange(of: editorState.selectedSampleID, initial: false) { _, newValue in
                    editorState.selectSample(id: newValue)
                }

                Spacer()

                Text("高亮: \(editorState.selectedSample.title)")
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .top, spacing: 16) {
                editorPane
                shortcutPane
            }
        }
        .padding(16)
        .background(ShortcutMonitorView().frame(width: 0, height: 0))
        .sheet(isPresented: $editorState.isFindPresented) {
            FindPanelView()
                .environmentObject(editorState)
        }
        .sheet(isPresented: $editorState.isReplacePresented) {
            ReplacePanelView()
                .environmentObject(editorState)
        }
        .sheet(isPresented: $editorState.isJumpToLinePresented) {
            JumpToLineView()
                .environmentObject(editorState)
        }
    }

    private var editorPane: some View {
        CodeEditor(
            source: $editorState.text,
            selection: $editorState.selection,
            language: codeEditorLanguage,
            theme: .pojoaque,
            fontSize: $editorState.fontSize,
            flags: [.selectable, .editable, .smartIndent]
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.quaternary, lineWidth: 1)
        }
        .onChange(of: editorState.pendingAction) { _, _ in
            runPendingActionIfNeeded()
        }
    }

    private var shortcutPane: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("快捷键配置")
                .font(.headline)

            ForEach(editorState.shortcutConfig.shortcuts) { item in
                HStack {
                    Text(item.action.title)
                    Spacer()
                    Text(item.shortcutLabel)
                        .foregroundStyle(.secondary)
                }
                .font(.system(size: 13, weight: .regular, design: .monospaced))
            }

            Divider()

            Text("配置文件")
                .font(.headline)

            Text("Resources/editor-shortcuts.json")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(.secondary)

            Text("改这个 JSON，再重新运行 app。")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Divider()

            Text("高亮库")
                .font(.headline)

            Text("CodeEditor + Highlightr")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .frame(width: 280, alignment: .topLeading)
    }

    private var codeEditorLanguage: CodeEditor.Language {
        switch editorState.selectedSample.language {
        case .swift:
            .swift
        case .json:
            .json
        case .markdown:
            .markdown
        }
    }

    private func runPendingActionIfNeeded() {
        guard let action = editorState.consumePendingAction() else {
            return
        }

        switch action {
        case .openFind, .openReplace, .jumpToLine:
            editorState.openPanel(for: action)
        default:
            applyEditingAction(action)
        }
    }

    private func applyEditingAction(_ action: EditorAction) {
        let nsString = NSMutableString(string: editorState.text)
        let selectedRange = NSRange(editorState.selection, in: editorState.text)
        let lineRange = nsString.lineRange(for: selectedRange)
        let lineText = nsString.substring(with: lineRange)

        switch action {
        case .deleteLine:
            nsString.replaceCharacters(in: lineRange, with: "")
            updateTextAndSelection(text: nsString as String, location: min(lineRange.location, nsString.length), length: 0)
        case .duplicateLine:
            nsString.insert(lineText, at: lineRange.upperBound)
            updateTextAndSelection(text: nsString as String, location: lineRange.upperBound, length: lineRange.length)
        case .insertLineBelow:
            nsString.insert("\n", at: lineRange.upperBound)
            updateTextAndSelection(text: nsString as String, location: min(lineRange.upperBound + 1, nsString.length), length: 0)
        case .insertLineAbove:
            nsString.insert("\n", at: lineRange.location)
            updateTextAndSelection(text: nsString as String, location: lineRange.location, length: 0)
        case .joinLines:
            joinLine(nsString, lineRange: lineRange)
        case .moveLineUp:
            moveLine(nsString, lineRange: lineRange, direction: .up)
        case .moveLineDown:
            moveLine(nsString, lineRange: lineRange, direction: .down)
        case .openFind, .openReplace, .jumpToLine:
            break
        }
    }

    private func joinLine(_ nsString: NSMutableString, lineRange: NSRange) {
        guard lineRange.upperBound < nsString.length else {
            return
        }

        let nextLineRange = nsString.lineRange(for: NSRange(location: lineRange.upperBound, length: 0))
        let currentText = nsString.substring(with: lineRange).trimmingCharacters(in: .newlines)
        let nextText = nsString.substring(with: nextLineRange).trimmingCharacters(in: .newlines)
        nsString.replaceCharacters(in: NSRange(location: lineRange.location, length: nextLineRange.upperBound - lineRange.location), with: currentText + " " + nextText + "\n")
        updateTextAndSelection(text: nsString as String, location: lineRange.location, length: currentText.count + 1 + nextText.count)
    }

    private func moveLine(_ nsString: NSMutableString, lineRange: NSRange, direction: MoveDirection) {
        let targetLocation: Int

        switch direction {
        case .up:
            guard lineRange.location > 0 else {
                return
            }
            let previousAnchor = max(lineRange.location - 1, 0)
            let previousRange = nsString.lineRange(for: NSRange(location: previousAnchor, length: 0))
            let movingText = nsString.substring(with: lineRange)
            let previousText = nsString.substring(with: previousRange)
            nsString.replaceCharacters(in: NSRange(location: previousRange.location, length: lineRange.upperBound - previousRange.location), with: movingText + previousText)
            targetLocation = previousRange.location
        case .down:
            guard lineRange.upperBound < nsString.length else {
                return
            }
            let nextRange = nsString.lineRange(for: NSRange(location: lineRange.upperBound, length: 0))
            let movingText = nsString.substring(with: lineRange)
            let nextText = nsString.substring(with: nextRange)
            nsString.replaceCharacters(in: NSRange(location: lineRange.location, length: nextRange.upperBound - lineRange.location), with: nextText + movingText)
            targetLocation = nextRange.upperBound - lineRange.length
        }

        updateTextAndSelection(text: nsString as String, location: targetLocation, length: max(0, lineRange.length - 1))
    }

    private func updateTextAndSelection(text: String, location: Int, length: Int) {
        editorState.text = text

        guard let start = stringIndex(in: text, utf16Offset: location),
              let end = stringIndex(in: text, utf16Offset: location + length) else {
            editorState.selection = text.endIndex..<text.endIndex
            return
        }

        editorState.selection = start..<end
    }

    private func stringIndex(in text: String, utf16Offset: Int) -> String.Index? {
        guard let utf16Index = text.utf16.index(text.utf16.startIndex, offsetBy: utf16Offset, limitedBy: text.utf16.endIndex),
              let index = String.Index(utf16Index, within: text) else {
            return nil
        }

        return index
    }
}

private enum MoveDirection {
    case up
    case down
}
