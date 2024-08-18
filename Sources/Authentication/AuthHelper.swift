//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/8/2.
//

import Foundation
import CryptoKit

class AuthHelper {
    private let oAuthWebClientID: String = "8abda58990ce-4c12-bcb2-6e4f35447166"
    private let oAuthWebClientSecret: String = "ta-secret.K!VHq-lnUUI8DFQd"
    private let oAuthOneRedirectURI: String = "https://www.amosstudio.com.cn/callback"
    private let oAuthScope: String = "openid offline_access vehicle_device_data vehicle_cmds vehicle_charging_cmds"
    private let oAuthNonce: String = "amostesla"
    private let oAuthAudience: String = "https://fleet-api.prd.cn.vn.cloud.tesla.cn"
    
    // 随机生成的长度为86的字符串
    private let oAuthClientSecret: String = "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3"
    
    private let oAuthMethod = "S256"
    private let oAuthGrantType = "urn:ietf:params:oauth:grant-type:jwt-bearer"
    
    var email: String
    var password: String
    
    init(_ email: String = "",
         _ password: String = "") {
        if let key = KeyChainManager().fetch() {
            self.email = key.username
            self.password = key.password
        }else {
            self.email = email
            self.password = password
        }
    }
    
    // MARK: - Step 1 - 获取登录页面
    var stepOneParameter: [String: String] {
        [
            "client_id": oAuthWebClientID,
            "locale": "en-US",
            "prompt": "login",
            "redirect_uri": oAuthOneRedirectURI,
            "response_type": "code",
            "scope": oAuthScope,
            "state": oAuthNonce
        ]
    }
    
    // MARK: - Step 3 - 交换调用以生成令牌 转换为 bearer token
    func bearerTokenParameter(_ code: String) -> [String: String] {
        [
            "grant_type": "authorization_code",
            "client_id": oAuthWebClientID,
            "client_secret": oAuthWebClientSecret,
            "code": code,
            "redirect_uri": oAuthOneRedirectURI,
            "scope": oAuthScope,
            "audience": oAuthAudience
        ]
    }
    
    // MARK: - Step 5 - Refresh Token 刷新令牌生成新的令牌
    func refreshParameter(_ token: String) -> [String: String] {
        [
            "grant_type": "refresh_token",
            "client_id": oAuthWebClientID,
            "refresh_token": token
        ]
    }
    
//    func parseHtml(_ data: Data?, withCredential: Bool) throws -> [String: String] {
//        guard let data else { return [:] }
//        
//        var codeParameter = [String: String]()
//        if let document = try? HTMLDocument(data: data) {
//            print("----------Parse Html hidden inputs-----------")
//            for input in document.xpath("//input") {
//                if input.attr("type") == "hidden" {
////                    print("value: \(input.attr("name") ?? ""): \(input.attr("value") ?? "")")
//                    if let name = input.attr("name"), let value = input.attr("value") {
//                        codeParameter[name] = value
//                    }
//                }
//            }
//        }
        
//        if let _ = codeParameter["sec_chlge_forward_wrap"] {
//            throw TeslaError.recaptchaError
//        }
//        
//        var hiddenPara: [String: String] = [:]
//        hiddenPara["_csrf"] = codeParameter["_csrf"]
//        hiddenPara["_phase"] = codeParameter["_phase"]
//        hiddenPara["transaction_id"] = codeParameter["transaction_id"]
//        hiddenPara["cancel"] = codeParameter["cancel"]
//        hiddenPara["identity"] = codeParameter["identity"] ?? email
//        if withCredential {
//            hiddenPara["privacy_consent"] = "1"
//            hiddenPara["credential"] = password
//        }
//        print("hiddenPara: \(hiddenPara.description)")
//        
//        return codeParameter
//    }
}

extension String {
    func parseLocationCode() -> String? {
        let urlComponents = URLComponents(
            url: URL(string: self)!,
            resolvingAgainstBaseURL: true
        )
        if let queryItems = urlComponents?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "code", let code = queryItem.value {
                    print("权鉴成功 => 解析Code：\(code)")
                    return code
                }
            }
            return nil
        }else {
            debugPrint("====> Fail to fetch authorization code")
            return nil
        }
    }
    
    static func randomString(length: Int = 86) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    var challenge: String {
        let hash = self.sha256
        let challenge = hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        return challenge
    }

    private var sha256: Data {
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)
        return Data(hashed)
    }

    func base64EncodedString() -> String {
        let verifier = self.data(using: .utf8)!.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
        return verifier
    }
}
