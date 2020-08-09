import SwiftUI

struct BottomSheetModal<Content: View>: View {
  @Binding var isShown: Bool
  @Binding var height: CGFloat

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
  }

  private var modal: some View {
    self.content()
      .frame(width: UIScreen.main.bounds.width, height: height, alignment: .top)
      .background(Color.white)
      .cornerRadius(10)
  }
}
