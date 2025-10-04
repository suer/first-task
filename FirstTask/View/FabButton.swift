import SwiftUI

struct FabButton: View {
    var action: (() -> Void)?

    var body: some View {
        let accentColor = Color(UIColor(named: "Accent")!)
        let button = Button(action: {
            action?()
        }) {
            Label("Add", systemImage: "plus")
                .labelStyle(.iconOnly)
                .frame(width: 50, height: 50)
                .imageScale(.large)
                .background(accentColor)
                .foregroundColor(.white)
                .clipShape(Circle())
        }

        if #available(iOS 26.0, *) {
            button
                .glassEffect(.clear.interactive().tint(accentColor.opacity(0.5)))
        } else {
            button
        }
    }
}

struct FabButton_Previews: PreviewProvider {
    static var previews: some View {
        FabButton(action: nil)
    }
}
