import SwiftUI

@main
struct QuicksilverApp: App {
    @State private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            SanctumView(container: container)
                .environment(container)
                .preferredColorScheme(.dark)
        }
    }
}
