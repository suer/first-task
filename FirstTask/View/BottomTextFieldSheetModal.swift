import SwiftUI

struct BottomTextFieldSheetModal: View {
    @Binding var isShown: Bool
    @Binding var text: String
    var action: () -> Void

    init(isShown: Binding<Bool>, text: Binding<String>, action: @escaping () -> Void) {
        _isShown = isShown
        _text = text
        self.action = action
    }

    var body: some View {
        BottomSheetModal(isShown: self.$isShown) {
            GeometryReader { geometry in
                HStack {
                    FocusableTextField(text: self.$text, onCommit: { _ in
                        self.action()
                        self.$text.wrappedValue = ""
                    }, isFirstResponder: true)
                        .frame(width: geometry.size.width - 40, height: 50)
                        .keyboardType(.default)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        self.action()
                        self.$text.wrappedValue = ""
                        UIApplication.shared.closeKeyboard()
                    }) {
                        Image(systemName: "arrow.up")
                            .frame(width: 40, height: 40)
                            .imageScale(.large)
                            .background(Color(UIColor(named: "Accent")!))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
            .frame(height: 80)
        }
    }
}
