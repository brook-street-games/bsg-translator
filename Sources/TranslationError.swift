//
//  TranslationError.swift
//
//  Created by JechtSh0t on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Foundation

public enum TranslationError: Error, CustomStringConvertible {
    
	case missingInputStrings
	case invalidStringFile(_ fileName: String)
	case emptyStringsFile(_ fileName: String)
	case invalidParameters
	case invalidResponse(statusCode: Int?)
	case incompleteTranslation
	case failedDecoding
	case unknown
	
    // MARK: - Properties -
    
    public var description: String {
        
		switch self {
		case .missingInputStrings: return "Missing input strings."
		case .invalidStringFile(let fileName): return "Could not find strings file named \(fileName)."
		case .emptyStringsFile(let fileName): return "String file \(fileName) is empty."
		case .invalidParameters: return "Invalid parameters in API request."
		case .invalidResponse(let statusCode):
			var description = "Invalid response."
			if let statusCode { description += "Status code \(statusCode)." }
			return description
		case .incompleteTranslation: return "Trnalsation was started but could not complete."
		case .failedDecoding: return "Failed to decode API response."
		case .unknown: return "An unknwon error occured."
		}
    }
    
    public var localizedDescription: String { return description }
}
