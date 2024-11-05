//
//  File.swift
//  AmosTeslaAuth
//
//  Created by AmosFitness on 2024/10/30.
//

import Foundation
import AmosBase

let extensionDefaults = UserDefaults(suiteName: "group.AppTesla")!

extension SimpleDefaults.Keys {
    
    public static let userRegion = Key<UserRegion>("UserRegion", default: .china, suite: extensionDefaults, iCloud: true)
    
    public static let access_token = Key<String>("access_token", default: "", suite: extensionDefaults, iCloud: true)
    public static let refresh_token = Key<String>("refresh_token", default: "", suite: extensionDefaults, iCloud: true)
    public static let expires_TS = Key<Double>("expires_TS", default: 0, suite: extensionDefaults, iCloud: true)
}

extension Double {
    public func hasExpired() -> Bool {
        debugPrint("Token 过期的TS：\(self.toString(digit: 1)) \(Date(timeIntervalSince1970: self))")
        debugPrint("当前的TS：\(Date().timeIntervalSince1970)")
        let hasExpired = self < Date().timeIntervalSince1970
        return hasExpired
    }
}
