import SwiftUI

struct BottomSheetModal<Content: View>: View {
    @Binding var isShown: Bool

    var content: () -> Content

    var body: some View {
        ZStack(alignment: .bottom) {
            if isShown {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture { self.isShown = false }

                self.content()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(), value: isShown)
    }
}
