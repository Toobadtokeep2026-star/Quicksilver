import SwiftUI

@main
struct QuicksilverApp: App {
    @State private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container)
                .preferredColorScheme(.dark)
        }
    }
}
