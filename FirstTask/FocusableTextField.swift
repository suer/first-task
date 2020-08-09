import SwiftUI

struct FocusableTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        let onTextFieldShouldEndEditing: (String) -> ()
        var didBecomeFirstResponder = false

        init(text: Binding<String>, onTextFieldShouldEndEditing: @escaping (String) -> ()) {
            _text = text
            self.onTextFieldShouldEndEditing = onTextFieldShouldEndEditing
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            onTextFieldShouldEndEditing(text)
            return true
        }
    }

    @Binding var text: String
    let onTextFieldShouldEndEditing: (String) -> ()
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<FocusableTextField>) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.borderStyle = .roundedRect
        return textField
    }

    func makeCoordinator() -> FocusableTextField.Coordinator {
        return Coordinator(text: $text, onTextFieldShouldEndEditing: onTextFieldShouldEndEditing)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<FocusableTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
