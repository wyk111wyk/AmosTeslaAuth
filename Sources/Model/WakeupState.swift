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
    let user_id: Int64
    let vehicle_id: Int64
    let vin: String
    let display_name: String?
    let state: String // offline / online / asleep
    let in_service: Bool
}

extension WakeupState {
    var is_online: Bool {
        state == "online"
    }
}
