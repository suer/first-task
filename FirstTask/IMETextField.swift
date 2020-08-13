import UIKit
import SwiftUI

// from https://qiita.com/nkmrh/items/56f0241c2e34532bdcfa

final class IMETextFieldCoordinator: NSObject, UITextFieldDelegate {
    var control: IMETextField
    
    init(_ control: IMETextField) {
        self.control = control
        super.init()
        control.textField.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: .editingDidBegin)
        control.textField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: .editingDidEnd)
        control.textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        control.textField.addTarget(self, action: #selector(textFieldEditingDidEndOnExit(_:)), for: .editingDidEndOnExit)
    }
    
    @objc private func textFieldEditingDidBegin(_ textField: UITextField) {
        control.onEditingChanged(true)
    }
    
    @objc private func textFieldEditingDidEnd(_ textField: UITextField) {
        control.onEditingChanged(false)
    }
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        control.text = textField.text ?? ""
    }
    
    @objc private func textFieldEditingDidEndOnExit(_ textField: UITextField) {
        control.onCommit()
    }
}

struct IMETextField: UIViewRepresentable {
    
    private let title: String?
    @Binding var text: String
    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void
    
    let textField = UITextField()
    
    init(title: String?, text: Binding<String>, onEditingChanged: @escaping (Bool) -> Void = { _ in }, onCommit: @escaping () -> Void = {}) {
        self.title = title
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    func makeCoordinator() -> IMETextFieldCoordinator {
        IMETextFieldCoordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        textField.placeholder = title
        textField.text = text
        textField.delegate = context.coordinator
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
    }
}
