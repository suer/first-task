import SwiftUI
import Firebase

class AppSettings: ObservableObject {
    @Published var showAddTaskModal: Bool = false
    @Published var tags: [Tag] = []
}
