// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI
import Alamofire
import AmosBase

public class AuthManager {
    
    @SimpleSetting(.userRegion) var userRegion
    @SimpleSetting(.access_token) var access_token
    @SimpleSetting(.refresh_token) var refresh_token
    @SimpleSetting(.expires_TS) var expires_TS
    
    public let updateCallback: () -> Void
    
    let helper = AuthHelper()
    
    public init(
        updateCallback: @escaping () -> Void
    ) {
        self.updateCallback = updateCallback
    }
    
    /// 车辆认证的总入口
    public func requestToken() async throws -> HTTPHeaders? {
        // Token 为空，用户需要先登录
        guard access_token.isNotEmpty else {
            throw TeslaError.authenticationRequired
        }
        
        // Token 已过期，需要进行刷新
        if expires_TS.hasExpired() {
            #if os(watchOS)
            throw TeslaError.authenticationRequired
            #else
            // 必须 refreshCode 不为空
            // 本地不储存 refreshCode，仅存在 iCloud 服务器多设备的保证唯一性
            guard refresh_token.isNotEmpty else {
                return nil
            }
            // 只有最新的刷新令牌，且首次刷新才有效
            debugPrint("====> Token已过期,需要进行认证de刷新")
            let headers = try await refreshAccessToken()
            return headers
            #endif
        }else {
            debugPrint("====> 权鉴仍然有效 直接使用认证信息")
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(access_token)"
            ]
            return headers
        }
    }
    
    /// 将 code 转换为 Token
    @discardableResult
    public func transferToken(
        _ code: String
    ) async throws -> HTTPHeaders {
        debugPrint("====> Step 03: 使用 Code 转换权鉴: \(code)")
        let bearer_token = try await authFromWebpage(
            para: self.helper.bearerTokenParameter(code)
        )
        let access_token = try await requestAccessToken(bearer_token)
        return access_token
    }
    
    /// bearer_token 转换为 AccessToken
    private func requestAccessToken(
        _ bearer_token: String
    ) async throws -> HTTPHeaders {
        debugPrint("====> Step 04: Fetch AccessToken Done")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(bearer_token)"
        ]
        return headers
    }
}

// MARK: - 刷新 Token
extension AuthManager {
    /// 刷新 Token
    @discardableResult
    public func refreshToken() async throws -> HTTPHeaders {
        let headers = try await refreshAccessToken()
        return headers
    }
    
    func refreshAccessToken() async throws -> HTTPHeaders {
        debugPrint("====> Start Refresh Token: \(refresh_token)")
        do {
            let bearer_token = try await self.requestRefresh(
                para: self.helper.refreshParameter(refresh_token))
            debugPrint("----------Step 05: Refresh Token Done-----------")
            let result = try await self.requestAccessToken(bearer_token)
            return result
        }catch {
            if error.localizedDescription == "login_required" {
                // 1. 刷新令牌已被使用；只有最新的刷新令牌才有效。 2. 用户已重置密码。
                // 重新进行登陆
                debugPrint("====> 刷新失败：需要重新进行登陆")
                throw error
            }else {
                throw error
            }
        }
    }
}

// MARK: - 使用code来交换access token
extension AuthManager {
    // code 来自网页登录和用户授权
    func authFromWebpage(
        para: [String: String]
    ) async throws -> String {
        return try await withCheckedThrowingContinuation(
            {
                contionuation in
                let endpoint = Endpoint.oAuth2Token
                AF.request(
                    endpoint.urlString(userRegion),
                    method: endpoint.method,
                    parameters: para,
                    encoder: JSONParameterEncoder.default
                )
                .responseDecodable(of: TokenState.self)
                { response in
                    var debugString = "Step03 Status Code: \(response.response!.statusCode)"
                    debugString += "\nREQUEST: \(endpoint.urlString(SimpleDefaults[.userRegion]))"
                    debugString += "\nREQUEST PARA: \(para.print())"
                    debugPrint("\(debugString)")
                    
                    if let error = response.error {
                        debugPrint("Step 3 Error: \(error.localizedDescription)")
                        // “invalid_auth_code”可能意味着“代码”已过期
                        contionuation.resume(throwing: error)
                    }
                    else {
                        switch response.result {
                        case .failure(let error):
                            contionuation.resume(throwing: error)
                        case .success(let result):
                            if let error = result.error,
                               let msg = result.error_description {
                                contionuation.resume(
                                    throwing: TeslaError.customError(msg: msg.isEmpty ? error : msg)
                                )
                            }
                            else if let access_token = result.access_token,
                                    let refresh_token = result.refresh_token {
                                let expiredDate = Date().addingTimeInterval(result.expires_in ?? 28800)
                                SimpleDefaults[.access_token] = access_token
                                SimpleDefaults[.refresh_token] = refresh_token
                                SimpleDefaults[.expires_TS] = expiredDate.timeIntervalSince1970
                                
                                debugPrint("成功获取 access token")
//                                debugPrint("过期时间：\(String(describing: result.expires_in))")
                                Task { @MainActor in
                                    self.updateCallback()
                                }
                                contionuation.resume(returning: access_token)
                            }else {
                                contionuation.resume(throwing: TeslaError.authenticationFailed)
                            }
                        }
                    }
                }
        })
    }
}

// MARK: - 刷新权鉴的方法
extension AuthManager {
    /// 刷新 access token
    ///
    /// 刷新间隔需要5分钟以上
    func requestRefresh(
        para: [String: String]
    ) async throws -> String {
        return try await withCheckedThrowingContinuation({ contionuation in
            let endpoint = Endpoint.oAuth2Token
            AF.request(endpoint.urlString(userRegion),
                       method: endpoint.method,
                       parameters: para,
                       encoder: URLEncodedFormParameterEncoder.default)
                .responseDecodable(of: TokenState.self)
                { response in
                    if let error = response.error {
                        debugPrint("Refresh Error: \(error.localizedDescription)")
                        contionuation.resume(throwing: error)
                    }else {
                        switch response.result {
                        case .failure(let error):
                            contionuation.resume(throwing: error)
                        case .success(let result):
                            if let error = result.error {
                                debugPrint("====> Request refresh_token error: \(error)")
                                if error == "login_required" {
                                    contionuation.resume(throwing: TeslaError.authenticationRequired)
                                }else {
                                    contionuation.resume(throwing: TeslaError.customError(msg: error))
                                }
                            }else if let access_token = result.access_token,
                                     let refresh_token = result.refresh_token {
                                debugPrint("刷新 AccessToken 成功！")
                                debugPrint("过期时间：\(String(describing: result.expires_in))")
                                let expiredDate = Date().addingTimeInterval(result.expires_in ?? 28800)
                                SimpleDefaults[.access_token] = access_token
                                SimpleDefaults[.refresh_token] = refresh_token
                                SimpleDefaults[.expires_TS] = expiredDate.timeIntervalSince1970
                                
                                debugPrint("成功刷新获取新的 AccessToken")
                                Task { @MainActor in
                                    self.updateCallback()
                                }
                                contionuation.resume(returning: access_token)
                            }else {
                                contionuation.resume(throwing: TeslaError.authenticationFailed)
                            }
                        }
                    }
                }
        })
    }
}
