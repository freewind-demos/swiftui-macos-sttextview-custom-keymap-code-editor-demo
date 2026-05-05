import SwiftUI

struct EditorCommands: Commands {
    let editorState: EditorState

    var body: some Commands {
        CommandMenu("Editor") {
            ForEach(EditorAction.allCases) { action in
                Button(action.title) {
                    editorState.trigger(action)
                }
                .applyShortcut(editorState.shortcutConfig.item(for: action))
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func applyShortcut(_ item: ShortcutItem?) -> some View {
        if let shortcut = item?.keyboardShortcut {
            self.keyboardShortcut(shortcut)
        } else {
            self
        }
    }
}
