//
//  GoogleTranslateResponse.swift
//
//  Created by JechtShot on 9/11/25.
//  Copyright © 2025 Brook Street Games. All rights reserved.
//

struct GoogleTranslateResponse: Decodable {
    var data: GoogleTranslationSet
}

struct GoogleTranslationSet: Decodable {
    let translations: [GoogleTranslation]
}

struct GoogleTranslation: Decodable {
    let translatedText: String
}
