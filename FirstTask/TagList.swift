import SwiftUI
import MobileCoreServices

struct TagList: View {
    let task: Task
    @State var tags: [Tag]
    @State var showAddTagModal = false
    @State var newTagName = ""

    init(task: Task) {
        self.task = task
        self._tags = State.init(initialValue: task.allTags)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(tags) { tag in
                    Text(tag.name ?? "")
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FabButton {
                        self.showAddTagModal = true
                    }
                }.padding(10)
            }.padding(10)

            BottomSheetModal(isShown: $showAddTagModal) {
                GeometryReader { geometry in
                    HStack {
                        FocusableTextField(text: self.$newTagName, isFirstResponder: true) { _ in }
                            .frame(width: geometry.size.width - 40, height: 50)
                            .keyboardType(.default)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: {
                            if let tag = Tag.create(task: self.task, name: self.newTagName) {
                                self.tags = self.task.allTags
                            }
                            self.$newTagName.wrappedValue = ""
                            self.showAddTagModal = false

                            UIApplication.shared.closeKeyboard()
                        }) {
                            Image(systemName: "arrow.up")
                                .frame(width: 40, height: 40)
                                .imageScale(.large)
                                .background(Color(UIColor(named: "Accent")!))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .frame(height: 80)
            }
        }
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        TagList(task: Task.make(id: UUID(), title: "test"))
    }
}
