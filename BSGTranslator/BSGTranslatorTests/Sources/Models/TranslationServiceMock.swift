//
//  TranslationServiceMock.swift
//
//  Created by JechtSh0t on 6/6/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

@testable import BSGTranslator

struct TranslationServiceMock: TranslationServiceProtocol {
	init(apiKey: String) {}
	func translate(sourceStrings: [String: String], sourceLanguage: String, targetLanguage: String) async throws -> [String: String] {
		return TestConstants.italianTargetStrings
	}
}
