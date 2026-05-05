import SwiftUI

struct ReplacePanelView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var editorState: EditorState
    @State private var findText = ""
    @State private var replaceText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("替换")
                .font(.headline)

            TextField("查找", text: $findText)
                .textFieldStyle(.roundedBorder)

            TextField("替换为", text: $replaceText)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("关闭") {
                    dismiss()
                }

                Spacer()

                Button("全部替换") {
                    replaceAll()
                }
                .keyboardShortcut(.return)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private func replaceAll() {
        guard !findText.isEmpty else {
            return
        }

        let source = editorState.text
        let replaced = source.replacingOccurrences(of: findText, with: replaceText)
        editorState.text = replaced
        editorState.selection = replaced.endIndex..<replaced.endIndex
        dismiss()
    }
}
