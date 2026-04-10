import SwiftUI

struct SettingMenuView: View {
    @Environment(\.presentationMode) var presentationMode

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
                            Text(.tags)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.semibold))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(.settings)
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
                            .foregroundColor(Color(.accent))
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
