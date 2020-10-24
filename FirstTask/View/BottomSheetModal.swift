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
        .edgesIgnoringSafeArea(.all)
    }

    private var background: some View {
        Color.black
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .center)
            .opacity(0.65)
            .animation(.spring())
            .gesture(TapGesture().onEnded { self.isShown = false })
    }

    private var modal: some View {
        self.content()
            .frame(width: .infinity, alignment: .top)
            .background(Color(UIColor.systemBackground))
            .keyboardAwarePadding()
    }
}
