import Foundation

enum ShortcutConfigLoader {
    static func load() -> ShortcutConfig {
        guard let url = Bundle.main.url(forResource: "editor-shortcuts", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(ShortcutConfig.self, from: data) else {
            return .fallback
        }

        return config
    }
}
