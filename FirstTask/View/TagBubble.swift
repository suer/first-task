import SwiftUI

struct TagBubble: View {
    @ObservedObject var tag: Tag

    var body: some View {
        Text(tag.name)
            .foregroundColor(Color(UIColor(named: "TagForeground")!))
            .font(.system(size: 11))
            .padding(4)
            .background(Color(UIColor(named: "TagBackground")!))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(UIColor(named: "TagBorder")!), lineWidth: 1)
        )
    }
}

struct TagBubble_Previews: PreviewProvider {
    static var previews: some View {
        let tag = Tag()
        tag.name = "重要"
        return TagBubble(tag: tag)
    }
}
