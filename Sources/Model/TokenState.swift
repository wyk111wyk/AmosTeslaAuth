//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/8/4.
//

import Foundation

public struct TokenState: Codable {
    public let access_token: String?
    public let expires_in: TimeInterval?
    public let id_token: String? // Only for bearer token
    public let refresh_token: String? // bearer response works
    public let state: String?
    public let token_type: String?
    
    public let error: String?
    public let error_description: String?
}
