//
//  File.swift
//  
//
//  Created by Amos on 2024/8/18.
//

import Foundation

// MARK: - Example Data
public func exampleAllVehicles() -> [VehicleStore] {
    let vehicle = VehicleStore(id_s: "23456789", vehicle_id: 99999, vin: "YYKKPP0099KK", display_name: "Demo Car", state: "online", in_service: false, isDemo: true)
    return [vehicle]
}

public func exampleDrive() -> DriveState {
    let state = DriveState(active_route_latitude: 20.018679, active_route_longitude: 110.262135, latitude: 20.020816, longitude: 110.257883, native_latitude: 20.018682, native_longitude: 110.262137, native_type: "wgs", shift_state: "D", speed: 80, active_route_traffic_minutes_delay: 0, power: 0)
    return state
}

public func exampleConfig() -> VehicleConfig {
    let config = VehicleConfig(rhd: false, car_type: "model3", charge_port_type: "GB", exterior_color: "RedMulticoat", exterior_trim: "Chrome", interior_trim_type: "Black", wheel_type: "Pinwheel18", trim_badging: "dual motol", rear_seat_heaters: 1, driver_assist: "TeslaAP3", has_air_suspension: false, has_ludicrous_mode: false, motorized_charge_port: true, performance_package: "Base", roof_color: "RoofColorGlass", spoiler_type: "None", third_row_seats: "None")
    return config
}

public func exampleCharge(changingState: String = "Charging") -> ChargeState {
    ChargeState(battery_heater_on: true, battery_level: 81, battery_range: 235.5, est_battery_range: 254.3, charge_energy_added: 9.3, charge_limit_soc: 80, charging_state: changingState, supercharger_session_trip_planner: false, scheduled_charging_mode: "startAt", scheduled_charging_pending: true, scheduled_charging_start_time: 1701959400, scheduled_departure_time: 1688773500, preconditioning_enabled: true, off_peak_charging_enabled: true, charger_actual_current: 16, charger_power: 24, charger_voltage: 240, minutes_to_full_charge: 321, time_to_full_charge: 0.89, charge_port_door_open: true, charge_miles_added_rated: 24, charge_rate: 120)
}

public func exampleClimate() -> ClimateState {
    let climate = ClimateState(battery_heater: true, is_climate_on: true, is_auto_conditioning_on: true, is_front_defroster_on: false, inside_temp: 30, outside_temp: -15.6, driver_temp_setting: 21.5, passenger_temp_setting: 19.5, climate_keeper_mode: "dog", seat_heater_left: 0, seat_heater_right: 1, seat_heater_rear_left: 2, seat_heater_rear_center: 0, seat_heater_rear_right: 3, side_mirror_heaters: false, wiper_blade_heater: false, steering_wheel_heater: false, cabin_overheat_protection: "FanOnly")
    return climate
}

public func exampleVehicle() -> VehicleState {
    let update = SoftwareUpdate(download_perc: 1, install_perc: 0, expected_duration_sec: 2700, status: "downloading_wifi_wait", version: "2021.36.5")
    let vehicle = VehicleState(api_version: 14, car_version: "2020.48.26 e3178ea250ba", locked: true, df: 0, pf: 0, dr: 0, pr: 0, ft: 0, rt: 0, fd_window: 1, fp_window: 0, rd_window: 0, rp_window: 0, tpms_pressure_fl: 2.6, tpms_pressure_fr: 2.7, tpms_pressure_rl: 2.8, tpms_pressure_rr: 2.825, tpms_rcp_front_value: 2.9, tpms_rcp_rear_value: 2.75, odometer: 12345, sentry_mode: true, sentry_mode_available: true, remote_start: false, remote_start_enabled: true, remote_start_supported: true, timestamp: 1630670107964, software_update: update)
    return vehicle
}

public func exampleData(state: String = "online", isChanging: Bool = true) -> TeslaStore {
    let gui = GuiSetting(gui_24_hour_time: true, gui_charge_rate_units: "km/hr", gui_distance_units: "km/hr", gui_range_display: "Rated", gui_temperature_units: "C", show_range_units: false)
    let tesla = TeslaStore(id: 23456789, id_s: "23456789", user_id: 12345, vehicle_id: 24680, vin: "YYKKPP0099KK", access_type: "OWNER", state: state, display_name: "Demo", fetchDate: Date().addingTimeInterval(-5*60), vehicle_config: exampleConfig(), drive_state: exampleDrive(), gui_settings: gui, charge_state: exampleCharge(changingState: isChanging ? "Charging" : "Normal"), climate_state: exampleClimate(), vehicle_state: exampleVehicle())
    
    return tesla
}
