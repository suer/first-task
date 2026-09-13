import SwiftUI

struct SettingMenuView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var showTagView = false
    @State private var showCompletedTaskList = false

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
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        showCompletedTaskList = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text(.completedTasks)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.semibold))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(.settings)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showTagView) {
                TagView()
            }
            .navigationDestination(isPresented: $showCompletedTaskList) {
                CompletedTaskList()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .frame(width: 40, height: 40)
                            .imageScale(.large)
                            .foregroundColor(.secondary)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(Text(.close))
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
