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
    
    public var errorDescription: String? {
        switch self {
        case .accountOrPasswordWrong:
            return "AccountWrongDescription"
        case .networkError(error: let error):
            return "Network error: \(error.localizedDescription)"
        case .authenticationFailed:
            return "Authentication failed, please update your App"
        case .wrongLocale:
            return "Please change your system locale to current region"
        case .frequentError:
            return "frequentError"
        case .recaptchaError:
            return "Recaptcha Error"
        case .authenticationRequired:
            return "Authentication required"
        case .tokenRevoked:
            return "token Revoked"
        case .watchRefresh:
            return "Refresh on one device"
        case .decodeError:
            return "Decode wrong"
        case .encodeError:
            return "Encode wrong"
        case .notReachable:
            return "notReachableError"
        case .dataSerializationError(let msg):
            return "dataSerializationError".localized() + "\n" + "\(msg)"
        case .customError(let msg):
            return msg
        }
    }
}
