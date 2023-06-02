//
//  TranslationService.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Foundation

///
/// Used for making calls to and getting data from Google Translate API.
///
public class TranslationService {
    
	typealias GoogleTranslateResponseResultHandler = (Result<TranslationService.GoogleTranslateResponse, TranslationError>) -> Void
	typealias DataResultHandler = (Result<Data, TranslationError>) -> Void
	
    // MARK: - Properties -
    
    /// The host of the Google Translate API.
    private let apiHost = "google-translate1.p.rapidapi.com"
    /// User-specific API key given by RapiAPI.
    private let apiKey: String
    /// Session used for all API calls.
    private lazy var session = URLSession.shared
    
    // MARK: - Setup -
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
}

// MARK: - Translation -

extension TranslationService {
    
    ///
    /// Translates an array of input strings into another language.
    /// - warning: This method passes all input strings as a single parameter. Separating them was causing results to cut off ~100.
    ///
    /// - parameter inputStrings: Strings in the input language to translate.
    /// - parameter inputLanguage: The alpha2 code for the language of *inputStrings*.
    /// - parameter targetLanguage: The language to translate to.
    /// - parameter completion: The completion handler.
    ///
    func getGoogleTranslation(for inputStrings: [String], inputLanguage: String = "en", targetLanguage: String, completion: GoogleTranslateResponseResultHandler?) {

        var parameters = "source=\(inputLanguage)&target=\(targetLanguage)"
        parameters = inputStrings.reduce(parameters) { return $0 + "&q=\($1)" }
       
        guard let url = URL(string: "https://google-translate1.p.rapidapi.com/language/translate/v2"), let postData = parameters.data(using: String.Encoding.utf8) else {
            completion?(.failure(TranslationError(type: .invalidParameters)))
            return
        }
    
        performRequest(url: url, body: postData, apiKey: apiKey, completion: { result in
            
            switch result {
                
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(GoogleTranslateResponse.self, from: data)
                    completion?(.success(response))
                } catch {
                    let errorResponse = try? JSONDecoder().decode(GoogleTranslateErrorResponse.self, from: data)
                    completion?(.failure(TranslationError(type: .failedDecoding, additionalInfo: errorResponse?.message)))
                }
                
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }
    
    ///
    /// Generic method for making an API call to any endpoint.
    /// - note: Currently all endpoints use Rapid API key.
    ///
    /// - parameter url: The endpoint of the call.
    /// - parameter body: Optional additional info.
    /// - parameter apiKey: The key from API provider.
	/// - parameter completion: The completion handler.
    ///
    private func performRequest(url: URL, body: Data? = nil, apiKey: String, completion: DataResultHandler?) {
        
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["x-rapidapi-host": apiHost, "x-rapidapi-key": apiKey, "content-type": "application/x-www-form-urlencoded"]
        request.httpBody = body
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            do {
                if let error = error { throw error }
                guard let data = data else { throw TranslationError(type: .failedTranslation) }
                
                completion?(.success(data))
                
            } catch {
                completion?(.failure(TranslationError(type: .failedTranslation, additionalInfo: error.localizedDescription)))
            }
        })

        dataTask.resume()
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
    
    struct GoogleTranslateErrorResponse: Decodable {
        let message: String
    }
}
