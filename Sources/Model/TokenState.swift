//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/8/4.
//

import Foundation

struct TokenState: Codable {
    let access_token: String?
    let expires_in: TimeInterval?
    let id_token: String? // Only for bearer token
    let refresh_token: String? // bearer response works
    let state: String?
    let token_type: String?
    
    let error: String?
    let error_description: String?
}
