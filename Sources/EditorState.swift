import AppKit
import Foundation

@MainActor
final class EditorState: ObservableObject {
    @Published var text: String
    @Published var selection: Range<String.Index>
    @Published var selectedSampleID: String
    @Published var pendingAction: EditorAction?
    @Published var isFindPresented = false
    @Published var isReplacePresented = false
    @Published var isJumpToLinePresented = false
    @Published var jumpToLineText = ""
    @Published var fontSize: CGFloat = 14

    let samples: [CodeSample]
    let shortcutConfig: ShortcutConfig

    init(
        samples: [CodeSample] = DemoSamples.all,
        shortcutConfig: ShortcutConfig = ShortcutConfigLoader.load()
    ) {
        self.samples = samples
        self.shortcutConfig = shortcutConfig
        let firstSample = samples.first ?? CodeSample(id: "empty", title: "Empty", language: .swift, text: "")
        self.selectedSampleID = firstSample.id
        self.text = firstSample.text
        self.selection = firstSample.text.endIndex..<firstSample.text.endIndex
    }

    var selectedSample: CodeSample {
        samples.first(where: { $0.id == selectedSampleID }) ?? samples[0]
    }

    func selectSample(id: String) {
        guard let sample = samples.first(where: { $0.id == id }) else {
            return
        }

        selectedSampleID = id
        text = sample.text
        selection = sample.text.endIndex..<sample.text.endIndex
    }

    func trigger(_ action: EditorAction) {
        pendingAction = action
    }

    func consumePendingAction() -> EditorAction? {
        defer { pendingAction = nil }
        return pendingAction
    }

    func openPanel(for action: EditorAction) {
        switch action {
        case .openFind:
            isFindPresented = true
        case .openReplace:
            isReplacePresented = true
        case .jumpToLine:
            isJumpToLinePresented = true
        default:
            break
        }
    }
}
