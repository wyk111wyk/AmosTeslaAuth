//
//  File.swift
//  
//
//  Created by Amos on 2024/8/14.
//

import Foundation

// MARK: - 查找所属车辆
struct VehiclesRoot: Codable {
    let count: Int?
    let response: [VehicleStore]?
    let error: String?
    let error_description: String?
}

public struct VehicleStore: Codable, Identifiable, Hashable {
    public var id: String { id_s }
    public let id_s: String
    public let vehicle_id: Int64?
    public let vin: String
    public let access_type: String
    public let display_name: String
    public var state: String?
    
    public let in_service: Bool?
    public let calendar_enabled: Bool?
    public let api_version: Int?
    
    public var isDemo: Bool?
    
    public init(
        id_s: String,
        vehicle_id: Int64? = nil,
        vin: String,
        access_type: String = "OWNER",
        display_name: String,
        state: String? = nil,
        in_service: Bool? = false,
        calendar_enabled: Bool? = true,
        api_version: Int? = nil,
        isDemo: Bool? = nil
    ) {
        self.id_s = id_s
        self.vehicle_id = vehicle_id
        self.vin = vin
        self.access_type = access_type
        self.display_name = display_name
        self.state = state
        self.in_service = in_service
        self.calendar_enabled = calendar_enabled
        self.api_version = api_version
        self.isDemo = isDemo
    }
    
    public init(from store: TeslaStore) {
        self.id_s = store.id_s
        self.vehicle_id = store.vehicle_id
        self.vin = store.vin
        self.access_type = store.access_type ?? "OWNER"
        self.display_name = store.display_name ?? "My Car"
        self.state = store.state
        self.in_service = store.in_service
        self.calendar_enabled = true
        self.api_version = store.vehicle_state.api_version
        self.isDemo = false
    }
}

extension VehicleStore {
    public var is_online: Bool {
        state == "online"
    }
    public var stateType: VehicleStateType {
        if state == "online" {
            return .online
        }else if state == "offline" {
            if in_service == true {
                return .inService
            }else {
                return .offline
            }
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

extension VehicleStore {
    public static func example() -> VehicleStore {
        .init(id_s: "12345", vin: "VG123456", display_name: "Demo", state: "online")
    }
}
