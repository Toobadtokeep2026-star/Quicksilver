import Foundation

/// Single source of truth for available personas.
struct PersonaRegistry: Sendable {
    private let configurations: [String: PersonaConfiguration]

    init(configurations: [PersonaConfiguration] = PersonaConfiguration.all) {
        var map: [String: PersonaConfiguration] = [:]
        for config in configurations {
            map[config.id] = config
        }
        self.configurations = map
    }

    var all: [PersonaConfiguration] {
        Array(configurations.values).sorted { $0.id < $1.id }
    }

    func configuration(for id: String) -> PersonaConfiguration? {
        configurations[id]
    }

    func contains(id: String) -> Bool {
        configurations[id] != nil
    }

    func require(id: String) throws -> PersonaConfiguration {
        guard let config = configurations[id] else {
            throw AppError.personaUnavailable(id)
        }
        return config
    }
}
