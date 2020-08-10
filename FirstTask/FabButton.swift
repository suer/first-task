import SwiftUI

struct FabButton: View {
    var action: (() -> ())?

    var body: some View {
        Button(action: {
            if let action = self.action {
                action()
            }
        }) {
            Image(systemName: "pencil")
                .frame(width: 50, height: 50)
                .imageScale(.large)
                .background(Color(UIColor(red: 33/255, green: 125/255, blue: 251/255, alpha: 1.0)))
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
