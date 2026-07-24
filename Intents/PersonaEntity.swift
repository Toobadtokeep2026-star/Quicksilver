import AppIntents
import Foundation

@available(iOS 17.0, macOS 14.0, *)
public struct PersonaEntity: AppEntity {
    public static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Persona")
    public static var defaultQuery = PersonaEntityQuery()

    public var id: String
    public var displayName: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayName)")
    }

    public init(id: String, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}

@available(iOS 17.0, macOS 14.0, *)
public struct PersonaEntityQuery: EntityQuery {
    public init() {}

    public func entities(for identifiers: [String]) async throws -> [PersonaEntity] {
        identifiers.compactMap { id in
            switch id.lowercased() {
            case "forge": return PersonaEntity(id: "forge", displayName: "Forge")
            case "quicksilver": return PersonaEntity(id: "quicksilver", displayName: "Quicksilver")
            case "eternal": return PersonaEntity(id: "eternal", displayName: "Eternal")
            default: return nil
            }
        }
    }

    public func suggestedEntities() async throws -> [PersonaEntity] {
        [
            PersonaEntity(id: "quicksilver", displayName: "Quicksilver"),
            PersonaEntity(id: "forge", displayName: "Forge"),
            PersonaEntity(id: "eternal", displayName: "Eternal")
        ]
    }
}
