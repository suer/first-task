import SwiftUI

struct SettingMenuView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var sessionState = SessionState()

    @State var showingFirebaseUIView = false

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
                    if !sessionState.isSignedIn {
                        Button(action: {
                            self.showingFirebaseUIView.toggle()
                        }) {
                            HStack {
                                Image(systemName: "person")
                                Text("Sign in with Google")
                                Spacer()
                            }.contentShape(Rectangle())
                        }.sheet(isPresented: $showingFirebaseUIView) {
                            FirebaseUIView()
                        }.buttonStyle(PlainButtonStyle())
                    } else {
                        Button(action: {
                            try? sessionState.signOut()
                        }) {
                            HStack {
                                Image(systemName: "person")
                                Text("Sign out from \(sessionState.email)")
                                Spacer()
                            }.contentShape(Rectangle())
                        }.buttonStyle(PlainButtonStyle())
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
