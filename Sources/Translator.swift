//
//  Translator.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Foundation

// MARK: - Delegate -

public protocol TranslatorDelegate: AnyObject {
    
    /// Called when translation completes, regardless of if an API call was made.
    func translator(_ translator: Translator, didCompleteTranslation result: Result<TranslationSet, TranslationError>)
    /// Called when a loggable event occurs. The delegate may then log the event accordingly.
    func translator(_ translator: Translator, didEncounterLogEvent logEvent: String)
}

public extension TranslatorDelegate {
    
	func translator(_ translator: Translator, didCompleteTranslation result: Result<TranslationSet, TranslationError>) {}
    func translator(_ translator: Translator, didEncounterLogEvent logEvent: String) {}
}

// MARK: - Class -

public class Translator {
    
	// MARK: - Constants -
	
	public struct Constants {
		/// The cache directory.
		public static let diskCacheDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("bsg/translator")
	}
	
    // MARK: - Public Properties -
    
    /// The ISO 639-1 code of the input language. https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes.
    private(set) public var inputLanguage: String
	/// The ISO 639-1 code of the output language. The default value is the language set in iOS settings. When this value is changed, *updateTranslations(_:)* must be called.
	public var outputLanguage: String
	/// Optional delegate method handler.
	public weak var delegate: TranslatorDelegate?
	
    // MARK: - Private Properties -
    
	/// Determines the source of input strings.
	private var inputType: InputType
    /// The current set of translated text.
    private var currentTranslationSet: TranslationSet?
    /// The service used to perform translation.
    private let translationService: TranslationService
	/// The file manager instance used for caching to disk.
	private lazy var fileManager = FileManager.default
    
    // MARK: - Setup -
    
    ///
    /// Required initial configuration.
    ///
    /// - parameter apiKey: An API key for Google Translate API. See the README for instructions on how to get one.
    /// - parameter inputLanguage: The ISO 639-1 code of the input language. https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes.
    /// - parameter inputType: Determines the source of input strings.
	/// - parameter outputLanguage: The ISO 639-1 code of the output language. The default value is the language set in iOS settings.
    /// - parameter delegate: Optional delegate method handler.
    ///
	public init(apiKey: String, inputLanguage: String, inputType: InputType, outputLanguage: String = String(Locale.preferredLanguages.first!.prefix(2)), delegate: TranslatorDelegate? = nil) {
        
        self.inputLanguage = inputLanguage
		self.inputType = inputType
		self.outputLanguage = outputLanguage
        self.delegate = delegate
        self.translationService = TranslationService(apiKey: apiKey)
		
		createCacheDirectory()
    }
}

// MARK: - Retrieval -

extension Translator {
    
    public enum CapitalizationStyle {
		
        /// No adjustment.
        case none
        /// Capitalize the first letter of the first word.
        case first
        /// Captitalize the first letter of each word.
        case allFirst
        /// Capitalize all letters.
        case all
    }
    
    ///
    /// Get a translation for a specified key in the output language. If no translation is found, the key is returned.
    ///
    /// - parameter key: The key for the translation.
    /// - parameter capitalization: The formatting for the translation.
    ///
    /// - returns: Text translated to output language.
    ///
    public func translate(_ key: String, capitalization: CapitalizationStyle = .first) -> String {
        
        guard let translation = currentTranslationSet?.translations[key] else { return key }
        
        switch capitalization {
        case .none: return translation
        case .first: return translation.prefix(1).capitalized + translation.dropFirst()
        case .allFirst: return translation.capitalized
        case .all: return translation.uppercased()
        }
    }
}

// MARK: - Input Strings -

extension Translator {
    
    public enum InputType {
		
        /// Input strings will be read from a bundled .strings file.
        case stringsFile(fileName: String)
        /// Input strings will be supplied manually.
        case manual(inputStrings: [String: String])
    }
    
    ///
    /// Get input strings from the appropriate location based on *inputType*.
    ///
    private func getInputStrings() throws -> [String: String] {
        
        switch inputType {
            
        case .stringsFile(let fileName):
            guard let stringsFilePath = Bundle.main.path(forResource: fileName, ofType: "strings") else { throw TranslationError.invalidStringFile(fileName) }
			guard let inputStrings = NSDictionary(contentsOfFile: stringsFilePath) as? [String: String], !inputStrings.isEmpty else { throw TranslationError.emptyStringsFile(fileName) }
            return inputStrings
            
        case .manual(let inputStrings):
            guard !inputStrings.isEmpty else { throw TranslationError.missingInputStrings }
            return inputStrings
        }
    }
}

// MARK: - Cache -

extension Translator {
    
	///
	/// Create a directory for disk cache.
	///
	private func createCacheDirectory() {
		
		do {
			try fileManager.createDirectory(at: Constants.diskCacheDirectory, withIntermediateDirectories: true, attributes: [:])
		} catch {
			fatalError("Invalid disk cache directory.")
		}
	}
	
    ///
    /// Get a translation set from cache.
    ///
    /// - parameter language: The ISO 639-1 code of the language to get translations for.
    /// - returns: A translation set for the language, if available.
    ///
    private func getCachedTranslationSet(for language: String) -> TranslationSet? {
        
		guard let data = fileManager.contents(atPath: Constants.diskCacheDirectory.appendingPathComponent(language).path) else { return nil }
		return try? JSONDecoder().decode(TranslationSet.self, from: data)
    }
    
    ///
    /// Cache a translation set.
    ///
    /// - parameter translationSet: The translation set to cache.
    ///
    private func setCachedTranslationSet(_ translationSet: TranslationSet) {
        
        guard let data = try? JSONEncoder().encode(translationSet) else { return }
		
		let filePath = Constants.diskCacheDirectory.appendingPathComponent(translationSet.language)
		fileManager.createFile(atPath: filePath.path, contents: data)
    }
}

// MARK: - Translation -

extension Translator {

	///
	/// Translate input strings to a translation set in the output language. This method uses caching to avoid making excess API calls. If the output language matches the input language, no translation is needed and the input strings will be returned. If a cached translation set from a previous API call satisfies the requirements, it will be returned. Otherwise, this method will reach out to Google Translate API and cache the result. This result can be handled with async/await, or with the delegate method translator(_:didCompletionTranslation).
	///
	/// - parameter translationId: An optional ID for a translation set. A cached translation set must meet or exceed the supplied ID to be considered valid. For example, a client could keep track of the last ID used and only increment it when changes have been made to the input strings. If nil is supplied, any saved translation set matching the output language will be considered valid. Nil is the default.
	///
	public func updateTranslations(translationId: Int? = nil) {
		
		guard delegate != nil else { fatalError("Translator must have a delegate to use this method.") }
		Task { try await updateTranslations(translationId: translationId) }
	}
	
    ///
    /// Translate input strings to a translation set in the output language. This method uses caching to avoid making excess API calls. If the output language matches the input language, no translation is needed and the input strings will be returned. If a cached translation set from a previous API call satisfies the requirements, it will be returned. Otherwise, this method will reach out to Google Translate API and cache the result. This result can be handled with async/await, or with the delegate method translator(_:didCompletionTranslation).
    ///
    /// - parameter translationId: An optional ID for a translation set. A cached translation set must meet or exceed the supplied ID to be considered valid. For example, a client could keep track of the last ID used and only increment it when changes have been made to the input strings. If nil is supplied, any saved translation set matching the output language will be considered valid. Nil is the default.
    ///
	@discardableResult
    @MainActor public func updateTranslations(translationId: Int? = nil) async throws -> TranslationSet {
        
		do {
			let inputStrings = try getInputStrings()
			let translationId = translationId ?? 0
			
			if outputLanguage == inputLanguage {
				// Input language matches output language.
				delegate?.translator(self, didEncounterLogEvent: #"Input language "\#(outputLanguage)" matches output language "\#(outputLanguage)". Returning input strings."#)
				let inputTranslationSet = TranslationSet(id: translationId, language: outputLanguage, translations: inputStrings)
				currentTranslationSet = inputTranslationSet
				delegate?.translator(self, didCompleteTranslation: .success(inputTranslationSet))
				return inputTranslationSet
				
			} else if let savedTranslationSet = getCachedTranslationSet(for: outputLanguage) {
				
				if translationId > savedTranslationSet.id {
					// The cached translation set is considered invalid based on translation ID.
					delegate?.translator(self, didEncounterLogEvent: #"Provided translation ID (\#(translationId)) is higher than the cached translation set (\#(savedTranslationSet.id)). Performing translation for "\#(outputLanguage)"."#)
					return try await performTranslation(inputStrings, outputLanguage: outputLanguage, translationId: translationId)
					
				} else if let missingInputStrings = savedTranslationSet.getMissingTranslations(from: inputStrings) {
					// Additional input strings have been found.
					delegate?.translator(self, didEncounterLogEvent: #"Cached translation set is missing some keys (\#(missingInputStrings.keys). Performing translation for "\#(outputLanguage)"."#)
					return try await performTranslation(inputStrings, outputLanguage: outputLanguage, translationId: translationId)
					
				} else {
					// A valid translation set was found in cache.
					delegate?.translator(self, didEncounterLogEvent: #"Found cached translation set for "\#(outputLanguage)". Returning cached translations."#)
					currentTranslationSet = savedTranslationSet
					delegate?.translator(self, didCompleteTranslation: .success(savedTranslationSet))
					return savedTranslationSet
				}
			} else {
				// No cached translation set was found for the output language.
				delegate?.translator(self, didEncounterLogEvent: #"No cached translation set found. Performing translation for "\#(outputLanguage)"."#)
				return try await performTranslation(inputStrings, outputLanguage: outputLanguage, translationId: translationId)
			}
		} catch {
			
			let error = error as? TranslationError ?? TranslationError.unknown
			delegate?.translator(self, didCompleteTranslation: .failure(error))
			throw error
		}
    }
    
    ///
    /// Send an API request to perform translation.
    ///
    /// - parameter inputStrings: The text to translate.
    /// - parameter outputLanguage: The ISO 639-1 code for the output language.
    /// - parameter translationId: The translation ID.
    ///
	@MainActor private func performTranslation(_ inputStrings: [String: String], outputLanguage: String, translationId: Int) async throws -> TranslationSet {
		
		let translations = try await translationService.performTranslation(inputStrings: inputStrings, inputLanguage: inputLanguage, outputLanguage: outputLanguage)
		
		let translationSet = TranslationSet(id: translationId, language: outputLanguage, translations: translations)
		setCachedTranslationSet(translationSet)
		currentTranslationSet = translationSet
		
		delegate?.translator(self, didCompleteTranslation: .success(translationSet))
		return translationSet
    }
}
