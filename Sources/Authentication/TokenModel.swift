//
//  File.swift
//  AmosTeslaAuth
//
//  Created by AmosFitness on 2024/9/12.
//

import Foundation
import AmosBase
import SwiftUI

public struct TokenModel {
    public var id: UUID
    
    public var access_token: String
    public var expires_TS: Double
    public var refresh_token: String
    
    public init(
        id: UUID = UUID(),
        access_token: String? = nil,
        expires_TS: Double? = 0,
        refresh_token: String = ""
    ) {
        self.id = id
        if let access_token {
            self.access_token = access_token
        }else {
            self.access_token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        }
        if let expires_TS {
            self.expires_TS = expires_TS
        }else {
            self.expires_TS = UserDefaults.standard.double(forKey: "expires_TS")
        }
        self.refresh_token = refresh_token
    }
    
    public init(cloudIdentifier: String) async {
        guard let cloudHelper = SimpleCloudHelper(
            identifier: cloudIdentifier,
            withCache: false
        ) else {
            self = TokenModel()
            return
        }
        
        guard let token: Self = try? await cloudHelper.fetchSingleCodable(
            idKey: "AmosTesla_Token",
            customKey: "TokenData"
        ) else {
            self = TokenModel()
            return
        }
        
        debugPrint("从 iCloud 初始化 TeslaToken")
        self = token
    }
    
    public func isAccessEmpty() -> Bool {
        access_token.isEmpty
    }
    
    public func isRefreshEmpty() -> Bool {
        refresh_token.isEmpty
    }
    
    /// 是否 Token 已过期，过期的话清空已有 Token
    public func hasExpired() -> Bool {
        debugPrint("Token 过期的TS：\(expires_TS) \(Date(timeIntervalSince1970: expires_TS))")
        debugPrint("当前的TS：\(Date().timeIntervalSince1970)")
        let hasExpired = expires_TS < Date().timeIntervalSince1970 || expires_TS == 0
        return hasExpired
    }
    
    public func update(
        newToken: TokenModel,
        cloudIdentifier: String
    ) -> TokenModel {
        update(
            access_token: newToken.access_token,
            expires_TS: newToken.expires_TS,
            refresh_token: newToken.refresh_token,
            cloudIdentifier: cloudIdentifier
        )
    }
    
    public func update(
        access_token: String,
        expires_TS: Double,
        refresh_token: String,
        cloudIdentifier: String
    ) -> TokenModel {
        debugPrint("更新 Token 和过期时间：\(expires_TS)")
        var tempToken = self
        tempToken.access_token = access_token
        tempToken.expires_TS = expires_TS
        tempToken.refresh_token = refresh_token
        
        UserDefaults.standard.set(access_token, forKey: "access_token")
        UserDefaults.standard.set(expires_TS, forKey: "expires_TS")
        
        Task { await self.saveToCloud(token: tempToken, cloudIdentifier: cloudIdentifier) }
        return tempToken
    }
    
    private func saveToCloud(
        token: TokenModel,
        cloudIdentifier: String
    ) async {
        guard let cloudHelper = SimpleCloudHelper(
            identifier: cloudIdentifier,
            withCache: false
        ) else {
            return
        }
        
        let idKey = "AmosTesla_Token"
        let _ = try? await cloudHelper.deleteCloudValue(idKey: idKey)
        
        let tokenData = token.toData()
        let savedRecord = try? await cloudHelper.saveDataToCloud(
            dataType: .data(tokenData),
            idKey: "AmosTesla_Token",
            customKey: "TokenData"
        )
        
        if let savedRecord {
            debugPrint("成功储存 Token 到 iCloud 服务器: \(savedRecord.recordID)")
        }
    }
}

extension TokenModel: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case cloudIdentifier
        case access_token
        case expires_TS
        case refresh_token
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.access_token = try container.decode(String.self, forKey: .access_token)
        self.expires_TS = try container.decode(Double.self, forKey: .expires_TS)
        self.refresh_token = try container.decode(String.self, forKey: .refresh_token)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(access_token, forKey: .access_token)
        try container.encode(expires_TS, forKey: .expires_TS)
        try container.encode(refresh_token, forKey: .refresh_token)
    }
}
