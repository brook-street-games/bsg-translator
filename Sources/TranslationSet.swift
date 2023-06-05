//
//  TranslationSet.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

///
/// Contains a set of translations in a specific language.
///
public struct TranslationSet: Codable {
    
    public let id: Int
    public let language: String
    public var translations: [String: String]
}

// MARK: - Operations -

extension TranslationSet {
    
    ///
    /// Return any missing translations from the specified set.
    ///
    /// - parameter translations: The translations to check for existance.
    /// - returns: A dictionary with all missing translations, or nil.
    ///
    func getMissingTranslations(from translations: [String: String]) -> [String: String]? {
        
        let missingTranslations = translations.filter { self.translations[$0.key] == nil }
        return missingTranslations.isEmpty ? nil : missingTranslations
    }
}

// MARK: - Display -

extension TranslationSet: CustomStringConvertible {
    
    /// A user-friendly description of the translation set.
    public var description: String {
        
        var description = "Translation ID: \(id)\n"
        description += "Language: \(language)\n\n"
        let sortedKeys = translations.keys.sorted()
        description += sortedKeys.reduce("") { $0 + "\($1): \(translations[$1] ?? $1)\n" }
        
        return description
    }
}
