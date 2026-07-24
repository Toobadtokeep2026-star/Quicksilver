import Foundation

/// Loads persona system prompts from the app bundle (Resources/Personas).
/// Falls back to the embedded defaults in PersonaConfiguration if the file is missing.
/// This keeps long prompt text out of Swift source while remaining fully offline.
enum PromptManager {

    /// Returns the system prompt for a given persona ID.
    /// Prefers the external file; falls back to the embedded string.
    static func systemPrompt(for personaID: String, fallback: String) -> String {
        if let loaded = loadFromBundle(personaID: personaID) {
            return loaded
        }
        return fallback.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func loadFromBundle(personaID: String) -> String? {
        // Look for Resources/Personas/<id>.txt inside the main bundle
        guard let url = Bundle.main.url(
            forResource: personaID,
            withExtension: "txt",
            subdirectory: "Personas"
        ) ?? Bundle.main.url(forResource: personaID, withExtension: "txt") else {
            return nil
        }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
