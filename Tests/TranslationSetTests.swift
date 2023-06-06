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
    
    func testGetMissingTranslations() {
        
        let translationSet = TranslationSet(id: 0, language: "it", translations: ["apple": "mela", "banana": "banana", "blueberry": "mirtillo", "coconut": "noce di cocco"])
        
        XCTAssertNil(translationSet.getMissingTranslations(from: [:]))
        XCTAssertNil(translationSet.getMissingTranslations(from: ["apple": "mela", "banana": "banana"]))
        XCTAssertNil(translationSet.getMissingTranslations(from: ["apple": "", "banana": ""]))
        
		XCTAssertEqual(translationSet.getMissingTranslations(from: ["apple": "mela", "banana": "banana", "cherry": "ciliegia"]), ["cherry": "ciliegia"])
		XCTAssertEqual(translationSet.getMissingTranslations(from: ["cherry": "ciliegia", "grape": "uva", "kiwi": "kiwi"]), ["cherry": "ciliegia", "grape": "uva", "kiwi": "kiwi"])
    }
}
