//
//  Result.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(TranslationError)
}

typealias GoogleTranslateResponseResultHandler = (Result<TranslationService.GoogleTranslateResponse>) -> Void
public typealias TranslationSetResultHandler = (Result<TranslationSet>) -> Void
public typealias DataResultHandler = (Result<Data>) -> Void
