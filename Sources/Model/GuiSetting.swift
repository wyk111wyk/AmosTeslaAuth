//
//  GuiSetting.swift
//  AmosTesla001
//
//  Created by 吴昱珂 on 2021/2/3.
//

import Foundation

public struct GuiSetting: Codable {
    public let gui_24_hour_time: Bool
    public let gui_charge_rate_units: String // km/hr / mi/hr
    public let gui_distance_units: String // km/hr
    public let gui_range_display: String
    public let gui_temperature_units: String // C / F
    public let show_range_units: Bool
}
