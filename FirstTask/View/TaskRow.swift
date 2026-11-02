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
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(task.title)
                        .lineLimit(2)
                    ForEach(task.allTags(tags: appSettings.tags)) { tag in
                        TagBubble(tag: tag)
                            .fixedSize()
                            .layoutPriority(1)
                    }
                }
                if !task.memo.isEmpty {
                    Text(Self.linkedMemo(task.memo))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
    }

    static func linkedMemo(_ memo: String) -> AttributedString {
        var attributed = AttributedString(memo)
        guard
            let detector = try? NSDataDetector(
                types: NSTextCheckingResult.CheckingType.link.rawValue)
        else { return attributed }
        let fullRange = NSRange(location: 0, length: (memo as NSString).length)
        for match in detector.matches(in: memo, range: fullRange) {
            guard let url = match.url, let range = Range(match.range, in: attributed) else {
                continue
            }
            attributed[range].link = url
            attributed[range].foregroundColor = .secondary
            attributed[range].underlineStyle = .single
        }
        return attributed
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
