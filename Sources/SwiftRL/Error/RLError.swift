//
//  File.swift
//  SwiftRL
//
//  Created by SJ Basak on 23/06/26.
//

import Foundation

public enum RLError: Error {
    case limitExceeded
    case refillError(RFError)
    
    var message: String {
        switch self {
            case .limitExceeded : "Rate Limit Exceeded"
            case let .refillError(error): error.message
        }
    }
}

public enum RFError: Error {
    case refillConditionMismatch
    
    var message: String {
        switch self {
            case .refillConditionMismatch : "Refill Condition has not matched yet"
        }
    }
}
