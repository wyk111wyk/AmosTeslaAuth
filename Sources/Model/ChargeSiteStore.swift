//
//  File.swift
//  
//
//  Created by Amos on 2024/8/16.
//

import Foundation

struct ChargeSiteRoot: Codable {
    let response: ChargeSiteStore
}

public struct ChargeSiteStore: Codable {
    let congestion_sync_time_utc_secs: Int64
    let timestamp: Int64
    let destination_charging: [NearbyCharger]
    let superchargers: [NearbyCharger]
}

extension ChargeSiteStore {
    public static func exampleChargeSites() -> ChargeSiteStore {
        let chargeSites = ChargeSiteStore(
            congestion_sync_time_utc_secs: 1610093069,
            timestamp: 161,
            destination_charging: NearbyCharger.destinationSites(),
            superchargers: NearbyCharger.superChargeSites()
        )
        return chargeSites
    }

    public static func blankChargeSite() -> ChargeSiteStore {
        let chargeSites = ChargeSiteStore(
            congestion_sync_time_utc_secs: 1610093069,
            timestamp: 161,
            destination_charging: [],
            superchargers: []
        )
        return chargeSites
    }
}

public struct NearbyCharger: Codable {
    public struct Location: Codable {
        let lat: Double
        let long: Double
    }
    
    public let location: Location
    public let name: String // 海口特斯拉中心
    public let type: String // destination / supercharger
    public let distance_miles: Double
    public let amenities: String?
    
    // Super charge
    public let available_stalls: Int?
    public let total_stalls: Int?
    public let site_closed: Bool?
    public var address: String?
}

extension NearbyCharger: Identifiable {
    public var id: String {
        name + type + "\(distance_miles)"
    }
    public var distance_Locale: String {
        distance_miles.toUnit(unit: UnitLength.miles, degit: 1)
    }
    public var isClosed: Bool {
        site_closed ?? false
    }
    public enum ChargeType {
        case destination, supercharger, closedSupercharger
    }
    public var wrappedType: ChargeType {
        if type == "destination" {
            return .destination
        }else {
            if let closed = site_closed {
                if closed {
                    return .closedSupercharger
                }else {
                    return .supercharger
                }
            }else {
                return .supercharger
            }
        }
    }
}

extension NearbyCharger {
    public static func superChargeSites() -> [NearbyCharger] {
        let location = NearbyCharger.Location(lat: 20.003275, long: 110.258095)
        let site = NearbyCharger(location: location,
                                   name: "海口特斯拉中心",
                                   type: "supercharger",
                                 distance_miles: 1.096411,
                                 amenities: "卫生间，Wifi",
                                   available_stalls: 5,
                                   total_stalls: 6,
                                   site_closed: false)
        return Array(repeating: site, count: 5)
    }
    
    public static func destinationSites() -> [NearbyCharger] {
        let location = NearbyCharger.Location(lat: 19.995846, long: 110.299105)
        let site = NearbyCharger(location: location,
                                   name: "特来电-海口广汽新能源充电站",
                                   type: "destination",
                                   distance_miles: 2.872273,
                                 amenities: "卫生间，Wifi",
                                   available_stalls: nil,
                                   total_stalls: nil,
                                   site_closed: nil)
        return Array(repeating: site, count: 5)
    }
}
