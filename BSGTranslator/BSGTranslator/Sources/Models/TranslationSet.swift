//
//  TranslationSet.swift
//
//  Created by JechtShot on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

///
/// A set of translations in a single language.
///
public struct TranslationSet: Codable, Sendable {
    public let id: Int
    public let language: String
    public let translations: [String: String]
}

// MARK: - Operations -

extension TranslationSet {
    
    ///
    /// Return any translations from the specified dictionary that are not contained in the set.
    /// - parameter translations: All dictionary of all translations to check for existence.
    /// - returns: A dictionary with all missing translations, or nil.
    ///
    func getMissingTranslations(from translations: [String: String]) -> [String: String]? {
        let missingTranslations = translations.filter { self.translations[$0.key] == nil }
        return missingTranslations.isEmpty ? nil : missingTranslations
    }
}

// MARK: - Display -

extension TranslationSet: CustomStringConvertible {
    
    ///
    /// A user-friendly description.
    ///
    public var description: String {
        var description = "Translation ID: \(id)\n"
        description += "Language: \(language)\n\n"
        description += translations.keys.sorted()
            .map{ "\($0): \(translations[$0] ?? $0)" }
            .joined(separator: "\n")
        return description
    }
}
