//
//  ClimateState.swift
//  AmosTesla001
//
//  Created by 吴昱珂 on 2021/2/3.
//

import Foundation

public struct ClimateState: Codable {
    let battery_heater: Bool
    var is_climate_on: Bool
    let is_auto_conditioning_on: Bool
    var is_front_defroster_on: Bool
    let inside_temp: Double?
    let outside_temp: Double?
    var driver_temp_setting: Double
    let passenger_temp_setting: Double
    var climate_keeper_mode: String // off / dog / camp
    
    let seat_heater_left: Int
    let seat_heater_right: Int
    let seat_heater_rear_left: Int?
    let seat_heater_rear_center: Int?
    let seat_heater_rear_right: Int?
    
    let side_mirror_heaters: Bool
    let wiper_blade_heater: Bool
    var steering_wheel_heater: Bool?
    // 过热保护开启 FanOnly
    let cabin_overheat_protection: String?
}

extension ClimateState {
    var wrapped_inside_temp: Double {
        inside_temp ?? 0
    }
    var wrapped_outside_temp: Double {
        outside_temp ?? 0
    }
    var inside_temp_c: String {
        if inside_temp != nil {
            return inside_temp!.temperatureWithLocale()
        }else {
            return "-"
        }
    }
    var outside_temp_c: String {
        if outside_temp != nil {
            return outside_temp!.temperatureWithLocale()
        }else {
            return "-"
        }
    }
    var temp_setting_c: String {
        driver_temp_setting.temperatureWithLocale()
    }
    var wrapped_wheel_heater_on: Bool {
        steering_wheel_heater ?? false
    }
    
    // 座位状态：加热、吹风、按摩
    enum SeatCondition {
        case off, heat, cool, massage
    }
    enum SeatPosistion {
        case frontLeft, frontRight, rearLeft, rearCenter, rearRight
    }
    func seatHeatCondition(_ position: SeatPosistion) -> SeatCondition {
        switch position {
        case .frontLeft:
            return seat_heater_left > 0 ? .heat : .off
        case .frontRight:
            return seat_heater_right > 0 ? .heat : .off
        case .rearLeft:
            return seat_heater_rear_left ?? 0 > 0 ? .heat : .off
        case .rearCenter:
            return seat_heater_rear_center ?? 0 > 0 ? .heat : .off
        case .rearRight:
            return seat_heater_rear_right ?? 0 > 0 ? .heat : .off
        }
    }
    
    // 空调模式：宠物、露营
    enum ClimateKeepMode: String {
        case off, dog, camp
    }
    var wrapped_climate_keeper_mode: ClimateKeepMode {
        if climate_keeper_mode == "off" || climate_keeper_mode == "unknown" {
            return .off
        }else if climate_keeper_mode == "dog" {
            return .dog
        }else {
            return .camp
        }
    }
    mutating func changeClimateMode(_ newMode: ClimateKeepMode) {
        if wrapped_climate_keeper_mode == newMode {
            climate_keeper_mode = ClimateKeepMode.off.rawValue
        }else {
            climate_keeper_mode = newMode.rawValue
        }
    }
}
