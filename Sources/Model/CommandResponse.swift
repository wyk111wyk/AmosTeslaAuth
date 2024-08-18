//
//  File.swift
//  
//
//  Created by Amos on 2024/8/17.
//

import Foundation

open class Response<T: Decodable>: Decodable {
    
    open var response: T
    
    public init(response: T) {
        self.response = response
    }
    
    // MARK: Codable protocol
    
    enum CodingKeys: String, CodingKey {
        case response
    }
    
}

open class ArrayResponse<T: Decodable>: Decodable {
    
    open var response: [T] = []
    
    // MARK: Codable protocol
    
    enum CodingKeys: String, CodingKey {
        case response
    }
    
}


open class BoolResponse: Decodable {
    
    open var response: Bool
    
    public init(response: Bool) {
        self.response = response
    }
    
    // MARK: Codable protocol
    
    enum CodingKeys: String, CodingKey {
        case response = "response"
    }
    
}

public struct CommandResponse: Codable {
    let error: String?
    let error_description: String?
    let response: Response?
    
    struct Response: Codable {
        let result: Bool
    }
}
