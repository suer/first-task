enum TaskListType {
    case inbox
    case today
    case project
    case tag

    func icon() -> String {
        return switch self {
        case .inbox: "tray"
        case .today: "star"
        case .project: "flag"
        case .tag: "tag"
        }
    }

    func subtitle() -> String? {
        return switch self {
        case .inbox, .today: nil
        case .project: String(localized: .projects)
        case .tag: String(localized: .tags)
        }
    }
}
