import Foundation

/// Core identity contract for all Quicksilver personas.
/// Personas remain pure data + behavioral intent.
/// UI rendering and AI model calls stay outside this layer to preserve modularity.
protocol Persona: Sendable, Identifiable {
    var id: String { get }
    var name: String { get }
    var shortDescription: String { get }
    var systemPrompt: String { get }
    var accentColorName: String { get } // Semantic name for future theming; no UIKit/SwiftUI coupling here
}

extension Persona {
    /// Convenience for logging and analytics.
    var debugDescription: String {
        "\(name) (\(id))"
    }
}
