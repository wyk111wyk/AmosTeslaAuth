//
//  VehicleConfig.swift
//  AmosTesla001
//
//  Created by 吴昱珂 on 2021/2/3.
//

import Foundation

public struct VehicleConfig: Codable {
    let rhd: Bool // right hand drive
    let car_type: String // model3/models2
    let charge_port_type: String // GB / US / CCS
    let exterior_color: String // RedMulticoat/White
    let exterior_trim: String? // Chrome
    let interior_trim_type: String? // Black
    let wheel_type: String // Pinwheel18
    let trim_badging: String? // p90d
    let rear_seat_heaters: Int // 0 = no / 1 = yes
    let driver_assist: String? // TeslaAP3
    let has_air_suspension: Bool // 空气悬挂
    let has_ludicrous_mode: Bool // 狂暴模式
    let motorized_charge_port: Bool // 可遥控充电口
    let performance_package: String? // 性能套件: Base
    let roof_color: String? // RoofColorGlass
    let spoiler_type: String? // 扰流板类型: None
    let third_row_seats: String?
}

extension VehicleConfig {
    var has_rear_seat_heaters: Bool {
        rear_seat_heaters == 1
    }
    
    var car_type_name: String {
        if car_type == "model3" { return "Model 3" }
        else if car_type == "modely" { return "Model Y" }
        else if car_type == "modelx" { return "Model X" }
        else if car_type == "models" { return "Model S" }
        else if car_type == "cybertruck" { return "Cyber Truck" }
        else { return "N/A" }
    }
}
