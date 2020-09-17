import SwiftUI

class ModalState: ObservableObject {
    @Published var showingEditModal = false
    @Published var showingSettingMenuModal = false
    @Published var showingSearchModal = false
}
