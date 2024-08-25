//
//  File.swift
//  
//
//  Created by Amos on 2024/8/14.
//

import Foundation

struct DriverRoot: Codable {
    let response: [DriverStore]
    let count: Int
}

public struct DriverStore: Identifiable, Codable {
    public var id: String { user_id_s }
    public let user_id_s: String
    public let vault_uuid: String?
    public let driver_first_name: String?
    public let driver_last_name: String?
}
