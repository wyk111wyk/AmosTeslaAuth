//
//  File.swift
//  AmosTeslaAuth
//
//  Created by AmosFitness on 2024/9/12.
//

import Foundation

public struct TokenModel: Codable {

    public var access_token: String
    public var expires_TS: Double
    public var refresh_token: String
    
    init(
        access_token: String = "",
        expires_TS: Double = 0,
        refresh_token: String = ""
    ) {
        self.access_token = access_token
        self.expires_TS = expires_TS
        self.refresh_token = refresh_token
    }
    
    func isEmpty() -> Bool {
        access_token.isEmpty && refresh_token.isEmpty
    }
    
    /// 是否 Token 已过期
    func hasExpired() -> Bool {
        debugPrint("Token 过期TS：\(expires_TS)")
        debugPrint("当前 TS：\(Date().timeIntervalSince1970)")
        return expires_TS < Date().timeIntervalSince1970
    }
    
    mutating func update(
        access_token: String,
        expires_TS: Double,
        refresh_token: String
    ) {
        debugPrint("缓存新 Token 和过期时间：\(expires_TS)")
        self.access_token = access_token
        self.expires_TS = expires_TS
        self.refresh_token = refresh_token
    }
}
