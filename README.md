# SwiftUI macOS 自定义快捷键代码编辑器

## 简介

这个 Demo 用 SwiftUI 做一个 macOS 代码编辑器。

编辑器基于成熟第三方库 `CodeEditor`，底层接 `Highlightr` 做语法高亮。

重点不是只把 editor 放进去，而是把一组你常用的 editor 快捷键抽到外部 JSON config，让 demo 能改键。

## 快速开始

### 环境要求

- macOS 14+
- Xcode 15+
- XcodeGen

### 运行

```bash
cd swiftui-macos-sttextview-custom-keymap-code-editor-demo
chmod +x scripts/build.sh
xcodegen generate
open SwiftUIMacOSCodeEditorCustomKeymapDemo.xcodeproj
```

也可以命令行构建：

```bash
./scripts/build.sh
```

## 概念讲解

### 第三方 editor 选型

这里不用原生 `TextEditor`，而是直接接：

```swift
CodeEditor(
    source: $editorState.text,
    selection: $editorState.selection,
    language: codeEditorLanguage,
    theme: .pojoaque
)
```

这样直接拿到：

- 可编辑文本
- 语法高亮
- 外部可控选区
- smart indent

`CodeEditor` 已经把 SwiftUI 编辑器包装和高亮接好了，更适合快速验证“高亮 + 可配置快捷键”。

### 快捷键外置配置

快捷键不写死在视图里，而是放到：

```json
{
  "shortcuts": [
    {
      "action": "deleteLine",
      "key": "y",
      "modifiers": ["command"]
    }
  ]
}
```

路径：

```text
Resources/editor-shortcuts.json
```

App 启动时读取这个文件，映射成：

- 动作类型 `EditorAction`
- 按键 `key`
- 修饰键 `modifiers`

这样你后面只要改 JSON，就能调整 demo 的快捷键绑定。

### 从你的快捷键里挑 editor 相关动作

这个 demo 先接了这些和编辑器强相关的动作：

- `Cmd + Y` 删除当前行
- `Cmd + D` 复制行到下一行
- `Shift + Enter` 在下方插入新行
- `Cmd + Option + Enter` 在上方插入新行
- `Ctrl + Shift + J` 合并行
- `Shift + Option + Up` 向上移动行
- `Shift + Option + Down` 向下移动行
- `Cmd + F` 查找
- `Cmd + R` 替换
- `Cmd + G` 跳转到指定行

这些都来自你给的快捷键列表里，且都属于 editor 本身就该负责的范围。

## 完整示例

核心结构：

```swift
CodeEditor(
    source: $editorState.text,
    selection: $editorState.selection,
    language: codeEditorLanguage,
    theme: .pojoaque
)
```

外部 config：

```json
{
  "shortcuts": [
    {
      "action": "duplicateLine",
      "key": "d",
      "modifiers": ["command"]
    }
  ]
}
```

命令菜单绑定：

```swift
Button(action.title) {
    editorState.trigger(action)
}
.applyShortcut(editorState.shortcutConfig.item(for: action))
```

本地键盘事件拦截：

```swift
monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
    guard let self, let handler = self.handler else {
        return event
    }

    return handler(event) ? nil : event
}
```

这三层合起来，效果是：

1. editor 有成熟第三方高亮能力
2. 菜单快捷键能显示
3. 你的 keymap 能从 JSON 改

## 注意事项

- 这是 editor demo，不是完整 IDE
- 当前没接 LSP、诊断、补全、format
- `Cmd + B`、`Shift + F6` 这类依赖语义分析或项目索引的动作，这个 demo 没硬做假实现
- 若你要继续扩展，可在 `EditorAction` 里继续加动作

## 完整讲解（中文）

这次需求里，真正难点不是“SwiftUI 里放一个能高亮的 editor”，而是“这个 editor 的快捷键要能按你的习惯走，而且最好还能配”。

如果只求高亮，仓库里原本那个 `CodeEditor` demo 已经够了。但它没有把按键系统单独抽出来。所以这里重新起一个 demo，保留成熟 editor，本轮重点补“快捷键配置层”。

高亮这层没有自己造，而是直接复用 `CodeEditor` 底下的 `Highlightr`。对 Swift、JSON、Markdown 这种内容已经够演示。

快捷键这层我拆成三部分。第一部分是 `EditorAction`，把“删除行、复制行、插入行、移动行、查找、替换、跳行”这些动作先抽象成固定 action。第二部分是 `editor-shortcuts.json`，把 action 跟具体按键配置绑定。第三部分是运行时桥接：一边在菜单里注册快捷键，一边用 `NSEvent.addLocalMonitorForEvents` 兜住本地 keyDown，这样用户按键时能真实触发动作。

这样做的好处是，demo 的“编辑器能力”和“你的键位习惯”被拆开了。以后你若要继续换键，不需要回 Swift 源码里改事件判断，优先改 JSON 就行。若你还想继续加更多动作，比如“选择下一个匹配项”“重命名”“触发 quick fix”，就继续往 `EditorAction` 和对应处理逻辑里扩。
