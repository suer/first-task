import SwiftUI

struct BottomSheetModal<Content: View>: View {
    @Binding var isShown: Bool

    var content: () -> Content

    var body: some View {
        ZStack(alignment: .bottom) {
            if isShown {
                background
                modal
            }
        }
        .animation(.spring(), value: isShown)
    }

    private var background: some View {
        Color.black
            .opacity(0.65)
            .onTapGesture { self.isShown = false }
    }

    private var modal: some View {
        self.content()
            .padding(.bottom)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(Color(UIColor.systemBackground))
            .keyboardAwarePadding()
            .transition(.move(edge: .bottom))
    }
}
