// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI
import Alamofire

class AuthManager {
    @AppStorage("UserRegion") private var userRegion = "china"
    let helper = AuthHelper()
    var userRegion_: UserRegion {
        .init(rawValue: userRegion) ?? .china
    }
    
    /// 车辆认证的总入口
    func requestToken(
        refreshToken: String?,
        accessToken: String?,
        expiredAt: Date
    ) async throws -> HTTPHeaders {
        guard let refreshToken,
              let accessToken else {
            throw TeslaError.authenticationRequired
        }
        
        if hasExpired(expiredAt) {
            // Token已过期,需要进行刷新
            // 只有最新的刷新令牌才有效
            debugPrint("====> Token已过期,需要进行认证刷新")
            let headers = try await refreshAccessToken(refreshToken)
            return headers
        }else {
            debugPrint("====> 权鉴仍然有效 直接使用认证信息")
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            return headers
        }
    }
    
    /// 是否 Token 已过期
    func hasExpired(_ expiredAt: Date) -> Bool {
        debugPrint("Token 过期的时间：\(expiredAt)")
        return expiredAt < Date()
    }
    
    /// 刷新 Token
    @discardableResult
    func refreshToken(_ refreshToken: String) async throws -> HTTPHeaders {
        let headers = try await refreshAccessToken(refreshToken)
        return headers
    }
}

// MARK: - 使用code来交换access token
extension AuthManager {
    // code 来自网页登录和用户授权
    func requestStep03(para: [String: String]) async throws -> String {
        debugPrint("第三步，使用code来交换access token")
        return try await withCheckedThrowingContinuation({
            contionuation in
            let endpoint = Endpoint.oAuth2Token
            AF.request(endpoint.urlString(userRegion_),
                       method: endpoint.method,
                       parameters: para,
                       encoder: JSONParameterEncoder.default)
            .responseDecodable(of: TokenState.self)
            { response in
                var debugString = "Step03 Status Code: \(response.response!.statusCode)"
                debugString += "\nREQUEST: \(endpoint.urlString(self.userRegion_))"
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
                            contionuation.resume(throwing: TeslaError.customError(msg: msg.isEmpty ? error : msg))
                        }
                        else if let access_token = result.access_token,
                                let refresh_token = result.refresh_token {
                            let expiredDate = Date().addingTimeInterval(result.expires_in ?? 28800)
//                                DataManagement().updateCurrentData(
//                                    accessExpired: expiredDate.timeIntervalSince1970,
//                                    accessToken: access_token,
//                                    refreshToken: refresh_token
//                                )
                                debugPrint("成功获取 access token")
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
    func requestRefresh(para: [String: String]) async throws -> String {
        debugPrint("开始刷新权鉴 Token")
        return try await withCheckedThrowingContinuation({ contionuation in
            let endpoint = Endpoint.oAuth2Token
            AF.request(endpoint.urlString(userRegion_),
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
                                contionuation.resume(throwing: TeslaError.customError(msg: error))
                            }else if let access_token = result.access_token,
                                     let refresh_token = result.refresh_token {
                                debugPrint("刷新 Token 成功！")
                                debugPrint("Token 将在\(result.expires_in ?? 0)秒后失效")
                                let expiredDate = Date().addingTimeInterval(result.expires_in ?? 28800)
//                                DataManagement().updateCurrentData(
//                                    accessExpired: expiredDate.timeIntervalSince1970,
//                                    accessToken: access_token,
//                                    refreshToken: refresh_token
//                                )
                                debugPrint("成功刷新获取 access token")
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

extension AuthManager {
    @discardableResult
    func transferToken(_ code: String) async throws -> HTTPHeaders {
        debugPrint("====> Step 03: 使用 Code 转换权鉴: \(code)")
        let bearer_token = try await requestStep03(
            para: self.helper.bearerTokenParameter(code))
        let access_token = try await requestAccessToken(bearer_token)
        return access_token
    }
    
    func refreshAccessToken(_ refreshToken: String) async throws -> HTTPHeaders {
        debugPrint("====> Start Refresh Token: \(refreshToken)")
        do {
            let bearer_token = try await self.requestRefresh(
                para: self.helper.refreshParameter(refreshToken))
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
    
    func requestAccessToken(_ bearer_token: String) async throws -> HTTPHeaders {
        print("----------Step 04: Fetch AccessToken Done-----------")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(bearer_token)"
        ]
//        print("====> \(bearer_token)")
        return headers
    }
}
