import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var context

    var body: some View {
        TaskList().onAppear(perform: {
            UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.badge]) { _, _ in }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, CoreDataSupport.context)
            .environmentObject(AppSettings())
    }
}
