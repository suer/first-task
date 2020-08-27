import SwiftUI

struct FocusableTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        let onCommit: (String) -> Void
        var didBecomeFirstResponder = false

        init(text: Binding<String>, onCommit: @escaping (String) -> Void) {
            _text = text
            self.onCommit = onCommit
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            if textField.markedTextRange == nil {
                text = textField.text ?? ""
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.onCommit(text)
            return true
        }
    }

    @Binding var text: String
    let onCommit: (String) -> Void
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<FocusableTextField>) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        return textField
    }

    func makeCoordinator() -> FocusableTextField.Coordinator {
        return Coordinator(text: $text, onCommit: onCommit)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<FocusableTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // XXX: workaround crash on TagList view
                uiView.becomeFirstResponder()
                context.coordinator.didBecomeFirstResponder = true
            }
        }
    }
}
