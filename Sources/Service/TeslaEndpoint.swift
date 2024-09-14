//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/8/3.
//

import Foundation
import Alamofire
import CoreLocation
/*
 https://developer.tesla.cn/docs/fleet-api?shell#overview
 Tesla Fleet API 使用限制
 设备数据限制    1个API请求/车辆/5分钟
 命令限制       50个API请求/车辆/天
 唤醒限制       5个API请求/车辆/小时
 */

public enum AllStatesEndpoints: String {
    case chargeState = "charge_state"
    case climateState = "climate_state"
    case closuresState = "closures_state"
    case driveState = "drive_state"
    case guiSettings = "gui_settings"
    case locationData = "location_data" // Same as driveState but with location
    case vehicleConfig = "vehicle_config"
    case vehicleState = "vehicle_state"
    case vehicleDataCombo = "vehicle_data_combo"

    public static var all: [AllStatesEndpoints] = [.chargeState, .climateState, .closuresState, .driveState, .guiSettings, .vehicleConfig, .vehicleState]
    public static var allWithLocation: [AllStatesEndpoints] = [.chargeState, .climateState, .closuresState, .locationData, .guiSettings, .vehicleConfig, .vehicleState]
}

public enum UserRegion: String, Identifiable {
    case china, us, europe
    
    public var id: String { self.rawValue }
    public static var allCase: [Self] {
        [.china, .us, .europe]
    }
    
    public var title: String {
        switch self {
        case .china:
            return "China or HK"
        case .us:
            return "North America or Asia"
        case .europe:
            return "Europe, Middle East or Africa"
        }
    }
    
    public var authUrl: String {
        switch self {
        case .china:
            return "https://auth.tesla.cn"
        default:
            return "https://auth.tesla.com"
        }
    }
    
    public var baseUrl: String {
        switch self {
        case .china:
            return "https://fleet-api.prd.cn.vn.cloud.tesla.cn"
        case .us:
            return "https://fleet-api.prd.na.vn.cloud.tesla.com"
        case .europe:
            return "https://fleet-api.prd.eu.vn.cloud.tesla.com"
        }
    }
}

public enum Endpoint {
    // Auth
    case oAuth2Authorization
    case oAuth2AuthorizationPost
    case oAuth2Token
    case authentication
    case oAuth2revoke
    case revoke
    case partnerAccounts
    // All vehicles
    case vehicles
    // 返回车辆的所有允许的驾驶员。该端点仅供车主使用。
    case drivers(vehicleID: String)
    // Data
    case vehicleSummary(vehicleID: String)
    case mobileAccess(vehicleID: String)
    case allStates(vehicleID: String)
    case chargeState(vehicleID: String)
    case climateState(vehicleID: String)
    case driveState(vehicleID: String)
    case guiSettings(vehicleID: String)
    case vehicleState(vehicleID: String)
    case vehicleConfig(vehicleID: String)
    case location(vehicleID: String)
    // 返回车辆当前位置附近的充电站。
    case nearbyChargingSites(vehicleID: String, count: Int?, radius: Int?, detail: Bool)
    // 远程启动车辆。需要启用无钥匙驾驶。
    case remoteStart(vehicleID: String, way: CommandInfo.ControlVehicleWay, password: String)
    case wakeUp(vehicleID: String)
    // 将位置发送至车载导航系统。
    case sendNavigationLocation(vehicleID: String, location: String)
    // 车辆前灯短暂闪烁。车辆必须处于驻车状态。
    case lights(vehicleID: String)
    // 鸣笛。车辆必须处于驻车状态。
    case horn(vehicleID: String)
    // 锁车门 / 解锁车门
    case doors(vehicleID: String, way: CommandInfo.ControlVehicleWay)
    // 控制车辆的前备箱(which_trunk: "front")或者后备箱(which_trunk: "rear")
    case frontTrunk(vehicleID: String)
    case rearTrunk(vehicleID: String)
    // 控制停放车辆的车窗。支持的命令: vent和close。关闭时，必须指定用户的纬度和经度，以确保它们在车辆的范围内（除非这是M3平台车辆）。
    case windows(
        vehicleID: String,
        way: CommandInfo.ControlVehicleWay,
        latitude: Double?,
        longitude: Double?
    )
    // 开启车内空调 / 关闭车内空调
    case climate(vehicleID: String, way: CommandInfo.ControlVehicleWay)
    // 设置车辆充电限额：0 - 100
    case chargeLimit(vehicleID: String, limit: Int)
    // 开始车辆充电 / 停止车辆充电
    case chargeSet(vehicleID: String, way: CommandInfo.ControlVehicleWay)
    // 打开充电口盖 / 关闭充电口盖
    case chargePortDoor(vehicleID: String, way: CommandInfo.ControlVehicleWay)
    // 设置驾驶员侧和/或乘客侧车厢温度（如果启用同步，则设置其他区域）
    case setTemps(vehicleID: String, temps: Double)
    // 设置方向盘加热功能的开/关。适用于不支持自动方向盘加热的车辆。
    case wheelHeater(vehicleID: String, way: CommandInfo.ControlVehicleWay)
    // 启用和禁用哨兵模式。
    case sentryMode(vehicleID: String, way: CommandInfo.ControlVehicleWay)
    // 设置空调预处理的覆盖 - 如果不使用覆盖，则它应默认为空。
    case defrost(vehicleID: String, way: CommandInfo.ControlVehicleWay)
    // 启用温度保持模式。可设置的值为 0，1，2，3。分别对应 “关闭”， “保持模式”， “宠物模式”，“露营模式”
    case climateKeeperMode(vehicleID: String, way: CommandInfo.ControlVehicleWay, mode: Int)
    // 设置充电完成的时间。 time参数是0:00过后的分钟（例如：time=120 计划在车辆当地时间凌晨 2:00 充电）
    case scheduledCharging(vehicleID: String, enable: Bool, time: Int)
    // 设置完成出发的时间。 time参数是0:00过后的分钟（例如：time=120 安排车辆当地时间凌晨 2:00 出发）
    case scheduledDeparture(vehicleID: String, enable: Bool, time: Int)
    // 更改车辆的名称。
    case setVehicleName(vehicleID: String, newName: String)
}

extension Endpoint {
    
    private var path: String {
        switch self {
        case .oAuth2Authorization, .oAuth2AuthorizationPost:
            return "/oauth2/v3/authorize"
        case .oAuth2Token:
            return "/oauth2/v3/token"
        case .oAuth2revoke:
            return "/oauth2/v3/revoke"
        case .authentication:
            return "/oauth/token"
        case .revoke:
            return "/oauth/revoke"
        case .partnerAccounts:
            return "/api/1/partner_accounts"
        case .vehicles:
            return "/api/1/vehicles"
        case .drivers(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/drivers"
        case .vehicleSummary(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)"
        case .mobileAccess(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/mobile_enabled"
        case .allStates(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/vehicle_data"
        case .chargeState(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/data_request/charge_state"
        case .climateState(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/data_request/climate_state"
        case .driveState(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/data_request/drive_state"
        case .guiSettings(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/data_request/gui_settings"
        case .nearbyChargingSites(let vehicleID, _, _, _):
            return "/api/1/vehicles/\(vehicleID)/nearby_charging_sites"
        case .vehicleState(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/data_request/vehicle_state"
        case .vehicleConfig(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/data_request/vehicle_config"
        case .location(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/vehicle_data?endpoints=location_data"
        case .wakeUp(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/wake_up"
        case .sendNavigationLocation(let vehicleID, _):
            return "/api/1/vehicles/\(vehicleID)/command/navigation_request"
        case .remoteStart(let vehicleID, _, _):
            return "/api/1/vehicles/\(vehicleID)/command/remote_start_drive"
        case .lights(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/command/flash_lights"
        case .horn(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/command/honk_horn"
        case .doors(let vehicleID, let way):
            return "/api/1/vehicles/\(vehicleID)/command/\(way == .open ? "door_unlock":"door_lock")"
        case .frontTrunk(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/command/actuate_trunk"
        case .rearTrunk(let vehicleID):
            return "/api/1/vehicles/\(vehicleID)/command/actuate_trunk"
        case .windows(let vehicleID, _, _, _):
            return "/api/1/vehicles/\(vehicleID)/command/window_control"
        case .climate(let vehicleID, let way):
            return "/api/1/vehicles/\(vehicleID)/command/\(way == .open ? "auto_conditioning_start":"auto_conditioning_stop")"
        case .chargeLimit(let vehicleID, _):
            return "/api/1/vehicles/\(vehicleID)/command/set_charge_limit"
        case .chargeSet(let vehicleID, let way):
            return way == .open ?
            "/api/1/vehicles/\(vehicleID)/command/charge_start" :
            "/api/1/vehicles/\(vehicleID)/command/charge_stop"
        case .chargePortDoor(let vehicleID, let way):
            return way == .open ?
            "/api/1/vehicles/\(vehicleID)/command/charge_port_door_open" :
            "/api/1/vehicles/\(vehicleID)/command/charge_port_door_close"
        case .setTemps(let vehicleID, _):
            return "/api/1/vehicles/\(vehicleID)/command/set_temps"
        case .wheelHeater(let vehicleID, _):
            return "/api/1/vehicles/\(vehicleID)/command/remote_steering_wheel_heater_request"
        case .sentryMode(let vehicleID, _):
            return "/api/1/vehicles/\(vehicleID)/command/set_sentry_mode"
        case .defrost(let vehicleID, _):
            return "/api/1/vehicles/\(vehicleID)/command/set_preconditioning_max"
        case .climateKeeperMode(let vehicleID, _, _):
            return "/api/1/vehicles/\(vehicleID)/command/set_climate_keeper_mode"
        case .scheduledCharging(let vehicleID, _, _):
            return "/api/1/vehicles/\(vehicleID)/command/set_scheduled_charging"
        case .scheduledDeparture(let vehicleID, _, _):
            return "/api/1/vehicles/\(vehicleID)/command/set_scheduled_departure"
        case .setVehicleName(let vehicleID, _):
            return "/api/1/vehicles/\(vehicleID)/command/set_vehicle_name"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .vehicles, .oAuth2revoke, .vehicleSummary, .mobileAccess, .allStates, .chargeState, .climateState, .driveState, .guiSettings, .vehicleState, .vehicleConfig, .location, .nearbyChargingSites, .oAuth2Authorization:
            return .get
        default:
            return .post
        }
    }
    
    public var parameter: [String: String]? {
        switch self {
        case .allStates(_):
            return ["endpoints": AllStatesEndpoints.allWithLocation.map({ $0.rawValue }).joined(separator: ";")]
        // count: 返回总数 radius: 半径（英里） detail: 包括站点详细信息
        case .nearbyChargingSites(_, let count, let radius, let detail):
            var statePara = ["detail": detail ? "true" : "false"]
            if let count { statePara["count"] = String(count) }
            if let radius { statePara["radius"] = String(radius) }
            return statePara
        case .remoteStart:
            // 开启之后进行2分钟倒计时
            if let credentials = KeyChainManager().fetch() {
                return ["password": credentials.password]
            }else {
                return nil
            }
        case .frontTrunk:
            return ["which_trunk": "front"]
        case .rearTrunk:
            return ["which_trunk": "rear"]
        case .windows(_, let way, let latitude, let longitude):
            if way == .open {
                // lat and lon values are ignored
                return ["command": "vent",
                        "lat": "0",
                        "lon": "0"]
            }else {
                let locationManager = CLLocationManager()
                if let latitude = latitude,
                   let longitude = longitude {
                    return ["command": "close",
                            "lat": "\(latitude)",
                            "lon": "\(longitude)"]
                }else if let lat = locationManager.location?.coordinate.latitude,
                         let long = locationManager.location?.coordinate.longitude {
                    return ["command": "close",
                            "lat": "\(lat)",
                            "lon": "\(long)"]
                }else {
                    return nil
                }
            }
        case .chargeLimit(_ , let limit):
            return ["percent": "\(limit)"]
        case .setTemps(_, let temps):
            return ["driver_temp": String(format: "%.1f", temps),
                    "passenger_temp": String(format: "%.1f", temps)]
        case .wheelHeater(_, let way), .sentryMode(_, let way), .defrost(_, let way):
            return ["on": way == .open ? "true" : "false"]
        // 启用温度保持模式。可设置的值为 0，1，2，3。分别对应 “关闭”， “保持模式”， “宠物模式”，“露营模式”
        case .climateKeeperMode(_, let way, let mode): // 0-off 1-on 2-dog 3-camp
            let modeContent: String = {
                if way == .open { return String(mode) }
                else { return "1" }}()
            return ["climate_keeper_mode": modeContent]
        case .scheduledCharging(_, let enable, let minAfterZero), .scheduledDeparture(_, let enable, let minAfterZero):
            let openState: String = enable ? "true" : "false"
            return ["enable": openState,
                    "time": String(minAfterZero)]
        case .setVehicleName(_, let newName):
            return ["vehicle_name": newName]
        default:
            return nil
        }
    }
    
    /*
     中国大陆地区: https://fleet-api.prd.cn.vn.cloud.tesla.cn
     北美，亚太地区(不包括中国): https://fleet-api.prd.na.vn.cloud.tesla.com
     欧洲，中东，非洲: https://fleet-api.prd.eu.vn.cloud.tesla.com
     */
    private func baseURL(_ userRegion: UserRegion) -> String {
        switch self {
        case .oAuth2Authorization, .oAuth2AuthorizationPost, .oAuth2Token, .oAuth2revoke:
            return userRegion.authUrl
        default:
            return userRegion.baseUrl
        }
    }
    
    public func urlString(_ userRegion: UserRegion) -> String {
        let url = self.baseURL(userRegion) + self.path
        debugPrint("\(method.rawValue): \(url)")
        return url
    }
}
