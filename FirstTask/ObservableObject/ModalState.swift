import SwiftUI

class ModalState: ObservableObject {
    @Published var showingEditModal = false
    @Published var showingSearchModal = false
}
