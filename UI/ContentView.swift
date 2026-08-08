import SwiftUI
import Core

struct ContentView: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        SanctumView(container: container)
    }
}
