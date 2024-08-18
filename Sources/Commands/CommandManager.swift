//
//  File.swift
//  
//
//  Created by Amos on 2024/8/16.
//

import Foundation
import Alamofire
import OSLog
import Combine
import SwiftUI

private let mylog = Logger(subsystem: "CommandManager", category: "Command")
public class CommandManager {
    @AppStorage("UserRegion") private var userRegion = "china"
    public var userRegion_: UserRegion { .init(rawValue: userRegion) ?? .china }
    public let authManager = AuthManager()
    public var canceller: AnyCancellable?
    
    // 第一次验证使用
    public init() {
        self.canceller = nil
    }
    
    public func requestToken(_ message: String) async throws -> HTTPHeaders {
        mylog.info("获取权鉴的目的：\(message)")
        return try await authManager.requestToken()
    }
    
    /// 获取所有账号下的车辆
    public func fetchAllVehicles() async throws -> [VehicleStore]? {
        let headers = try await requestToken("Fetch All Vehicles")
        return try await withCheckedThrowingContinuation({ contionuation in
            let endpoint = Endpoint.vehicles
            AF.request(endpoint.urlString(userRegion_),
                       method: endpoint.method,
                       headers: headers)
            .responseDecodable(of: VehiclesRoot.self) { response in
                switch response.result {
                case .failure(let error):
                    debugPrint("====> FetchAllVehicles Error: \(error)")
//                    debugPrint(response)
                    contionuation.resume(throwing: error)
                case .success(let fetchedData):
                    if let response = fetchedData.response {
                        contionuation.resume(returning: response)
                    }else if let error = fetchedData.error {
                        debugPrint("====> FetchAllVehicles Data Error: \(error)")
                        debugPrint(response)
                        contionuation.resume(throwing: TeslaError.customError(msg: error))
                    }
                }
            }
        })
    }
    
    /// 获取单车的详细信息
    public func fetchVehicleData(_ vehicle_id: String,
                          carName: String,
                          inService: Bool?) async throws -> TeslaStore? {
        let headers = try await requestToken("Fetch Vehicle Data")
        let endpoint = Endpoint.allStates(vehicleID: vehicle_id)
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(endpoint.urlString(userRegion_),
                       method: endpoint.method,
                       parameters: endpoint.parameter,
                       headers: headers)
                .responseDecodable(of: TeslaRoot.self) { response in
//                    debugPrint(response)
                    switch response.result {
                    case .failure(let error):
                        debugPrint("====> FetchVehicleData Error: \(error)")
                        continuation.resume(with: .failure(error))
                    case .success(let fetchedData):
                        debugPrint("成功获取车辆的详细信息:")
                        debugPrint("\(fetchedData)")
                        if var modelData = fetchedData.response {
                            modelData.display_name = carName
                            modelData.in_service = inService
                            modelData.fetchDate = Date()
                            continuation.resume(with: .success(modelData))
                        }else if let error = response.error {
                            continuation.resume(with: .failure(error))
                        }else {
                            continuation.resume(with: .failure(TeslaError.customError(msg: "Unknown error")))
                        }
                    }
                }
        }
    }
    
    /// 获取车辆当前位置
    public func fetchVehicleLocation(_ vehicle_id: String) async throws -> DriveState? {
        let headers = try await requestToken("Fetch Vehicle Location")
        let endpoint = Endpoint.location(vehicleID: vehicle_id)
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(endpoint.urlString(userRegion_),
                       method: endpoint.method,
                       headers: headers)
            .responseDecodable(of: DriveRoot.self) { response in
//                    debugPrint(response)
                    switch response.result {
                    case .failure(let error):
                        debugPrint("====> FetchVehicleLocation Error: \(error)")
                        continuation.resume(with: .failure(error))
                    case .success(let fetchedData):
                        debugPrint("成功获取车辆的地点信息")
//                        debugPrint("\(fetchedData)")
                        continuation.resume(with: .success(fetchedData.response?.drive_state))
                    }
                }
        }
    }
}

extension CommandManager {
    // 获取附近的超充站信息
    public func fetchNearbyChargeSites(_ vehicle_id: String) async throws -> ChargeSiteStore? {
        let headers = try await requestToken("Fetch Nearby Charge Sites")
        let endpoint = Endpoint.nearbyChargingSites(vehicleID: vehicle_id, count: nil, radius: 40, detail: true)
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(endpoint.urlString(userRegion_),
                       method: endpoint.method,
                       headers: headers)
                .responseDecodable(of: ChargeSiteRoot.self) { response in
                    switch response.result {
                    case .failure(let error):
                        if response.response?.statusCode == 429 {
                            print("Error: Too many ChargingSites requests")
                        }else {
                            print("====> Fetch nearby sites Error: \(error)")
                        }
                        continuation.resume(with: .failure(error))
                    case .success(let fetchedData):
                        //                            print(fetchedData.response)
                        continuation.resume(with: .success(fetchedData.response))
                    }
                }
        }
    }
}

extension CommandManager {
    /// 唤醒车辆的方式
    public enum WakeUpInternal {
        case normal, siri
        
        var paramater: (count: Int, timeInterval: TimeInterval) {
            switch self {
            case .normal:
                return (4, 10)
            case .siri:
                return (3, 2.5)
            }
        }
    }
    
    public func wakeupVehicle(
        _ vehicle_id: String,
        wakeUpInternal: WakeUpInternal = .normal
    ) async throws -> Bool {
        let headers = try await requestToken("Wakeup Vehicle")
        let repeatSec = wakeUpInternal.paramater.timeInterval
        let maxCount = wakeUpInternal.paramater.count
        let stopDate = Date().addingTimeInterval(TimeInterval(maxCount * Int(repeatSec) - 1))
        
        return try await withCheckedThrowingContinuation { continuation in
            self.canceller = Timer.publish(every: repeatSec, on: .main, in: .common)
                .autoconnect()
                .sink { date in
                    Task {
                        debugPrint("进行唤醒车辆的尝试:\(Date())")
                        let endpoint = Endpoint.wakeUp(vehicleID: vehicle_id)
                        let response = await AF.request(endpoint.urlString(self.userRegion_),
                                                        method: endpoint.method,
                                                        headers: headers)
                            .serializingDecodable(WakeupRoot.self)
                            .response
                        
                        switch response.result {
                        case .success(let fetchedData):
                            debugPrint(fetchedData)
                            let wakeupState = fetchedData.response
                            if wakeupState.is_online {
                                debugPrint("成功唤醒车辆: \(vehicle_id)")
                                self.canceller?.cancel()
                                continuation.resume(returning: true)
                            }else if date > stopDate {
                                debugPrint("唤醒车辆超时，结束唤醒")
                                self.canceller?.cancel()
                                continuation.resume(returning: false)
                            }
                        case .failure(let error):
                            debugPrint(error)
                            self.canceller?.cancel()
                            continuation.resume(throwing: error)
                        }
                    }
                }
        }
    }
    
    /// 操控车辆进行
    public func controlVehicle(
        _ vehicle_id: String,
        name: String,
        driverState: DriveState? = nil,
        way: CommandInfo.ControlVehicleWay,
        part: CommandInfo.ControlVehiclePart
    ) async throws -> Bool {
        
        guard let endpoint = self.generateEndpoint(
            vehicle_id,
            driverState: driverState,
            way: way,
            part: part
        )
        else { return false }
        
        let isSuccess = try await self.commandVehicle(endpoint: endpoint)
        return isSuccess
    }
    
    /// 操控车辆的方法
    private func generateEndpoint(
        _ vehicle_id: String,
        driverState: DriveState? = nil,
        way: CommandInfo.ControlVehicleWay,
        part: CommandInfo.ControlVehiclePart
    ) -> Endpoint? {
        switch part {
        case .alwaysAsk:
            return nil
        case .remoteStart:
            let key = KeyChainManager().fetch()
            return Endpoint.remoteStart(vehicleID: vehicle_id, way: way, password: key?.password ?? "")
        case .lights:
            return Endpoint.lights(vehicleID: vehicle_id)
        case .horn:
            return Endpoint.horn(vehicleID: vehicle_id)
        case .doors:
            return Endpoint.doors(vehicleID: vehicle_id, way: way)
        case .frontTrunk:
            return Endpoint.frontTrunk(vehicleID: vehicle_id)
        case .rearTrunk:
            return Endpoint.rearTrunk(vehicleID: vehicle_id)
        case .windows:
            return Endpoint.windows(vehicleID: vehicle_id, way: way, latitude: driverState?.latitude, longitude: driverState?.longitude)
        case .climate:
            return Endpoint.climate(vehicleID: vehicle_id, way: way)
        case .chargeLimit:
            return Endpoint.chargeLimit(vehicleID: vehicle_id, limit: way.percent())
        case .chargeSet:
            return Endpoint.chargeSet(vehicleID: vehicle_id, way: way)
        case .chargePortDoor:
            return Endpoint.chargePortDoor(vehicleID: vehicle_id, way: way)
        case .setTemps(let temps):
            return Endpoint.setTemps(vehicleID: vehicle_id, temps: temps)
        case .wheelHeater:
            return Endpoint.wheelHeater(vehicleID: vehicle_id, way: way)
        case .defrost:
            return Endpoint.defrost(vehicleID: vehicle_id, way: way)
        case .sentry:
            return Endpoint.sentryMode(vehicleID: vehicle_id, way: way)
        case .dogMode:
            return Endpoint.climateKeeperMode(vehicleID: vehicle_id, way: way, mode: 2)
        case .campMode:
            return Endpoint.climateKeeperMode(vehicleID: vehicle_id, way: way, mode: 3)
        }
    }
    
    private func commandVehicle(endpoint: Endpoint) async throws -> Bool {
        let headers = try await requestToken("Command Vehicle")
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(endpoint.urlString(userRegion_),
                       method: endpoint.method,
                       parameters: endpoint.parameter,
                       encoder: JSONParameterEncoder.default,
                       headers: headers).responseDecodable(of: CommandResponse.self)
            { response in
                debugPrint("执行指令后的回调: \(response)")
                switch response.result {
                case .failure(let error):
                    continuation.resume(with: .failure(error))
                case .success(let result):
                    if let error = result.error {
                        print("====> Share error: \(error)")
                        continuation.resume(with: .failure(TeslaError.customError(msg: error)))
                    }else if let subresponse = result.response {
//                        debugPrint("指令执行结果: \(subresponse.result.toString())")
                        continuation.resume(with: .success(subresponse.result))
                    }
                }
            }
        }
    }
}
