import AppKit
import SwiftUI

struct ShortcutMonitorView: NSViewRepresentable {
    @EnvironmentObject private var editorState: EditorState

    func makeNSView(context: Context) -> ShortcutMonitorNSView {
        let view = ShortcutMonitorNSView()
        view.handler = handle
        return view
    }

    func updateNSView(_ nsView: ShortcutMonitorNSView, context: Context) {
        nsView.handler = handle
    }

    private func handle(_ event: NSEvent) -> Bool {
        let normalizedFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        guard let item = editorState.shortcutConfig.shortcuts.first(where: {
            $0.nsModifiers == normalizedFlags && $0.matches(characters: event.charactersIgnoringModifiers)
        }) else {
            return false
        }

        editorState.trigger(item.action)
        return true
    }
}

final class ShortcutMonitorNSView: NSView {
    var handler: ((NSEvent) -> Bool)?

    private var monitor: Any?

    deinit {
        removeMonitor()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        if window == nil {
            removeMonitor()
            return
        }

        installMonitorIfNeeded()
    }

    private func installMonitorIfNeeded() {
        guard monitor == nil else {
            return
        }

        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, let handler = self.handler else {
                return event
            }

            return handler(event) ? nil : event
        }
    }

    private func removeMonitor() {
        guard let monitor else {
            return
        }

        NSEvent.removeMonitor(monitor)
        self.monitor = nil
    }
}

private extension ShortcutItem {
    func matches(characters: String?) -> Bool {
        switch key {
        case ShortcutKey.returnSymbol:
            characters == "\r"
        case ShortcutKey.upArrow:
            characters == String(UnicodeScalar(NSUpArrowFunctionKey)!)
        case ShortcutKey.downArrow:
            characters == String(UnicodeScalar(NSDownArrowFunctionKey)!)
        default:
            characters?.lowercased() == key.lowercased()
        }
    }
}
