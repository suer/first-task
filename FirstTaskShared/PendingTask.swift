import Foundation

struct PendingTask: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let title: String
    let memo: String
    let createdAt: Date

    init(id: String = UUID().uuidString, title: String, memo: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.memo = memo
        self.createdAt = createdAt
    }
}

// Each pending task is stored in its own file so that the share extension and the app never write the same file.
struct PendingTaskStore: Sendable {
    let directoryURL: URL

    static var shared: PendingTaskStore? {
        AppGroup.containerURL.map { PendingTaskStore(directoryURL: $0.appendingPathComponent("pending-tasks", isDirectory: true)) }
    }

    func add(_ task: PendingTask) throws {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try JSONEncoder().encode(task).write(to: fileURL(for: task), options: .atomic)
    }

    func load() -> [PendingTask] {
        guard let urls = try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else { return [] }
        return
            urls
            .filter { $0.pathExtension == "json" }
            .compactMap { url in (try? Data(contentsOf: url)).flatMap { try? JSONDecoder().decode(PendingTask.self, from: $0) } }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func remove(_ task: PendingTask) {
        try? FileManager.default.removeItem(at: fileURL(for: task))
    }

    private func fileURL(for task: PendingTask) -> URL {
        directoryURL.appendingPathComponent("\(task.id).json")
    }
}
