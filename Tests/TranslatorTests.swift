//
//  TranslatorTests.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import XCTest
@testable import BSGTranslator

class TranslatorTests: XCTestCase {
	
	private var translationService = TranslationServiceMock(apiKey: "")
	
	private var testUpdateTranslationsExpectation: XCTestExpectation?
	private var testInvalidStringsFileExpectation: XCTestExpectation?
	private var testMissingInputStringsExpectation: XCTestExpectation?
}

extension TranslatorTests {
	
	func testUpdateTranslations() {
		
		testUpdateTranslationsExpectation = expectation(description: "Test update translations")
		
		let translator = Translator(inputLanguage: "en", inputType: .manual(inputStrings: TestConstants.englishInputStrings), outputLanguage: "it", translationService: translationService)
		translator.delegate = self
		translator.clearCache()
		translator.updateTranslations()
		
		waitForExpectations(timeout: TestConstants.waitTime)
	}
}

// MARK: - Errors -

extension TranslatorTests {
	
	func testInvalidStringsFile() {
		
		testInvalidStringsFileExpectation = expectation(description: "Test invalid strings file")
		
		let translator = Translator(inputLanguage: "en", inputType: .stringsFile(fileName: "Test"), outputLanguage: "it", translationService: translationService)
		translator.delegate = self
		translator.clearCache()
		translator.updateTranslations()
		
		waitForExpectations(timeout: TestConstants.waitTime)
	}
	
	func testMissingInputStrings() {
		
		testMissingInputStringsExpectation = expectation(description: "Test missing input strings")
		
		let translator = Translator(inputLanguage: "en", inputType: .manual(inputStrings: [:]), outputLanguage: "it", translationService: translationService)
		translator.delegate = self
		translator.clearCache()
		translator.updateTranslations()
		
		waitForExpectations(timeout: TestConstants.waitTime)
	}
}

// MARK: - Delegate -

extension TranslatorTests: TranslatorDelegate {
	
	func translator(_ translator: Translator, didUpdateTranslations result: Result<TranslationSet, TranslationError>) {
		
		switch result {
			
		case .success(let translationSet):
			testUpdateTranslationsExpectation?.fulfill()
			for translation in TestConstants.italianTranslations {
				XCTAssert(translationSet.translations[translation.key] == translation.value)
			}
			
		case .failure(let error):
			
			switch error {
			case .invalidStringFile: testInvalidStringsFileExpectation?.fulfill()
			case .missingInputStrings: testMissingInputStringsExpectation?.fulfill()
			default: break
			}
		}
	}
}
