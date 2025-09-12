//
//  TranslationError.swift
//
//  Created by JechtShot on 10/26/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Foundation

///
/// All error types that can be thrown.
///
public enum TranslationError: Equatable, LocalizedError {
    case decoding
    case empty(_ name: String)
    case encoding
    case incomplete
	case missing(_ name: String)
	case response(statusCode: Int?)
    
    public var errorDescription: String {
		switch self {
        case .decoding: return "Failed to decode API response."
        case .empty(let name): return "Empty \(name) found."
        case .encoding: return "Failed to encode API request."
        case .incomplete: return "Translation was incomplete."
		case .missing(let name): return "Could not find \(name)."
		case .response(let statusCode):
			var description = "Invalid API response."
			if let statusCode { description += " Status code \(statusCode)." }
			return description
		}
    }
}
