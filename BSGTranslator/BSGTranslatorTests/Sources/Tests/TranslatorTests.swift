//
//  TranslatorTests.swift
//
//  Created by JechtShot on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Testing
@testable import BSGTranslator

@MainActor
struct TranslatorTests {
	
    // MARK: - Properties -
    
	private let translationService = TranslationServiceMock(apiKey: "")
}

// MARK: - Translation -

extension TranslatorTests {
	
	@Test private func testUpdateTranslations() async throws {
        let translator = Translator(sourceLanguage: "en", sourceType: .manual(sourceStrings: TestConstants.englishSourceStrings), targetLanguage: "it", translationService: translationService)
        translator.clearCache()
        let translationSet = try await translator.updateTranslations()
        for translation in TestConstants.italianTargetStrings {
            #expect(translationSet.translations[translation.key] == translation.value)
        }
	}
    
    @Test private func testMissingManualStrings() async {
        let translator = Translator(sourceLanguage: "en", sourceType: .manual(sourceStrings: [:]), targetLanguage: "it", translationService: translationService)
        translator.clearCache()
        await #expect(throws: TranslationError.empty("source strings")) {
            try await translator.updateTranslations()
        }
    }
    
    @Test private func testMissingStringsFile() async {
        let translator = Translator(sourceLanguage: "en", sourceType:  .stringsFile(fileName: "Test"), targetLanguage: "it", translationService: translationService)
        translator.clearCache()
        await #expect(throws: TranslationError.missing("Test")) {
            try await translator.updateTranslations()
        }
    }
}

// MARK: - Retrieval -

extension TranslatorTests {
	
    @Test private func testCapitalizationNone() async throws {
        let translator = Translator(sourceLanguage: "en", sourceType:  .manual(sourceStrings: TestConstants.englishSourceStrings), targetLanguage: "it", translationService: translationService)
        try await translator.updateTranslations()
        #expect(translator.getTranslatedValue(for: "coconut", capitalization: .none) == "noce di cocco")
    }
    
    @Test private func testCapitalizationFirst() async throws {
        let translator = Translator(sourceLanguage: "en", sourceType:  .manual(sourceStrings: TestConstants.englishSourceStrings), targetLanguage: "it", translationService: translationService)
        try await translator.updateTranslations()
        #expect(translator.getTranslatedValue(for: "coconut", capitalization: .first) == "Noce di cocco")
    }
    
    @Test private func testCapitalizationAllFirst() async throws {
        let translator = Translator(sourceLanguage: "en", sourceType:  .manual(sourceStrings: TestConstants.englishSourceStrings), targetLanguage: "it", translationService: translationService)
        try await translator.updateTranslations()
        #expect(translator.getTranslatedValue(for: "coconut", capitalization: .allFirst) == "Noce Di Cocco")
    }
    
    @Test private func testCapitalizationAll() async throws {
        let translator = Translator(sourceLanguage: "en", sourceType:  .manual(sourceStrings: TestConstants.englishSourceStrings), targetLanguage: "it", translationService: translationService)
        try await translator.updateTranslations()
        #expect(translator.getTranslatedValue(for: "coconut", capitalization: .all) == "NOCE DI COCCO")
    }
    
    @Test private func testSubscript() async throws {
        let translator = Translator(sourceLanguage: "en", sourceType:  .manual(sourceStrings: TestConstants.englishSourceStrings), targetLanguage: "it", translationService: translationService)
        try await translator.updateTranslations()
        #expect(translator["coconut"] == "Noce di cocco")
    }
}
