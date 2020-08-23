import SwiftUI
import MobileCoreServices

struct TagList: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var task: Task
    @State var showAddTagModal = false
    @State var newTagName = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(task.allTags) { tag in
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
                            _ = Tag.create(context: self.viewContext, task: self.task, name: self.newTagName)
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
        let context = CoreDataSupport.context
        return TagList(task: Task.make(context: context, id: UUID(), title: "test")).environment(\.managedObjectContext, context)
    }
}
