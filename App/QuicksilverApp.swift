import SwiftUI

/// Quicksilver application entry point.
/// Day One: Minimal shell with dependency injection and environment object injection.
@main
struct QuicksilverApp: App {
    @StateObject private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
                .preferredColorScheme(.dark) // Aligns with Quicksilver's intelligent, slightly chaotic aesthetic while remaining HIG-compliant
        }
    }
}
