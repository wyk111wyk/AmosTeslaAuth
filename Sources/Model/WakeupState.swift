//
//  File.swift
//  
//
//  Created by Amos on 2024/8/17.
//

import Foundation

struct WakeupRoot: Codable {
    let response: WakeupState
}

public struct WakeupState: Codable {
    public let id: Int64
    public let user_id: Int64
    public let vehicle_id: Int64
    public let vin: String
    public let display_name: String?
    public let state: String // offline / online / asleep
    public let in_service: Bool
}

extension WakeupState {
    public var is_online: Bool {
        state == "online"
    }
}
