import SwiftUI

struct ContentView: View {
    let dummyTasks = [
            Task(id: 1, title: "ミルクを買う"),
            Task(id: 2, title: "メールを返す")
    ]

    var body: some View {
        TaskList(tasks: dummyTasks)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
