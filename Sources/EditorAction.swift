import Foundation

enum EditorAction: String, CaseIterable, Codable, Identifiable {
    case deleteLine
    case duplicateLine
    case insertLineBelow
    case insertLineAbove
    case joinLines
    case moveLineUp
    case moveLineDown
    case openFind
    case openReplace
    case jumpToLine

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .deleteLine:
            "删除当前行"
        case .duplicateLine:
            "复制行到下一行"
        case .insertLineBelow:
            "在下方插入新行"
        case .insertLineAbove:
            "在上方插入新行"
        case .joinLines:
            "合并行"
        case .moveLineUp:
            "向上移动行"
        case .moveLineDown:
            "向下移动行"
        case .openFind:
            "查找"
        case .openReplace:
            "替换"
        case .jumpToLine:
            "跳转到指定行"
        }
    }
}
