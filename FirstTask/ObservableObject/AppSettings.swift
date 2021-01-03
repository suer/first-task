import SwiftUI

class AppSettings: ObservableObject {
    @Published var showAddTaskModal: Bool = false
    @Published var tags: [Tag] = []
}
