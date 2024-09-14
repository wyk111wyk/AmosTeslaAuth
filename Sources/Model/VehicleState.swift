//
//  VehicleState.swift
//  AmosTesla001
//
//  Created by 吴昱珂 on 2021/2/3.
//

import Foundation

public struct VehicleState: Codable {
    public let api_version: Int
    public let car_version: String
    public let locked: Bool
    
    // 车门
    public let df: Int // 驾驶室 0 = closed, non-zero is open.
    public let pf: Int // 前排乘客
    public let dr: Int // 驾驶室后排
    public let pr: Int // 后排乘客
    
    // 前后备箱
    public let ft : Int // front trunk 前备箱 0 == close
    public let rt: Int // rear trunk 后备箱
    
    // 窗户
    public let fd_window: Int // 0 - close - Front Drvier
    public let fp_window: Int
    public let rd_window: Int
    public let rp_window: Int
    
    // 轮胎
    public let tpms_pressure_fl: Double?
    public let tpms_pressure_fr: Double?
    public let tpms_pressure_rl: Double?
    public let tpms_pressure_rr: Double?
    public let tpms_rcp_front_value: Double?
    public let tpms_rcp_rear_value: Double?
    
    public let odometer: Double // total miles
    public var sentry_mode: Bool // 哨兵模式
    public let sentry_mode_available: Bool
    
    public let remote_start: Bool // 远程启动状态
    public let remote_start_enabled: Bool
    public let remote_start_supported: Bool
    
    public let timestamp: Int64
    public let software_update: SoftwareUpdate
}

public struct SoftwareUpdate: Codable {
    public let download_perc: Int // 0
    public let install_perc: Int // 0
    public let expected_duration_sec: Int // 2700
    public let status: String? // downloading_wifi_wait
    public let version: String? // 2021.36.5
    
    public var expected_text: String {
        Double(expected_duration_sec).toUnit(unit: UnitDuration.seconds, degit: 1)
    }
}

extension VehicleState {
    public var hasUpdate: Bool {
        if let newVersion = software_update.version,
           newVersion.count > 2 {
            return true
        }else {
            return false
        }
    }
    public var newVersion: String? {
        if let newVersion = software_update.version,
           newVersion.count > 2 {
            return newVersion
        }else {
            return nil
        }
    }
    public var car_version_prefix: String {
        let index = car_version.firstIndex(of: " ")
        return String(car_version[..<index!])
    }
    public var is_windowAllClosed: Bool {
        fd_window + fp_window + rd_window + rp_window == 0
    }
    public func is_tireTempLow(minTemp: Double = 2.5) -> Bool {
        if let tpms_pressure_fl,
           let tpms_pressure_fr,
           let tpms_pressure_rl,
           let tpms_pressure_rr {
            return tpms_pressure_fl < minTemp ||
            tpms_pressure_fr < minTemp ||
            tpms_pressure_rl < minTemp ||
            tpms_pressure_rr < minTemp
        }else {
            return false
        }
    }
    public var odometer_km: String {
        let locale = Locale.current(langCode: .english)
        return odometer.toLength(unit: .miles, locale: locale)
    }
    public var isTruckAllClose: Bool {
        ft == 0 && rt == 0
    }
    public var isFrontTrunkClose: Bool {
        ft == 0
    }
    public var isRearTrunkClose: Bool {
        rt == 0
    }
}

extension VehicleState {
    public enum VehicleDoor {
        case frontDriver, frontPassenger, rearDriver, rearPassenger
        public func isClosed(_ vehicle: VehicleState) -> Bool {
            switch self {
            case .frontDriver:
                vehicle.df == 0
            case .frontPassenger:
                vehicle.pf == 0
            case .rearDriver:
                vehicle.dr == 0
            case .rearPassenger:
                vehicle.pr == 0
            }
        }
    }
    public var is_doorAllClosed: Bool {
        df + pf + dr + pr == 0
    }
    public var is_doorAllOpen: Bool {
        df != 0 && pf != 0 && dr != 0 && pr != 0
    }
    // 0 = close
    public func doorStateImageName() -> String {
        if df == 0 && pf == 0 && dr == 0 && pr == 0 {
            return "car" // 全关
        }else if df != 0 && pf == 0 && dr == 0 && pr == 0 {
            return "car.top.door.front.left.open"
        }else if df == 0 && pf != 0 && dr == 0 && pr == 0 {
            return "car.top.door.front.right.open"
        }else if df == 0 && pf == 0 && dr != 0 && pr == 0 {
            return "car.top.door.rear.left.open"
        }else if df == 0 && pf == 0 && dr == 0 && pr != 0 {
            return "car.top.door.rear.right.open"
        }else if df != 0 && pf != 0 && dr == 0 && pr == 0 {
            return "car.top.door.front.left.and.front.right.open"
        }else if df != 0 && pf == 0 && dr != 0 && pr == 0 {
            return "car.top.door.front.left.and.rear.left.open"
        }else if df != 0 && pf == 0 && dr == 0 && pr != 0 {
            return "car.top.door.front.left.and.rear.right.open"
        }else if df == 0 && pf != 0 && dr != 0 && pr == 0 {
            return "car.top.door.front.right.and.rear.left.open"
        }else if df == 0 && pf != 0 && dr == 0 && pr != 0 {
            return "car.top.door.front.right.and.rear.right.open"
        }else if df == 0 && pf == 0 && dr != 0 && pr != 0 {
            return "car.top.door.rear.left.and.rear.right.open"
        }else if df != 0 && pf != 0 && dr != 0 && pr == 0 {
            return "car.top.door.front.left.and.front.right.and.rear.left.open"
        }else if df != 0 && pf != 0 && dr == 0 && pr != 0 {
            return "car.top.door.front.left.and.front.right.and.rear.right.open"
        }else if df != 0 && pf == 0 && dr != 0 && pr != 0 {
            return "car.top.door.front.left.and.rear.left.and.rear.right.open"
        }else if df == 0 && pf != 0 && dr != 0 && pr != 0 {
            return "car.top.door.front.right.and.rear.left.and.rear.right.open"
        }else {
            return "car.top.door.front.left.and.front.right.and.rear.left.and.rear.right.open" // 全开
        }
    }
}
