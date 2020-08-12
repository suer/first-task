import SwiftUI

struct FabButton: View {
    var action: (() -> ())?

    var body: some View {
        Button(action: {
            if let action = self.action {
                action()
            }
        }) {
            Image(systemName: "plus")
                .frame(width: 50, height: 50)
                .imageScale(.large)
                .background(Color(UIColor(named: "Accent")!))
                .foregroundColor(.white)
                .clipShape(Circle())
        }
    }
}

struct FabButton_Previews: PreviewProvider {
    static var previews: some View {
        FabButton(action: nil)
    }
}
