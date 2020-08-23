import SwiftUI

struct SettingMenuView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: TagView().environment(\.managedObjectContext, self.viewContext)) {
                        HStack {
                            Image(systemName: "tag")
                            Text("Tags")
                        }
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 40, height: 40)
                    .imageScale(.large)
                    .foregroundColor(Color(UIColor(named: "Accent")!))
                    .clipShape(Circle())
            })
        }
    }
}

struct SettingMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SettingMenuView()
    }
}
