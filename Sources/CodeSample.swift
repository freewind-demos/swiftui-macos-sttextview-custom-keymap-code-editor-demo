import Foundation

struct CodeSample: Identifiable, Hashable {
    let id: String
    let title: String
    let language: EditorLanguage
    let text: String
}

enum DemoSamples {
    static let all: [CodeSample] = [
        CodeSample(
            id: "swift",
            title: "Swift",
            language: .swift,
            text: """
            import Foundation

            struct User: Codable {
                let id: Int
                let name: String
            }

            func greet(_ users: [User]) -> String {
                users.map(\\.name).joined(separator: ", ")
            }

            let users = [
                User(id: 1, name: "Ada"),
                User(id: 2, name: "Linus"),
            ]

            print(greet(users))
            """
        ),
        CodeSample(
            id: "json",
            title: "JSON",
            language: .json,
            text: """
            {
              "editor": "CodeEditor",
              "features": [
                "syntax-highlight",
                "custom-shortcuts",
                "swiftui"
              ],
              "enabled": true
            }
            """
        ),
        CodeSample(
            id: "markdown",
            title: "Markdown",
            language: .markdown,
            text: """
            # Editor Demo

            - `Cmd + Y` 删除当前行
            - `Cmd + D` 复制当前行到下一行
            - `Shift + Enter` 在下方插入新行

            这些快捷键来自外部 JSON config。
            """
        ),
    ]
}
