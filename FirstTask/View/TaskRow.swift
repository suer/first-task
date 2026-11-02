import SwiftUI
import UIKit

struct TaskRow: View {
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var task: Task

    var body: some View {
        HStack {
            Image(systemName: task.completedAt != nil ? "checkmark.circle" : "circle")
                .font(.system(size: 20))
                .fontWeight(.light)
                .foregroundColor(Color(.label))
                .onTapGesture {
                    self.vibrate()
                    self.task.toggleDone()
                }
            Text(task.title)
                .lineLimit(2)
            ForEach(task.allTags(tags: appSettings.tags)) { tag in
                TagBubble(tag: tag)
                    .fixedSize()
                    .layoutPriority(1)
            }
            Spacer()
        }
    }

    func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        TaskRow(task: Task.make(title: "ミルクを買う"))
    }
}
