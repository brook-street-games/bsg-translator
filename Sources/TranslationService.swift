//
//  TranslationService.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Foundation

// MARK: - Protocol -

protocol TranslationServiceProtocol {
	
	init(apiKey: String)
	func performTranslation(inputStrings: [String: String], inputLanguage: String, outputLanguage: String) async throws -> [String: String]
}

// MARK: Class -

///
/// A service for performing translation with Google Translate API.
///
public class TranslationService: TranslationServiceProtocol {
    
	// MARK: - Constants -
	
	private struct Constants {
		/// The host of the Google Translate API.
		static let apiHost = "google-translate1.p.rapidapi.com"
	}
	
    // MARK: - Properties -
    
    /// API key for RapiAPI.
    private let apiKey: String
    /// Session used for all API calls.
	private lazy var session = URLSession.shared
    
    // MARK: - Initializers -
    
    required init(apiKey: String) {
        self.apiKey = apiKey
    }
}

// MARK: - Translation -

extension TranslationService {
    
    ///
    /// Translate input strings into another language.
    /// - note: This method passes all input strings as a single parameter. Separating them was causing results to cut off ~100.
    ///
    /// - parameter inputStrings: Text to translate.
    /// - parameter inputLanguage: The ISO 639-1 code for the input language.
    /// - parameter outputLanguage: The language to translate to.
    /// - returns: A set of output strings.
    ///
	func performTranslation(inputStrings: [String: String], inputLanguage: String, outputLanguage: String) async throws -> [String: String] {
		
		let sortedInputValues = inputStrings.sorted { $0.value < $1.value }.map { $0.value }
		
        var parameters = "source=\(inputLanguage)&target=\(outputLanguage)"
		parameters = sortedInputValues.reduce(parameters) { return $0 + "&q=\($1)" }
       
        guard let url = URL(string: "https://google-translate1.p.rapidapi.com/language/translate/v2"), let body = parameters.data(using: String.Encoding.utf8) else {
            throw TranslationError.invalidParameters
        }
		
		var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = ["x-rapidapi-host": Constants.apiHost, "x-rapidapi-key": apiKey, "content-type": "application/x-www-form-urlencoded"]
		request.httpBody = body
    
		let data = try await performRequest(request)
		
		guard let result = try? JSONDecoder().decode(GoogleTranslateResponse.self, from: data) else {
			throw TranslationError.failedDecoding
		}
		
		let sortedKeys = inputStrings.sorted { $0.value < $1.value }.map { $0.key }
		
		guard sortedKeys.count == result.data.translations.count else {
			throw TranslationError.incompleteTranslation
		}
		
		var translations = [String: String]()
		for (index, key) in sortedKeys.enumerated() where result.data.translations.count > index {
			translations[key] = result.data.translations[index].translatedText
		}
		
		return translations
    }
    
    ///
    /// Perform an API call.
    ///
    /// - parameter request: The request to perform.
	/// - returns: The resulting data.
    ///
	private func performRequest(_ request: URLRequest) async throws -> Data {
        
        let (data, response) = try await session.data(for: request)
		
		guard let response = response as? HTTPURLResponse else {
			throw TranslationError.invalidResponse(statusCode: nil)
		}
				
		guard response.statusCode == 200 else {
			throw TranslationError.invalidResponse(statusCode: response.statusCode)
		}
		
		return data
    }
}

// MARK: - Nested Types -

extension TranslationService {
    
    struct GoogleTranslateResponse: Decodable {
        var data: GoogleTranslationSet
    }

    struct GoogleTranslationSet: Decodable {
        let translations: [GoogleTranslation]
    }

    struct GoogleTranslation: Decodable {
        let translatedText: String
    }
}
