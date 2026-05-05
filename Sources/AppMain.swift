import SwiftUI

@main
struct CodeEditorCustomKeymapDemoApp: App {
    @StateObject private var editorState = EditorState()

    var body: some Scene {
        Window("CodeEditor Custom Keymap Demo", id: "main") {
            ContentView()
                .environmentObject(editorState)
        }
        .defaultSize(width: 1180, height: 760)
        .commands {
            EditorCommands(editorState: editorState)
        }
    }
}
