//
//  VehicleConfig.swift
//  AmosTesla001
//
//  Created by 吴昱珂 on 2021/2/3.
//

import Foundation

public struct VehicleConfig: Codable {
    public let rhd: Bool // right hand drive
    public let car_type: String // model3/models2
    public let charge_port_type: String // GB / US / CCS
    public let exterior_color: String // RedMulticoat/White
    public let exterior_trim: String? // Chrome
    public let interior_trim_type: String? // Black
    public let wheel_type: String // Pinwheel18
    public let trim_badging: String? // p90d
    public let rear_seat_heaters: Int // 0 = no / 1 = yes
    public let driver_assist: String? // TeslaAP3
    public let has_air_suspension: Bool // 空气悬挂
    public let has_ludicrous_mode: Bool // 狂暴模式
    public let motorized_charge_port: Bool // 可遥控充电口
    public let performance_package: String? // 性能套件: Base
    public let roof_color: String? // RoofColorGlass
    public let spoiler_type: String? // 扰流板类型: None
    public let third_row_seats: String?
}

extension VehicleConfig {
    public var has_rear_seat_heaters: Bool {
        rear_seat_heaters == 1
    }
    
    public var car_type_name: String {
        if car_type == "model3" { return "Model 3" }
        else if car_type == "modely" { return "Model Y" }
        else if car_type == "modelx" { return "Model X" }
        else if car_type == "models" { return "Model S" }
        else if car_type == "cybertruck" { return "Cyber Truck" }
        else { return "N/A" }
    }
}
