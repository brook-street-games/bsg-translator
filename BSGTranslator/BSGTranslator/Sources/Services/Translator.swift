//
//  Translator.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Foundation

@MainActor
public final class Translator {
    
	// MARK: - Constants -
	
	public struct Constants {
		/// The cache directory.
		public static let diskCacheDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("bsg/translator")
	}
	
    // MARK: - Properties -
    
    /// The current set of translated text.
    private var currentTranslationSet: TranslationSet?
    /// The file manager instance used for caching to disk.
    private lazy var fileManager = FileManager.default
    /// The ISO 639-1 code for the source language.
    private(set) public var sourceLanguage: String
    /// Determines where to get source strings.
    private var sourceType: SourceType
	/// The ISO 639-1 code for the target language.
	public var targetLanguage: String
    /// The service used to perform translation.
    private let translationService: TranslationServiceProtocol
    
    // MARK: - Initializers -
    
    ///
    /// Required initial configuration.
    /// - parameter apiKey: An API key for Google Translate API. See the README for instructions on how to get one.
    /// - parameter sourceLanguage: The ISO 639-1 code for the source language. (e.g. "en") See https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes.
    /// - parameter sourceType: Determines where to get source strings.
    /// - parameter targetLanguage:  The ISO 639-1 code for the target language. (e.g. "it") The default value is the language set in iOS settings.
    ///
	public init(apiKey: String, sourceLanguage: String, sourceType: SourceType, targetLanguage: String = String(Locale.preferredLanguages.first!.prefix(2))) {
        self.sourceLanguage = sourceLanguage
		self.sourceType = sourceType
		self.targetLanguage = targetLanguage
        self.translationService = TranslationService(apiKey: apiKey)
		createCacheDirectory()
    }
    
    ///
    /// Used for internal testing only.
    ///
    init(sourceLanguage: String, sourceType: SourceType, targetLanguage: String, translationService: TranslationServiceProtocol) {
        self.sourceLanguage = sourceLanguage
        self.sourceType = sourceType
        self.targetLanguage = targetLanguage
        self.translationService = translationService
        createCacheDirectory()
    }
}

// MARK: - Source Strings -

extension Translator {
    
    public enum SourceType {
        /// Source strings will be read from a bundled *.strings* file.
        case stringsFile(fileName: String)
        /// Source strings will be supplied manually.
        case manual(sourceStrings: [String: String])
    }
    
    private func getSourceStrings() throws -> [String: String] {
        switch sourceType {
        case .stringsFile(let fileName):
            guard let stringsFilePath = Bundle.main.path(forResource: fileName, ofType: "strings") else { throw TranslationError.missing(fileName) }
			guard let sourceStrings = NSDictionary(contentsOfFile: stringsFilePath) as? [String: String], !sourceStrings.isEmpty else { throw TranslationError.empty(fileName) }
            return sourceStrings
        case .manual(let sourceStrings):
            guard !sourceStrings.isEmpty else { throw TranslationError.empty("source strings") }
            return sourceStrings
        }
    }
}

// MARK: - Translation -

extension Translator {
	
    ///
    /// Translate source strings to the target language if needed. This method will avoid an API call in the following cases:
    /// 1. The target language matches the source language.
    /// 2. A valid cached translation set is found.
    /// Otherwise, this method will reach out to Google Translate API and cache the result.
    /// - parameter translationId: An optional integer that a translation set must meet or exceed to be considered valid.
    /// - returns: A translation set.
    ///
    @discardableResult
    public func updateTranslations(translationId: Int? = nil) async throws -> TranslationSet {
        let sourceStrings = try getSourceStrings()
        let translationId = translationId ?? 0
        
        if sourceLanguage == targetLanguage {
            let sourceTranslationSet = TranslationSet(id: translationId, language: targetLanguage, translations: sourceStrings)
            currentTranslationSet = sourceTranslationSet
            return sourceTranslationSet
        } else if let cachedTranslationSet = getCachedTranslationSet(for: targetLanguage) {
            guard cachedTranslationSet.id >= translationId && cachedTranslationSet.getMissingTranslations(from: sourceStrings) == nil else {
                return try await translate(sourceStrings, targetLanguage: targetLanguage, translationId: translationId)
            }
            currentTranslationSet = cachedTranslationSet
            return cachedTranslationSet
        } else {
            return try await translate(sourceStrings, targetLanguage: targetLanguage, translationId: translationId)
        }
    }
    
    private func translate(_ sourceStrings: [String: String], targetLanguage: String, translationId: Int) async throws -> TranslationSet {
        let targetStrings = try await translationService.translate(sourceStrings: sourceStrings, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
        let translationSet = TranslationSet(id: translationId, language: targetLanguage, translations: targetStrings)
        self.setCachedTranslationSet(translationSet)
        self.currentTranslationSet = translationSet
        return translationSet
    }
}

// MARK: - Cache -

extension Translator {
    
    private func createCacheDirectory() {
        do {
            try fileManager.createDirectory(at: Constants.diskCacheDirectory, withIntermediateDirectories: true, attributes: [:])
        } catch {
            fatalError("Invalid disk cache directory.")
        }
    }
    
    private func getCachedTranslationSet(for language: String) -> TranslationSet? {
        guard let data = fileManager.contents(atPath: Constants.diskCacheDirectory.appendingPathComponent(language).path) else { return nil }
        return try? JSONDecoder().decode(TranslationSet.self, from: data)
    }
    
    private func setCachedTranslationSet(_ translationSet: TranslationSet) {
        guard let data = try? JSONEncoder().encode(translationSet) else { return }
        let filePath = Constants.diskCacheDirectory.appendingPathComponent(translationSet.language)
        fileManager.createFile(atPath: filePath.path, contents: data)
    }
    
    func clearCache() {
        if let contents = try? fileManager.contentsOfDirectory(at: Constants.diskCacheDirectory, includingPropertiesForKeys: nil) {
            for file in contents {
                try? fileManager.removeItem(at: file)
            }
        }
    }
}

// MARK: - Retrieval -

extension Translator {
    
    public enum CapitalizationStyle {
        /// Return the result unaltered.
        case none
        /// Capitalize the first letter of the first word.
        case first
        /// Captitalize the first letter of each word.
        case allFirst
        /// Capitalize all letters.
        case all
    }
    
    ///
    /// Get a translation for a specified key in the target language. If no translation is found, the key is returned.
    /// - parameter key: The translation key.
    /// - parameter capitalization: The formatting for the translation.
    /// - returns: A translated string value.
    ///
    public func getTranslatedValue(for key: String, capitalization: CapitalizationStyle = .first) -> String {
        guard let translation = currentTranslationSet?.translations[key] else { return key }
        switch capitalization {
        case .none: return translation
        case .first: return translation.prefix(1).capitalized + translation.dropFirst()
        case .allFirst: return translation.capitalized
        case .all: return translation.uppercased()
        }
    }
    
    public subscript(_ key: String, capitalization: CapitalizationStyle = .first) -> String {
        getTranslatedValue(for: key, capitalization: .first)
    }
}
