//
//  Translator.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Foundation

// MARK: - Delegate -

public protocol TranslatorDelegate: AnyObject {
    
    /// Called when translations have been obtained for the target language, regardless of if an API call was made.
    func translator(_ translator: Translator, didReceiveTranslationSet translationSet: TranslationSet)
    /// Called whenever a loggable event occurs. The delegate may then log the event accordingly.
    func translator(_ translator: Translator, didEncounterLogEvent logEvent: String)
    /// Called when an error is encountered.
    func translator(_ translator: Translator, didEncounterError error: TranslationError)
}

public extension TranslatorDelegate {
    
    func translator(_ translator: Translator, didEncounterLogEvent logEvent: String) {}
}

// MARK: - Class -

public class Translator {
    
    // MARK: - Private Properties -
    
    /// The development language.
    private var inputLanguage: String
    /// Determines what to use as translation source.
    private var inputType: InputType
    /// The strings sent out for translation.
    private var inputStrings: [String: String] = [:]
    /// The alpha2 code of the language set in iOS settings.
    private var settingsLanguage: String {
        guard let preferredLanguage = Locale.preferredLanguages.first else { return inputLanguage }
        return String(preferredLanguage.prefix(2))
    }
    /// All available translations.
    private var currentTranslationSet: TranslationSet?
    /// Service to interact with Google Translate.
    private var translationService: TranslationService
    /// Object that handles events from *translator*.
    public weak var delegate: TranslatorDelegate?
    
    // MARK: - Setup -
    
    ///
    /// Required initial configuration.
    ///
    /// - parameter apiKey: A valid key for Google Translate API.
    /// - parameter inputLanguage: The alpha2 code of the language of the source strings to translate.
    /// - parameter inputType: Specifies where the source strings should be found.
    /// - parameter delegate: Optional object to handle events fired by the translator.
    ///
    public init(apiKey: String, inputLanguage: String, inputType: InputType, delegate: TranslatorDelegate? = nil) {
        
        self.inputLanguage = inputLanguage
        self.inputType = inputType
        self.delegate = delegate
        self.translationService = TranslationService(apiKey: apiKey)
    }
}

// MARK: - Retreival -

extension Translator {
    
    public enum CapitalizationStyle {
        /// Returns the translation without any adjustment.
        case none
        /// Capitalizes the first letter of the translated string.
        case first
        /// Captitalizes the first letter of each word in the translated string.
        case allFirst
        /// Capitalizes all letters in the translated string.
        case all
    }
    
    ///
    /// Searches available translations for one matching the key.
    ///
    /// - parameter key: The key used as an identifier for the translation.
    /// - parameter capitalization: The formatting of the translation.
    ///
    /// - returns: Text translated to target language if found, otherwise returns the key.
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

// MARK: - Source Strings -

extension Translator {
    
    public enum InputType {
        /// Source strings will be read from a bundled .strings file.
        case stringsFile(fileName: String)
        /// Source strings will be supplied manually.
        case manual(inputStrings: [String: String])
    }
    
    ///
    /// Gets source strings from the appropriate location based on *sourceType*.
    ///
    private func getInputStrings() throws -> [String: String] {
        
        switch inputType {
            
        case .stringsFile(let fileName):
            guard let stringsFilePath = Bundle.main.path(forResource: fileName, ofType: "strings") else { throw TranslationError(type: .missingSourceStrings, additionalInfo: "Could not find file named \(fileName).string") }
            guard let inputStrings = NSDictionary(contentsOfFile: stringsFilePath) as? [String: String], !inputStrings.isEmpty else { throw TranslationError(type: .missingSourceStrings) }
            return inputStrings
            
        case .manual(let inputStrings):
            guard inputStrings.isEmpty else { throw TranslationError(type: .missingSourceStrings, additionalInfo: "Input strings cannot be empty.") }
            return inputStrings
        }
    }
}

// MARK: - Cache -

extension Translator {
    
    ///
    /// Gets a translation set from local cache.
    ///
    /// - parameter targetLanguage: The alpha2 code of the language to get translations for.
    /// - returns: A translation set for the target language, if available.
    ///
    private func getCachedTranslationSet(for targetLanguage: String) -> TranslationSet? {
        
        guard let savedData = UserDefaults.standard.object(forKey: "\(Key.translationSet)_\(targetLanguage)") as? Data else { return nil }
        return try? JSONDecoder().decode(TranslationSet.self, from: savedData)
    }
    
    ///
    /// Saves a translation set to local cache.
    ///
    /// - parameter translationSet: The translation set to save.
    /// - parameter language: The alpha2 code for the language to save translations for.
    ///
    private func setCachedTranslationSet(_ translationSet: TranslationSet) {
        
        guard let data = try? JSONEncoder().encode(translationSet) else { return }
        UserDefaults.standard.set(data, forKey: "\(Key.translationSet)_\(translationSet.language)")
    }
}

// MARK: - Translation -

extension Translator {
    
    ///
    /// Translates all source strings into strings in the desired language. If the target language matches the source language, the source strings will be returned directly. If an available cache from a previous call to the Google Translate API satisfies the language and ID requirements, it will be used to avoid making an unessessary API call. If no translation set can satisfy the parameters, this method will reach out to Google Translate API and cache the response. Delegate method translator(_:didReceiveTranslationSet) will be called when a set is obtained.
    ///
    /// - parameter targetLanguage: An optional alpha2 language code. If nil is passed here, the iOS setting language will be used. Nil is the default.
    /// - parameter translationId: An optional ID for a translation set. If a local translation set with an ID greater than the minimum is not found, a new API call will be made. For example, a client could keep track of the last translationId used and only update it when changes have been made to the input strings to force a new translation. If no minimum ID is specified, any saved translation set matching the target language will be returned. On successful translation, the new translationId is saved to compare against next time. Nil is the default.
    ///
    public func updateTranslations(targetLanguage: String? = nil, translationId: Int? = nil) {
        
        do {
            inputStrings = try getInputStrings()
            let targetLanguage = targetLanguage ?? settingsLanguage
            let translationId = translationId ?? 0
            
            if targetLanguage == inputLanguage {
                // Target language matches source language.
                delegate?.translator(self, didEncounterLogEvent: #"Using source language "\#(targetLanguage)". Returning source strings."#)
                let sourceTranslationSet = TranslationSet(id: translationId, language: targetLanguage, translations: inputStrings)
                currentTranslationSet = sourceTranslationSet
                delegate?.translator(self, didReceiveTranslationSet: sourceTranslationSet)
                
            } else if let savedTranslationSet = getCachedTranslationSet(for: targetLanguage) {
                
                if translationId > savedTranslationSet.id {
                    // Translations are considered outdated based on minimum translation ID.
                    delegate?.translator(self, didEncounterLogEvent: #"Outdated translation ID requires an update (\#(savedTranslationSet.id) -> \#(translationId)). Running Google translate for "\#(targetLanguage)"."#)
                    googleTranslate(inputStrings, targetLanguage: targetLanguage, translationId: translationId)
                } else if let missingInputStrings = savedTranslationSet.getMissingTranslations(in: inputStrings) {
                    // Additional input strings have been found.
                    delegate?.translator(self, didEncounterLogEvent: #"Additional input strings found since last translation (\#(missingInputStrings.keys). Running Google translate for "\#(targetLanguage)"."#)
                    googleTranslate(inputStrings, targetLanguage: targetLanguage, translationId: translationId)
                } else {
                    // A saved set of translations satisfying *targetLanguage* and *minimumTranslationId* was found.
                    delegate?.translator(self, didEncounterLogEvent: #"Found saved translations for "\#(targetLanguage)". ID = \#(savedTranslationSet.id)"#)
                    currentTranslationSet = savedTranslationSet
                    delegate?.translator(self, didReceiveTranslationSet: savedTranslationSet)
                }
                
            } else {
                // Translation ID was not outdated, but no saved translation set found. User could have changed to another new language.
                delegate?.translator(self, didEncounterLogEvent: #"No saved translations found. Running Google translate for "\#(targetLanguage)"."#)
                googleTranslate(inputStrings, targetLanguage: targetLanguage, translationId: translationId)
            }
            
        } catch {
            let error = error as? TranslationError ?? TranslationError(type: .unknown)
            delegate?.translator(self, didEncounterError: error)
        }
    }
    
    ///
    /// Sends API request to Google Translate.
    ///
    /// - parameter sourceStrings: The raw strings to translate.
    /// - parameter targetLanguage: The alpha2 code of the language to translate to.
    /// - parameter minimumTranslationId: The translation ID.
    ///
    private func googleTranslate(_ inputStrings: [String: String], targetLanguage: String, translationId: Int) {
        
        let sortedInputValues = inputStrings.sorted { $0.value < $1.value }.map { $0.value }
        translationService.getGoogleTranslation(for: sortedInputValues, inputLanguage: inputLanguage, targetLanguage: targetLanguage, completion: { result in
            
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let translationResponse):
                    self.delegate?.translator(self, didEncounterLogEvent: "Google Translate: SUCCESS")
                    self.handleTranslationResponse(translationResponse, targetLanguage: targetLanguage, translationId: translationId)
                    
                case .failure(let error):
                    self.delegate?.translator(self, didEncounterLogEvent: "Google Translate: FAILURE")
                    self.delegate?.translator(self, didEncounterError: error)
                }
            }
        })
    }
    
    ///
    /// Handles a response from Google Translate API.
    ///
    /// - parameter response: The decoded API response.
    /// - parameter targetLanguage: The language that the source strings were translated to.
    ///
    private func handleTranslationResponse(_ response: TranslationService.GoogleTranslateResponse, targetLanguage: String, translationId: Int) {
        
        let sortedKeys = inputStrings.sorted { $0.value < $1.value }.map { $0.key }
        
        guard sortedKeys.count == response.data.translations.count else {
            delegate?.translator(self, didEncounterError: TranslationError(type: .incompleteTranslation))
            return
        }
        
        var translations = [String: String]()
        for (index, key) in sortedKeys.enumerated() {
            
            guard response.data.translations.count > index else { break }
            translations[key] = response.data.translations[index].translatedText
        }
        
        let translationSet = TranslationSet(id: translationId, language: targetLanguage, translations: translations)
        setCachedTranslationSet(translationSet)
        currentTranslationSet = translationSet
        
        delegate?.translator(self, didReceiveTranslationSet: translationSet)
    }
}
