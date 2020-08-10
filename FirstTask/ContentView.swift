import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var context

    var body: some View {
        TaskList()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
