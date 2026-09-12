import SwiftUI

struct BottomSheetModal<Content: View>: View {
    @Binding var isShown: Bool

    var content: () -> Content

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .sheet(isPresented: $isShown) {
                self.content()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
    }
}
