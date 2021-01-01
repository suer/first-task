import SwiftUI
import AudioToolbox

struct TaskRow: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var task: Task

    var body: some View {
        HStack {
            Circle()
                .fill(Color(task[\.completedAt] != nil
                    ? UIColor.label
                    : UIColor.systemBackground))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color(UIColor.label))
                        .frame(width: 20, height: 20)
            ).onTapGesture {
                self.vibrate()
                self.task.toggleDone()
            }
            VStack {
                HStack {
                    Text(task[\.title])
                    Spacer()
                }
                if task.allTags.count > 0 {
                    HStack {
                        ForEach(task.allTags) { tag in
                            TagBubble(tag: tag)
                        }
                        Spacer()
                    }.padding(.top, 4)
                }
            }
        }
    }

    func vibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(task: Task.make(title: "ミルクを買う"))
    }
}
