//
//  TranslationService.swift
//
//  Created by JechtShot on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Foundation

protocol TranslationServiceProtocol: Sendable {
	init(apiKey: String)
	func translate(sourceStrings: [String: String], sourceLanguage: String, targetLanguage: String) async throws -> [String: String]
}

///
/// A service for performing translation with Google Translate API.
///
public actor TranslationService: TranslationServiceProtocol {
	
    // MARK: - Properties -
    
    /// An API key from Google.
    private let apiKey: String
    /// The session used for all API calls.
	private lazy var session = URLSession.shared
    
    // MARK: - Initializers -
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
}

// MARK: - Translation -

extension TranslationService {
    
    ///
    /// Translate a set of strings into another language.
    /// - note: This method passes all source string values as &q query parameters.
    /// - parameter sourceStrings: A dictionary of text to translate (e.g. ["title": "Title Screen"])
    /// - parameter sourceLanguage: The ISO 639-1 code for the source language. (e.g. "en")
    /// - parameter targetLanguage:  The ISO 639-1 code for the target language. (e.g. "it")
    /// - returns: The source strings dictionary translated to the target language.
    ///
	func translate(sourceStrings: [String: String], sourceLanguage: String, targetLanguage: String) async throws -> [String: String] {
        var parameters = "source=\(sourceLanguage)&target=\(targetLanguage)"
        let sortedSourceValues = sourceStrings.sorted { $0.value < $1.value }.map { $0.value }
		parameters = sortedSourceValues.reduce(parameters) { return $0 + "&q=\($1)" }
       
        guard let url = URL(string: "https://translation.googleapis.com/language/translate/v2"), let body = parameters.data(using: String.Encoding.utf8) else {
            throw TranslationError.encoding
        }
		
		var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = ["x-goog-api-key": apiKey, "content-type": "application/x-www-form-urlencoded"]
		request.httpBody = body
		
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw TranslationError.response(statusCode: nil)
        }
        guard response.statusCode == 200 else {
            throw TranslationError.response(statusCode: response.statusCode)
        }
		guard let result = try? JSONDecoder().decode(GoogleTranslateResponse.self, from: data) else {
			throw TranslationError.decoding
		}
		
		let sortedKeys = sourceStrings.sorted { $0.value < $1.value }.map { $0.key }
		guard sortedKeys.count == result.data.translations.count else {
			throw TranslationError.incomplete
		}
		
		var targetStrings = [String: String]()
        for (index, key) in sortedKeys.enumerated() where result.data.translations.count > index {
            targetStrings[key] = result.data.translations[index].translatedText
        }
		return targetStrings
    }
}
