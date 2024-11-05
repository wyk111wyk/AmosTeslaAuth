//
//  File.swift
//  
//
//  Created by Amos on 2024/8/14.
//

import Foundation

public enum VehicleLoadingState: Equatable {
    case loading, loaded, failed(Error), wakeup
    
    public static func == (a: VehicleLoadingState, b: VehicleLoadingState) -> Bool {
        switch (a, b) {
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        case (.failed, .failed):
            return true
        case (.wakeup, .wakeup):
            return true
        default:
            return false
        }
    }
    
    public var title: String {
        switch self {
        case .loading:
            "载入中"
        case .loaded:
            "已载入"
        case .failed(_):
            "载入失败"
        case .wakeup:
            "唤醒中"
        }
    }
}

public enum VehicleStateType: String {
    case online, offline, asleep, inService, loginRequired, noCar
    public var title: String {
        var tempTitle = String.init()
        switch self {
        case .online:
            tempTitle = "Online"
        case .offline:
            tempTitle = "Offline"
        case .asleep:
            tempTitle = "Asleep"
        case .inService:
            tempTitle = "In Service"
        case .loginRequired:
            tempTitle = "Need Login"
        case .noCar:
            tempTitle = "NoCar"
        }
        return tempTitle
    }
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
        "id: \(id_s)\nvin: \(vin)\nbattery:\(charge_state.battery_range_km)\ntemp:\(climate_state.inside_temp_c)\nstate: \(state)\ndisplay_name: \(display_name ?? "")\nin_service: \(in_service ?? false)\nfetchDate: \(fetchDate ?? Date())"
    }
    
    public var is_online: Bool {
        state == "online"
    }
    
    public var is_asleep: Bool {
        state == "asleep"
    }
    
    public var isChanging: Bool {
        charge_state.is_changing
    }
    
    public var stateType: VehicleStateType {
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
    
    public mutating func setState(_ type: VehicleStateType) {
        state = type.rawValue
    }
}
