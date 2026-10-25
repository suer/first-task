import Foundation
import Testing

@testable import FirstTask

struct WidgetSnapshotTests {

    private let snapshot = WidgetSnapshot(
        tasks: [
            WidgetTask(id: "1", title: "inbox 2", projectId: "", tagIds: [], displayOrder: 2),
            WidgetTask(id: "2", title: "inbox 1", projectId: "", tagIds: [], displayOrder: 1),
            WidgetTask(id: "3", title: "project", projectId: "p1", tagIds: ["today"], displayOrder: 0),
            WidgetTask(id: "4", title: "tagged", projectId: "p2", tagIds: ["t1"], displayOrder: 0),
        ],
        projects: [WidgetProject(id: "p1", title: "Project 1")],
        tags: [
            WidgetTag(id: "today", name: "today", kind: "today"),
            WidgetTag(id: "t1", name: "Tag 1", kind: ""),
        ]
    )

    @Test
    func inboxReturnsTasksWithoutProjectSortedByDisplayOrder() {
        #expect(snapshot.tasks(for: .inbox).map(\.id) == ["2", "1"])
    }

    @Test
    func todayReturnsTasksWithTodayTag() {
        #expect(snapshot.tasks(for: .today).map(\.id) == ["3"])
    }

    @Test
    func todayIsEmptyWithoutTodayTag() {
        let withoutTodayTag = WidgetSnapshot(tasks: snapshot.tasks, projects: [], tags: [])
        #expect(withoutTodayTag.tasks(for: .today).isEmpty)
    }

    @Test
    func projectAndTagFilterById() {
        #expect(snapshot.tasks(for: .project(id: "p1")).map(\.id) == ["3"])
        #expect(snapshot.tasks(for: .tag(id: "t1")).map(\.id) == ["4"])
    }

    @Test(arguments: [
        WidgetListKind.inbox,
        .today,
        .project(id: "p1"),
        .tag(id: "t1"),
        .project(id: "id with/special chars"),
    ])
    func urlRoundTrips(kind: WidgetListKind) throws {
        let url = try #require(kind.url)
        #expect(WidgetListKind(url: url) == kind)
    }

    @Test
    func urlRejectsUnknownLinks() throws {
        #expect(WidgetListKind(url: try #require(URL(string: "org.codefirst.firsttask://list/unknown"))) == nil)
        #expect(WidgetListKind(url: try #require(URL(string: "org.codefirst.firsttask://other/inbox"))) == nil)
        #expect(WidgetListKind(url: try #require(URL(string: "https://example.com/list/inbox"))) == nil)
    }
}
