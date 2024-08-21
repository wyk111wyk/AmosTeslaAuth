//
//  File.swift
//  AmosTesla001
//
//  Created by 吴昱珂 on 2021/2/3.
//

import Foundation

public struct ChargeState: Codable {
    let battery_heater_on: Bool
    let battery_level: Int // 38 -> 38%
    let battery_range: Double // 113.56 -> mile
    let est_battery_range: Double? // 104.03 -> mile
    let charge_energy_added: Double? // 6.74 -> kwh
    let charge_limit_soc: Int // 80
    let charging_state: String // Disconnected / Charging / 
    
    let supercharger_session_trip_planner: Bool
    // StartAt / Off / DepartBy
    let scheduled_charging_mode: String
    // 是否已经插好电正在等待到时间充电
    // 手动开启和关闭充电后，pending会恢复原状
    let scheduled_charging_pending: Bool
    let scheduled_charging_start_time: TimeInterval?
    let scheduled_departure_time: TimeInterval?
    let preconditioning_enabled: Bool // 是否预设空调
    let off_peak_charging_enabled: Bool // 是否开启峰谷电
    // 充电时显示
    let charger_actual_current: Int?
    let charger_power: Int?
    let charger_voltage: Int?
    let minutes_to_full_charge: Int
    let time_to_full_charge: Double
    let charge_port_door_open: Bool
    // 充电增加了多少里程
    let charge_miles_added_rated: Double
    // 充电速率 mile/hr
    let charge_rate: Double
}

extension ChargeState {
    enum ScheduleMode {
        case off, startAt, departBy
    }
    
    /// 计划充电的模式
    var scheduleMode: ScheduleMode {
        if scheduled_charging_mode == "Off" {
            return .off
        }else if scheduled_charging_mode == "StartAt" {
            return .startAt
        }else {
            return .departBy
        }
    }
    
    /// 计划充电或离开的时间（精确到每一天）
    var scheduledChangeDate: Date? {
        if scheduleMode == .startAt,
           let ts = scheduled_charging_start_time {
            return Date(timeIntervalSince1970: ts)
        }else if scheduleMode == .departBy,
                 let ts = scheduled_departure_time {
            return Date(timeIntervalSince1970: ts)
        }else {
            return nil
        }
    }
    
    /// 充电增加了多少里程（本地化）
    var change_local_range_added: String {
        charge_miles_added_rated.distanceWithLocale()
    }
    
    /// 72%
    var battery_level_percentage: String {
        "\(battery_level)%"
    }
    
    /// 345 km
    var battery_range_km: String {
        return battery_range.distanceWithLocale()
    }
    
    /// 345
    var battery_range_noUnit: String {
        return battery_range.distanceWithLocale(0, withUnit: false)
    }
    
    var battery_range_local: Double {
        Double(battery_range_noUnit) ?? 0
    }
    
    /// 345 km
    var est_battery_range_km: String {
        guard let range = est_battery_range else { return "" }
        return range.distanceWithLocale()
    }
    
    /// 345
    var est_battery_range_noUnit: String {
        guard let range = est_battery_range else { return "" }
        return range.distanceWithLocale(0, withUnit: false)
    }
    
    var current_maxrange: Double {
        return battery_range / (Double(battery_level) / 100)
    }
    
    var current_maxrange_noUnit: String {
        return current_maxrange.distanceWithLocale(0, withUnit: false)
    }
    
    var current_maxrange_km: String {
        let max_range = battery_range / (Double(battery_level) / 100)
        return max_range.distanceWithLocale()
    }
    
    var is_changing: Bool {
        charging_state == "Charging"
    }
    
    /// 上次充电量
    var wrapped_charge_energy_added: String {
        String(format: "%.1f", charge_energy_added ?? 0)
    }
    
    var wrapped_charge_miles_added: String {
        charge_miles_added_rated.distanceWithLocale(withUnit: false)
    }
    
    var wrapped_charger_actual_current: Int {
        charger_actual_current ?? 0
    }
    
    var wrapped_charger_power: Int {
        charger_power ?? 0
    }
    
    var wrapped_charger_voltage: Int {
        charger_voltage ?? 0
    }
    
    func left_charge_time_text(_ locale: Locale = Locale(identifier: "en_US")) -> String {
        Double(minutes_to_full_charge*60).toDuration(units: [.minute, .hour],
                                                     style: .abbreviated,
                                                     locale: locale)
    }
}