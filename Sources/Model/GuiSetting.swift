//
//  GuiSetting.swift
//  AmosTesla001
//
//  Created by 吴昱珂 on 2021/2/3.
//

import Foundation

public struct GuiSetting: Codable {
    let gui_24_hour_time: Bool
    let gui_charge_rate_units: String // km/hr / mi/hr
    let gui_distance_units: String // km/hr
    let gui_range_display: String
    let gui_temperature_units: String // C / F
    let show_range_units: Bool
}
