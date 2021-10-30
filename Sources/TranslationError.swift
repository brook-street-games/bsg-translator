//
//  TranslationError.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Foundation

public struct TranslationError: Error, CustomStringConvertible {
    
    // MARK: - Properties -
    
    public var type: ErrorType
    public var additionalInfo: String?
    
    public var description: String {
        
        var description = type.rawValue
        if let additionalInfo = additionalInfo { description += ". \(additionalInfo)" }
        return description
    }
    
    public var localizedDescription: String { return description }
    
    // MARK: - Setup -
    
    init(type: ErrorType, additionalInfo: String? = nil) {
        
        self.type = type
        self.additionalInfo = additionalInfo
    }
}

// MARK: - Error Types -

extension TranslationError {
    
    public enum ErrorType: String {
        
        case missingInputStrings = "Missing input strings"
        case emptyStringsFile = "Empty strings file detected"
        case invalidConfiguration = "Missing configuration for translator"
        case invalidParameters = "Invalid parameters sent to API"
        case failedTranslation = "Failed to get translations"
        case incompleteTranslation = "Failed to get some translations"
        case failedDecoding = "Failed to decode translations"
        case unknown = "Unknown error"
    }
}
