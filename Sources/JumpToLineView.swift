import SwiftUI

struct JumpToLineView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var editorState: EditorState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("跳转到指定行")
                .font(.headline)

            TextField("输入行号", text: $editorState.jumpToLineText)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("关闭") {
                    dismiss()
                }

                Spacer()

                Button("跳转") {
                    jump()
                }
                .keyboardShortcut(.return)
            }
        }
        .padding(20)
        .frame(width: 320)
    }

    private func jump() {
        guard let lineNumber = Int(editorState.jumpToLineText), lineNumber > 0 else {
            return
        }

        let text = editorState.text
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        guard lineNumber <= lines.count else {
            return
        }

        var location = 0
        for index in 0..<(lineNumber - 1) {
            location += lines[index].count + 1
        }

        guard let index = stringIndex(in: text, utf16Offset: location) else {
            return
        }

        editorState.selection = index..<index
        dismiss()
    }

    private func stringIndex(in text: String, utf16Offset: Int) -> String.Index? {
        guard let utf16Index = text.utf16.index(text.utf16.startIndex, offsetBy: utf16Offset, limitedBy: text.utf16.endIndex),
              let index = String.Index(utf16Index, within: text) else {
            return nil
        }

        return index
    }
}
