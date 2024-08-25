//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/8/3.
//

import Foundation
import Intents
import SwiftUI

public struct CommandInfo {
    public enum ForceWake: String, CaseIterable {
        case alwaysAsk = "Always ask",
             yes = "Yes",
             no = "No"
        
        func title() -> String {
            switch self {
            case .alwaysAsk:
                "Always ask".localized()
            case .yes:
                "Yes".localized()
            case .no:
                "No".localized()
            }
        }
        func convertToConfirm() -> Bool {
            if self == .yes {
                return true
            }else {
                return false
            }
        }
        func imageName() -> String {
            switch self {
            case .yes:
                return "icon_open"
            case .no:
                return "icon_close"
            case .alwaysAsk:
                return "icon_unknow"
            }
        }
        func subTitle() -> String? {
            switch self {
            case .alwaysAsk:
                return nil
            case .yes:
                return "Wake up your vehicle".localized()
            case .no:
                return "Keep your vehicle asleep".localized()
            }
        }
    }
    
    public enum ControlVehiclePart: CaseIterable, Identifiable, Equatable, Hashable {
        public static var allCases: [CommandInfo.ControlVehiclePart] {
            [.alwaysAsk, .remoteStart, .lights, .horn, .doors, .frontTrunk, .rearTrunk, .windows, .chargeLimit, .chargePortDoor, climate, .wheelHeater, .defrost, .sentry]
        }
        
        case alwaysAsk, remoteStart
        case lights, horn
        case doors, frontTrunk, rearTrunk, windows, chargeLimit, chargePortDoor, chargeSet
        case climate, setTemps(temps: Double = 20), wheelHeater, dogMode, campMode
        case sentry, defrost
        
        public var id: String { self.commandName() }
        
        func commandName() -> String {
            var tempName = ""
            switch self {
            case .remoteStart:
                tempName = "Remote start drive"
            case .lights:
                tempName = "Flash lights"
            case .horn:
                tempName = "Honk horn"
            case .doors:
                tempName = "Doors"
            case .frontTrunk:
                tempName = "Front trunk"
            case .rearTrunk:
                tempName = "Rear trunk"
            case .windows:
                tempName = "Windows"
            case .climate:
                tempName = "Air condition"
            case .chargeLimit:
                tempName = "Charge limit"
            case .chargeSet:
                tempName = "Charge state"
            case .chargePortDoor:
                tempName = "Charge port door"
            case .setTemps:
                tempName = "Temps"
            case .wheelHeater:
                tempName = "Wheel heater"
            case .sentry:
                tempName = "Sentry mode"
            case .defrost:
                tempName = "Defrost"
            case .dogMode:
                tempName = "Dog mode"
            case .campMode:
                tempName = "Camp mode"
            default:
                tempName = "-"
            }
            return tempName.localized()
        }
        
        func imageName() -> String {
            switch self {
            case .remoteStart:
                return "icon_remoteStart"
            case .lights:
                return "icon_lights"
            case .horn:
                return "icon_horn"
            case .doors:
                return "icon_doors"
            case .frontTrunk:
                return "icon_frunk"
            case .rearTrunk:
                return "icon_trunk"
            case .windows:
                return "icon_windows"
            case .climate, .setTemps, .dogMode, .campMode:
                return "icon_ac"
            case .chargeLimit:
                return "icon_battery"
            case .chargeSet:
                return "icon_chargePort"
            case .chargePortDoor:
                return "icon_chargePort"
            case .alwaysAsk:
                return "icon_vehicle"
            case .wheelHeater:
                return "icon_wheel"
            case .sentry:
                return "icon_sentry"
            case .defrost:
                return "icon_defrost"
            }
        }
        
        public static func == (lhs: CommandInfo.ControlVehiclePart, rhs: CommandInfo.ControlVehiclePart) -> Bool {
            lhs.commandName() == rhs.commandName()
        }
    }
    
    public enum ControlVehicleWay: CaseIterable, Equatable, Hashable {
        public static var allCases: [CommandInfo.ControlVehicleWay] = [.alwaysAsk, .open, .close]
        static var allChargePhases: [CommandInfo.ControlVehicleWay] {
            CommandInfo.ChargeLimitPhase.allCases.map {
                CommandInfo.ControlVehicleWay.setPercent(limit: $0.limit())
            }
        }
        public static func == (lhs: CommandInfo.ControlVehicleWay, rhs: CommandInfo.ControlVehicleWay) -> Bool {
            lhs.title() == rhs.title() &&
                lhs.percent() == lhs.percent()
        }
        static func != (lhs: CommandInfo.ControlVehicleWay, rhs: CommandInfo.ControlVehicleWay) -> Bool {
            lhs.title() != rhs.title() ||
                lhs.percent() != lhs.percent()
        }
        public func hash(into hasher: inout Hasher) {
            hasher.combine(value)
        }
        
        case alwaysAsk,
             open,
             close,
             setPercent(limit: Int),
             setTemps(temps: Double)
        
        var value: String {
            switch self {
            case .open:
                return "Open".localized()
            case .close:
                return "Close".localized()
            case .setPercent(let limit):
                return "\(limit)"
            case .setTemps(let temps):
                return String(format: "%.1f", temps)
            case .alwaysAsk:
                return "Control".localized()
            }
        }
        
        func percent() -> Int {
            switch self {
            case .setPercent(let limit):
                return limit
            default:
                return 90
            }
        }
        
        func title() -> String {
            switch self {
            case .open:
                return "Open".localized()
            case .close:
                return "Close".localized()
            case .setPercent(let limit):
                return CommandInfo.ChargeLimitPhase.phaseFromLimit(limit).subTitle()
            case .setTemps(let temps):
                return "Set temps".localized() + ": " + "\(String(format: "%.1f", temps))"
            case .alwaysAsk:
                return "Control".localized()
            }
        }
        
        func titleForDescribe(part: CommandInfo.ControlVehiclePart) -> String {
            switch self {
            case .open, .close:
                return CommandInfo.genernateWay(part: part, way: self)
            case .setPercent(let limit):
                return CommandInfo.ChargeLimitPhase.phaseFromLimit(limit).subTitle()
            case .setTemps(let temps):
                return "Set temps".localized() + ": " + "\(String(format: "%.1f", temps))"
            case .alwaysAsk:
                return "Control".localized()
            }
        }
        
        func imageName() -> String {
            switch self {
            case .open:
                return "icon_open"
            case .close:
                return "icon_close"
            case .setPercent:
                return "icon_percent"
            case .setTemps:
                return "icon_ac"
            case .alwaysAsk:
                return "icon_unknow"
            }
        }
        
        func subTitle() -> String? {
            switch self {
            case .alwaysAsk:
                return nil
            case .open:
                return "Open, vent or unlock".localized()
            case .close:
                return "Close or lock".localized()
            case .setTemps:
                return "Set ac temps".localized()
            case .setPercent:
                return "Set percentage like charge limit".localized()
            }
        }
    }
    
    /// 设置充电比例的预置选项
    public enum ChargeLimitPhase: String, CaseIterable, Identifiable {
        case fullCharge, longRange, dailyUsage, maintenance
        
        public var id: String { self.rawValue }
        
        static func phaseFromLimit(_ limit: Int) -> CommandInfo.ChargeLimitPhase {
            if limit == 100 {
                return .fullCharge
            }else if limit == 96 {
                return .longRange
            }else if limit == 90 {
                return .dailyUsage
            }else {
                return .maintenance
            }
        }
        
        func title() -> String {
            switch self {
            case .fullCharge:
                return "Full charge".localized()
            case .longRange:
                return "Long range".localized()
            case .dailyUsage:
                return "Daily usage".localized()
            case .maintenance:
                return "Maintenance".localized()
            }
        }
        
        func subTitle() -> String {
            switch self {
            case .fullCharge:
                return "100% - " + "Full charge".localized()
            case .longRange:
                return "96% - " + "Long range".localized()
            case .dailyUsage:
                return "90% - " + "Daily usage".localized()
            case .maintenance:
                return "50% - " + "Maintenance".localized()
            }
        }
        
        func limit() -> Int {
            switch self {
            case .fullCharge:
                return 100
            case .longRange:
                return 96
            case .dailyUsage:
                return 90
            case .maintenance:
                return 50
            }
        }
        
        func imageName() -> String {
            switch self {
            case .fullCharge:
                return "icon_100"
            case .longRange:
                return "icon_96"
            case .dailyUsage:
                return "icon_90"
            case .maintenance:
                return "icon_50"
            }
        }
    }
    
    /// 生成可操控部位的本地化名称
    public static func genernatePart(
        part: CommandInfo.ControlVehiclePart
    ) -> String {
        var partText = String.init()
        
        switch part {
        case .remoteStart:
            partText = "drive"
        case .lights:
            partText = "lights"
        case .horn:
            partText = "horn"
        case .doors:
            partText = "doors"
        case .frontTrunk:
            partText = "front trunk"
        case .rearTrunk:
            partText = "rear trunk"
        case .windows:
            partText = "windows"
        case .climate:
            partText = "air condition"
        case .chargeLimit:
            partText = "charge limit"
        case .chargeSet:
            partText = "charging"
        case .chargePortDoor:
            partText = "charge port door"
        case .alwaysAsk:
            partText = "part"
        case .setTemps:
            partText = "temps"
        case .wheelHeater:
            partText = "wheel heater"
        case .sentry:
            partText = "sentry mode"
        case .defrost:
            partText = "defrost"
        case .dogMode:
            partText = "dog mode"
        case .campMode:
            partText = "camp mode"
        }
        
        return partText.localized()
    }
    
    /// 通过部位生成动作的本地化名称: 打开
    public static func genernateWay(
        part: CommandInfo.ControlVehiclePart,
        way: CommandInfo.ControlVehicleWay
    ) -> String {
        var wayText = String.init()
        
        switch part {
        case .remoteStart:
            wayText = "Remote start"
        case .lights:
            wayText = "Flash"
        case .horn:
            wayText = "Honk"
        case .doors:
            switch way {
            case .open:
                wayText = "Unlock"
            case .close:
                wayText = "Lock"
            case .alwaysAsk:
                wayText = "Control"
            case .setTemps, .setPercent:
                wayText = "Set"
            }
        case .windows:
            switch way {
            case .open:
                wayText = "Vent"
            case .close:
                wayText = "Close"
            case .alwaysAsk:
                wayText = "Control"
            case .setTemps, .setPercent:
                wayText = "Set"
            }
        case .climate, .defrost, .sentry, .dogMode, .campMode:
            switch way {
            case .open:
                wayText = "Turn on"
            case .close:
                wayText = "Turn off"
            case .alwaysAsk:
                wayText = "Control"
            case .setTemps, .setPercent:
                wayText = "Set"
            }
        case .chargeLimit:
            wayText = "Set"
        case .alwaysAsk:
            wayText = "Control"
        case .setTemps:
            wayText = "Set"
        case .wheelHeater, .frontTrunk, .rearTrunk, .chargePortDoor:
            switch way {
            case .open:
                wayText = "Open"
            case .close:
                wayText = "Close"
            case .alwaysAsk:
                wayText = "Control"
            case .setTemps, .setPercent:
                wayText = "Set"
            }
        case .chargeSet:
            switch way {
            case .open:
                wayText = "Start"
            case .close:
                wayText = "Stop"
            case .alwaysAsk:
                wayText = "Control"
            case .setTemps, .setPercent:
                wayText = "Set"
            }
        }
        
        return wayText.localized()
    }
    
    public static func genernateSuggestion(
        part: CommandInfo.ControlVehiclePart,
        way: CommandInfo.ControlVehicleWay
    ) -> String {
        var partText = CommandInfo.genernatePart(part: part)
        if part == .alwaysAsk {
            partText = "vehicle".localized()
        }
        let wayText = CommandInfo.genernateWay(part: part, way: way)
        
        // 将动作和部位组合到一起
        var suggestion = wayText + " " + partText
        if part == .chargeLimit {
            suggestion = suggestion + " to \(CommandInfo.ChargeLimitPhase.phaseFromLimit(way.percent()).subTitle())"
        }
        
        return suggestion
    }
}
