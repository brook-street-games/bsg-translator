//
//  TranslationServiceMock.swift
//
//  Created by JechtSh0t on 6/6/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

@testable import BSGTranslator

class TranslationServiceMock: TranslationServiceProtocol {
	
	required init(apiKey: String) {}
	
	func performTranslation(inputStrings: [String: String], inputLanguage: String, outputLanguage: String) async throws -> [String: String] {
		return TestConstants.italianTranslations
	}
}
