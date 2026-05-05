import SwiftUI

struct FindPanelView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var editorState: EditorState
    @State private var query = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("查找")
                .font(.headline)

            TextField("输入关键字", text: $query)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("关闭") {
                    dismiss()
                }

                Spacer()

                Button("查找下一个") {
                    selectNextMatch()
                }
                .keyboardShortcut(.return)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private func selectNextMatch() {
        let text = editorState.text
        guard !query.isEmpty,
              let range = text.range(of: query) else {
            return
        }

        editorState.selection = range
        dismiss()
    }
}
