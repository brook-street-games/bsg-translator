//
//  TranslationSetTests.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import XCTest
@testable import BSGTranslator

class TranslationSetTests: XCTestCase {}

extension TranslationSetTests {
    
    func testMissingInputStrings() {
        
        let translationSet = TranslationSet(id: 0, language: "it", translations: ["dog": "cane", "cat": "gatto", "monkey": "scimmia", "spider": "ragno"])
        
        XCTAssertNil(translationSet.getMissingTranslations(in: [:]))
        XCTAssertNil(translationSet.getMissingTranslations(in: ["cat": "gatto", "dog": "cane"]))
        XCTAssertNil(translationSet.getMissingTranslations(in: ["cat": "value", "dog": "value"]))
        
        XCTAssertEqual(translationSet.getMissingTranslations(in: ["shark": "squalo", "dog": "cane"]), ["shark": "squalo"])
        XCTAssertEqual(translationSet.getMissingTranslations(in: ["bee": "ape", "lion": "leone", "duck": "anatra"]), ["bee": "ape", "lion": "leone", "duck": "anatra"])
    }
}
