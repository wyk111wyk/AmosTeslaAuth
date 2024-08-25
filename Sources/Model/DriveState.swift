//
//  DriveState.swift
//  AmosTesla001
//
//  Created by 吴昱珂 on 2021/2/3.
//

import Foundation
import CoreLocation
import SwiftUI

struct DriveRoot: Codable {
    let response: DriveResponse?
    
    struct DriveResponse: Codable {
        public let drive_state: DriveState
    }
}

public struct DriveState: Codable {
    public let active_route_latitude: Double?
    public let active_route_longitude: Double?
    public let latitude: Double?
    public let longitude: Double?
    public let native_latitude: Double?
    public let native_longitude: Double?
    public let native_type: String?
    // 目前挡位
    public let shift_state: String?
    public let speed: Double?
    public let active_route_traffic_minutes_delay: Double?
    public let power: Int?
}

extension DriveState {
    public var coordinate: CLLocationCoordinate2D? {
        if let native_latitude, let native_longitude {
            return .init(latitude: native_latitude, longitude: native_longitude)
        }else {
            return nil
        }
    }
    public var speedText: String? {
        if let speed {
            let locale = Locale.current(langCode: .english)
            return speed.toUnit(unit: UnitSpeed.milesPerHour, style: .medium, locale: locale)
        }else {
            return nil
        }
    }
    
    // 车辆档位
    public enum VehicleShift: String {
        case p, d, r, n
        public var stateTitle: String {
            switch self {
            case .p:
                return "Vehicle parked"
            case .d:
                return "Vehicle driving"
            case .r:
                return "Vehicle reversing"
            case .n:
                return "Vehicle in neutral"
            }
        }
        public var stateColor: Color {
            switch self {
            case .p:
                return .blue
            case .d:
                return .green
            case .r:
                return .red
            case .n:
                return .gray
            }
        }
    }
    public var shift: VehicleShift? {
        if let shift_state {
            return VehicleShift(rawValue: shift_state.lowercased())
        }else {
            return nil
        }
    }
}
