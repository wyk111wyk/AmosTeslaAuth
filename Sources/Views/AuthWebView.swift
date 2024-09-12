//
//  File.swift
//  
//
//  Created by Amos on 2024/8/15.
//

import Foundation
import SwiftUI
#if !os(watchOS)
@preconcurrency import WebKit
#endif
import OSLog

/*
 进行网页认证需要将 web 链接在特斯拉 Fleet 进行绑定
 */
#if os(iOS)
private let mylog = Logger(subsystem: "AuthWebView", category: "Auth")
public struct AuthWebView: UIViewRepresentable {
    init(userRegion: UserRegion,
         presentState: Binding<Bool>,
         result: ((Result<URL, Error>) -> Void)?) {
        
        let endpoint = Endpoint.oAuth2Authorization
        var urlString = endpoint.urlString(userRegion) + "?"
        for (key, value) in AuthHelper().stepOneParameter {
            urlString = urlString + key.urlEncoded + "=" + value.urlEncoded + "&"
        }
        urlString.remove(at: urlString.index(before: urlString.endIndex))
        mylog.log("开启网页Web认证")
        mylog.log("Web认证LINK: \(urlString)")
        self.urlString = urlString
        self._presentState = presentState
        self.result = result
    }
    
    init(urlString: String, presentState: Binding<Bool>) {
        self.urlString = urlString
        self._presentState = presentState
    }
    
    let urlString: String
    var url: URL {
        URL(string: urlString)!
    }
    var result: ((Result<URL, Error>) -> Void)?
    
    @Binding var presentState: Bool
    
    public func makeCoordinator() -> AuthCoordinator {
        AuthCoordinator(for: self)
    }
    
    public func makeUIView(context: UIViewRepresentableContext<AuthWebView>) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = context.coordinator

        let request = URLRequest(url: self.url)
        webview.load(request)

        return webview
    }

    public func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<AuthWebView>) {
//        print("Web update url: \(webview.url?.absoluteString ?? "")")
        let request = URLRequest(url: self.url)
        webview.load(request)
    }
}

public class AuthCoordinator: NSObject, WKNavigationDelegate {
    
    var parent: AuthWebView
    init(for parent: AuthWebView) {
        self.parent = parent
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    /*
     https://www.amosstudio.com.cn/callback?
     locale=en-US&
     code=CN_519e9831d40028ef4b9cc298b6c1bf9bd352414c4d7fb30b1a03f8235750&
     state=yNDUWHdFrLhM7W4&
     issuer=https%3A%2F%2Fauth.tesla.cn%2Foauth2%2Fv3
     */
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
            url.absoluteString.starts(with: "https://www.amosstudio.com.cn/callback")  {
            decisionHandler(.cancel)
            
            let urlString = url.absoluteString
            mylog.log("Web回调URL: \(urlString)")
            self.parent.result?(.success(url))
            self.parent.presentState = false
        } else {
            decisionHandler(.allow)
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.parent.result?(.failure(TeslaError.authenticationFailed))
        self.parent.presentState = false
    }
}
#endif
