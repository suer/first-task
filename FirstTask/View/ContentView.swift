import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var context

    var body: some View {
        TopView().onAppear(perform: {
            UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.badge]) { _, _ in }

            CreateTodayTag().call()
            AddTodayTag().call()
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
