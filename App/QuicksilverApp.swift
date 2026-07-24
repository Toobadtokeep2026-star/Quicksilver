import SwiftUI

/// Quicksilver application entry point.
/// Day One: Minimal shell with dependency injection and environment injection.
@main
struct QuicksilverApp: App {
    @State private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container)
                .preferredColorScheme(.dark) // Aligns with Quicksilver's intelligent, slightly chaotic aesthetic while remaining HIG-compliant
        }
    }
}
