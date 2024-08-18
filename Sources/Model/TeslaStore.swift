//
//  File.swift
//  
//
//  Created by Amos on 2024/8/14.
//

import Foundation

public enum VehicleStateType: String {
    case online, offline, asleep, inService, loginRequired, noCar
}

struct TeslaRoot: Codable {
    let response: TeslaStore?
    let error: String?
    let error_description: String?
}

public struct TeslaStore: Codable, Identifiable {
    public let id: Int64
    public let id_s: String
    public let user_id: Int64
    public let vehicle_id: Int64
    public let vin: String
    public let access_type: String? // OWNER
    public var state: String // offline / online / asleep
    
    public var display_name: String?
    public var in_service: Bool?
    public var fetchDate: Date?
    
    public let vehicle_config: VehicleConfig
    public var drive_state: DriveState
    public let gui_settings: GuiSetting
    public let charge_state: ChargeState
    public let climate_state: ClimateState
    public let vehicle_state: VehicleState
}

extension TeslaStore: CustomStringConvertible {
    public var description: String {
        "id: \(id_s)\n vin: \(vin)\n state: \(state)\n display_name: \(display_name ?? "")\n in_service: \(in_service ?? false)\n fetchDate: \(fetchDate ?? Date())"
    }
    
    var is_online: Bool {
        state == "online"
    }
    
    var is_asleep: Bool {
        state == "asleep"
    }
    
    var isChanging: Bool {
        charge_state.is_changing
    }
    
    var stateType: VehicleStateType {
        if state == "online" {
            return .online
        }else if state == "offline" {
            return .offline
        }else if state == "asleep" {
            return .asleep
        }else {
            return .noCar
        }
    }
    
    mutating func setState(_ type: VehicleStateType) {
        state = type.rawValue
    }
}
