import SwiftUI

struct FabButton: View {
    var action: (() -> Void)?

    var body: some View {
        let button = Button(action: {
            action?()
        }) {
            Label(.add, systemImage: "plus")
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .frame(width: 50, height: 50)
        }
        .buttonBorderShape(.circle)

        if #available(iOS 26.0, *) {
            button.buttonStyle(.glassProminent)
        } else {
            button.buttonStyle(.borderedProminent)
        }
    }
}

struct FabButton_Previews: PreviewProvider {
    static var previews: some View {
        FabButton(action: nil)
    }
}
