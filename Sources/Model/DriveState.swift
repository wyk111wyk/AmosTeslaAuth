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
        let drive_state: DriveState
    }
}

public struct DriveState: Codable {
    let active_route_latitude: Double?
    let active_route_longitude: Double?
    let latitude: Double?
    let longitude: Double?
    let native_latitude: Double?
    let native_longitude: Double?
    let native_type: String?
    // 目前挡位
    let shift_state: String?
    let speed: Double?
    let active_route_traffic_minutes_delay: Double?
    let power: Int?
}

extension DriveState {
    var coordinate: CLLocationCoordinate2D? {
        if let native_latitude, let native_longitude {
            return .init(latitude: native_latitude, longitude: native_longitude)
        }else {
            return nil
        }
    }
    var speedText: String? {
        if let speed {
            let locale = Locale.current(langCode: .english)
            return speed.toUnit(unit: UnitSpeed.milesPerHour, style: .medium, locale: locale)
        }else {
            return nil
        }
    }
    
    // 车辆档位
    enum VehicleShift: String {
        case p, d, r, n
        var stateTitle: String {
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
        var stateColor: Color {
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
    var shift: VehicleShift? {
        if let shift_state {
            return VehicleShift(rawValue: shift_state.lowercased())
        }else {
            return nil
        }
    }
}
