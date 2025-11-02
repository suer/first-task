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
                    FocusableTextField(
                        text: self.$text,
                        onCommit: { _ in
                            self.onCommit()
                        }, isFirstResponder: true
                    )
                    .frame(width: geometry.size.width - 40, height: 50)
                    .keyboardType(.default)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: {
                        self.onCommit()
                    }) {
                        let accentColor = Color(UIColor(named: "Accent")!)
                        let button = Label("Add", systemImage: "arrow.up")
                            .labelStyle(.iconOnly)
                            .frame(width: 40, height: 40)
                            .imageScale(.large)
                            .background(accentColor)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                        if #available(iOS 26.0, *) {
                            button
                                .glassEffect(.clear.interactive().tint(accentColor.opacity(0.5)))
                        } else {
                            button
                        }
                    }
                }
            }
            .padding()
            .frame(height: 80)
        }
    }

    private func onCommit() {
        guard self.$text.wrappedValue != "" else { return }
        self.action()
        self.$text.wrappedValue = ""
    }
}
