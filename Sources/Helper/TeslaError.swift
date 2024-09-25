//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/8/2.
//

import Foundation

public enum TeslaError: Error, Equatable, LocalizedError {
    case networkError(error: NSError)
    case authenticationFailed
    case authenticationRequired
    case tokenRevoked
    case accountOrPasswordWrong
    case wrongLocale
    case frequentError
    case recaptchaError
    case decodeError
    case encodeError
    case notReachable
    case watchRefresh
    case dataSerializationError(msg: String)
    case customError(msg: String)
    
    public var errorDescription: String {
        var errorMsg = ""
        switch self {
        case .accountOrPasswordWrong:
            errorMsg = "Account Wrong Error"
        case .networkError(error: let error):
            errorMsg = "Network error: \(error.localizedDescription)"
        case .authenticationFailed:
            errorMsg = "Authentication failed, please update your App"
        case .wrongLocale:
            errorMsg = "Please change your system locale to current region"
        case .frequentError:
            errorMsg = "frequentError"
        case .recaptchaError:
            errorMsg = "Recaptcha Error"
        case .authenticationRequired:
            errorMsg = "Authentication required"
        case .tokenRevoked:
            errorMsg = "Token Revoked"
        case .watchRefresh:
            errorMsg = "Refresh on one device"
        case .decodeError:
            errorMsg = "Decode wrong"
        case .encodeError:
            errorMsg = "Encode wrong"
        case .notReachable:
            errorMsg = "notReachableError"
        case .dataSerializationError(let msg):
            errorMsg = "dataSerializationError" + "\n" + "\(msg)"
        case .customError(let msg):
            errorMsg = msg
        }
        
        return errorMsg
    }
}
