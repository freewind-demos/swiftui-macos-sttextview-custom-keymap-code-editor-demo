import AppKit
import Foundation
import SwiftUI

struct ShortcutConfig: Codable {
    let shortcuts: [ShortcutItem]

    func item(for action: EditorAction) -> ShortcutItem? {
        shortcuts.first { $0.action == action }
    }

    static let fallback = ShortcutConfig(
        shortcuts: [
            ShortcutItem(action: .deleteLine, key: "y", modifiers: [.command]),
            ShortcutItem(action: .duplicateLine, key: "d", modifiers: [.command]),
            ShortcutItem(action: .insertLineBelow, key: ShortcutKey.returnSymbol, modifiers: [.shift]),
            ShortcutItem(action: .insertLineAbove, key: ShortcutKey.returnSymbol, modifiers: [.command, .option]),
            ShortcutItem(action: .joinLines, key: "j", modifiers: [.control, .shift]),
            ShortcutItem(action: .moveLineUp, key: ShortcutKey.upArrow, modifiers: [.shift, .option]),
            ShortcutItem(action: .moveLineDown, key: ShortcutKey.downArrow, modifiers: [.shift, .option]),
            ShortcutItem(action: .openFind, key: "f", modifiers: [.command]),
            ShortcutItem(action: .openReplace, key: "r", modifiers: [.command]),
            ShortcutItem(action: .jumpToLine, key: "g", modifiers: [.command]),
        ]
    )
}

struct ShortcutItem: Codable, Identifiable {
    let action: EditorAction
    let key: String
    let modifiers: [ShortcutModifier]

    var id: String {
        action.rawValue
    }

    var nsModifiers: NSEvent.ModifierFlags {
        modifiers.reduce(into: NSEvent.ModifierFlags()) { partial, item in
            partial.insert(item.nsModifier)
        }
    }

    var shortcutLabel: String {
        let prefix = modifiers
            .sorted(by: { $0.sortOrder < $1.sortOrder })
            .map(\.symbol)
            .joined()
        return prefix + keyDisplay
    }

    var keyDisplay: String {
        switch key {
        case ShortcutKey.returnSymbol:
            "↩"
        case ShortcutKey.upArrow:
            "↑"
        case ShortcutKey.downArrow:
            "↓"
        default:
            key.uppercased()
        }
    }

    var keyboardShortcut: KeyboardShortcut? {
        guard let keyEquivalent = KeyEquivalent(shortcutKey: key) else {
            return nil
        }

        return KeyboardShortcut(keyEquivalent, modifiers: eventModifiers.toSwiftUI)
    }

    var eventModifiers: EventModifiers {
        modifiers.reduce(into: EventModifiers()) { partial, item in
            partial.insert(item.eventModifier)
        }
    }
}

enum ShortcutModifier: String, CaseIterable, Codable {
    case command
    case shift
    case option
    case control

    var nsModifier: NSEvent.ModifierFlags {
        switch self {
        case .command:
            .command
        case .shift:
            .shift
        case .option:
            .option
        case .control:
            .control
        }
    }

    var eventModifier: EventModifiers {
        switch self {
        case .command:
            .command
        case .shift:
            .shift
        case .option:
            .option
        case .control:
            .control
        }
    }

    var symbol: String {
        switch self {
        case .command:
            "⌘"
        case .shift:
            "⇧"
        case .option:
            "⌥"
        case .control:
            "⌃"
        }
    }

    var sortOrder: Int {
        switch self {
        case .control:
            0
        case .option:
            1
        case .shift:
            2
        case .command:
            3
        }
    }
}

enum ShortcutKey {
    static let returnSymbol = "return"
    static let upArrow = "upArrow"
    static let downArrow = "downArrow"
}

private extension EventModifiers {
    var toSwiftUI: EventModifiers {
        self
    }
}

private extension KeyEquivalent {
    init?(shortcutKey: String) {
        switch shortcutKey {
        case ShortcutKey.returnSymbol:
            self = .return
        case ShortcutKey.upArrow:
            self = .upArrow
        case ShortcutKey.downArrow:
            self = .downArrow
        default:
            guard let character = shortcutKey.lowercased().first else {
                return nil
            }
            self = KeyEquivalent(character)
        }
    }
}
