import Foundation
import SwiftUI

/// Central dependency injection container for Quicksilver.
/// Keeps object graph explicit, testable, and free of global state pollution.
/// All major subsystems are created here and injected via environment or initializers.
@MainActor
final class DependencyContainer: ObservableObject {
    // MARK: - Configuration
    let configuration: AppConfiguration

    // MARK: - Personas
    private(set) var activePersona: any Persona

    // MARK: - Nexus
    let nexus: NexusCoordinator

    // MARK: - Init
    init(
        configuration: AppConfiguration = .shared,
        initialPersona: any Persona = QuicksilverPersona()
    ) {
        self.configuration = configuration
        self.activePersona = initialPersona
        self.nexus = NexusCoordinator()
    }

    // MARK: - Persona Switching (future expansion point)
    func switchPersona(to persona: any Persona) {
        activePersona = persona
        objectWillChange.send()
    }
}
