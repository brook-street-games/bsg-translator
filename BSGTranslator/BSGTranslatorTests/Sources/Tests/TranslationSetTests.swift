//
//  TranslationSetTests.swift
//
//  Created by JechtShot on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Testing
@testable import BSGTranslator

struct TranslationSetTests {
    
    @Test private func testGetMissingTranslations() {
        let translationSet = TranslationSet(id: 0, language: "it", translations: ["apple": "mela", "banana": "banana", "blueberry": "mirtillo", "coconut": "noce di cocco"])
        #expect(translationSet.getMissingTranslations(from: [:]) == nil)
        #expect(translationSet.getMissingTranslations(from: ["apple": "mela", "banana": "banana"]) == nil)
        #expect(translationSet.getMissingTranslations(from: ["apple": "", "banana": ""]) == nil)
        #expect(translationSet.getMissingTranslations(from: ["apple": "mela", "banana": "banana", "cherry": "ciliegia"]) == ["cherry": "ciliegia"])
        #expect(translationSet.getMissingTranslations(from: ["cherry": "ciliegia", "grape": "uva", "kiwi": "kiwi"]) == ["cherry": "ciliegia", "grape": "uva", "kiwi": "kiwi"])
    }
    
    @Test private func testDescription() {
        let translationSet = TranslationSet(id: 0, language: "it", translations: ["apple": "mela", "banana": "banana", "blueberry": "mirtillo", "coconut": "noce di cocco"])
        #expect(translationSet.description == """
        Translation ID: 0
        Language: it
        
        apple: mela
        banana: banana
        blueberry: mirtillo
        coconut: noce di cocco
        """)
    }
}
