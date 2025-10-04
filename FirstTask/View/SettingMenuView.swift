import SwiftUI

struct SettingMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var sessionState = SessionState()

    @State var showingFirebaseUIView = false
    @State private var showTagView = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button(action: {
                        showTagView = true
                    }) {
                        HStack {
                            Image(systemName: "tag")
                            Text("Tags")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.semibold))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                    }
                    .buttonStyle(.plain)
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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showTagView) {
                TagView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .frame(width: 40, height: 40)
                            .imageScale(.large)
                            .foregroundColor(Color(UIColor(named: "Accent")!))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

struct SettingMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SettingMenuView()
    }
}
