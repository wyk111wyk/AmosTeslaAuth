//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/8/2.
//

import Foundation

class KeyChainManager {
    let serverTesla = "www.amosTesla.com"
    let accessGroup = "com.AKSocial.AmosTesla001.sharedKey"
    
    struct Credentials {
        var username: String
        var password: String
    }
    
    @discardableResult
    func save(username: String, password: String) -> Bool {
        guard !username.isEmpty && !password.isEmpty else {
            return false
        }
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: username,
                                    kSecAttrServer as String: serverTesla,
                                    kSecValueData as String: password.data(using: String.Encoding.utf8)!]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("====> Keychain save error: \(status.description)")
            return false
        }
        
        return true
    }
    
    func fetch() -> Credentials? {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: serverTesla,
                                    kSecMatchLimit as String: kSecMatchLimitOne, // 限制查询数量
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status != errSecSuccess {
            if status == errSecNoSuchAttr {
                print("====> Keychain fetch error: \(status) 查无属性")
            }else {
//                print("====> Keychain fetch error: \(status)")
            }
        }
        
        if let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
        {
            let credentials = Credentials(username: account, password: password)
            return credentials
        }
        
        return nil
    }
    
    func change(username: String, password: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: serverTesla]

        // 新的数据
        let attributes: [String: Any] = [kSecAttrAccount as String: username,
                                         kSecValueData as String: password.data(using: String.Encoding.utf8)!]
        // 更新数据
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status != errSecSuccess {
            print("====> Keychain change error: \(status)")
        }
    }
    
    func delete() {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: serverTesla]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            print("====> Keychain delete error: \(status)")
        }
    }
}
