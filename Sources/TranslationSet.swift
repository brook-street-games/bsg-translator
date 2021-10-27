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
    /// Returns any missing translations from the specified set.
    ///
    /// - parameter queryTranslation: The translations to check for existance.
    /// - returns: A dictionary with all missing translations, or nil.
    ///
    func getMissingTranslations(in testTranslations: [String: String]) -> [String: String]? {
        
        let missingTranslations = testTranslations.filter { self.translations[$0.key] == nil }
        return missingTranslations.isEmpty ? nil : missingTranslations
    }
}

// MARK: - CustomStringConvertible -

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
