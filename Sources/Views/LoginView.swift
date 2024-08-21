//
//  LoginView.swift
//  AmosTesla001
//
//  Created by 吴昱珂 on 2021/1/9.
//

import SwiftUI
import Foundation

public struct LoginView: View {
    @AppStorage("UserRegion") private var userRegion = "china"
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var showLoginWebView = false
    @State private var loadingMsg: String? = nil
    @State private var failError: Error? = nil
    
    private enum FieldType: Int, Hashable, CaseIterable {
        case userName, password
    }
    @FocusState private var focusedField: FieldType?
    
    @Binding var presentState: Bool
    public let isPushIn: Bool
    
    public enum LoginState {
        case login, demo, fail(Error)
    }
    public let loginAction: (LoginState) -> Void
    
    public init(
        presentState: Binding<Bool>,
        isPushIn: Bool,
        loginAction: @escaping (LoginState) -> Void
    ) {
        if let key = KeyChainManager().fetch() {
            _username = State(wrappedValue: key.username)
            _password = State(wrappedValue: key.password)
        }
        self._presentState = presentState
        self.isPushIn = isPushIn
        self.loginAction = loginAction
    }
    
    let verticalPaddingForForm = 30.0
    public var body: some View {
        ScrollView {
            VStack(spacing: CGFloat(verticalPaddingForForm)) {
                topIcon()
                textView()
                loginButton()
                serviceLink()
                Spacer()
            }
            .padding(.top, 80)
            .padding(.horizontal, CGFloat(verticalPaddingForForm))
        }
        .background(Color.red.gradient.opacity(0.8))
        .toolbar {
            keyboardToolbarMenu()
        }
        .overlay(alignment: .topLeading) {
            dismissButton()
        }
        .overlay(alignment: .center) {
            loadingHud()
        }
        .sheet(isPresented: $showLoginWebView) {
            authWebPage()
        }
        .alert("登陆账号错误", isPresented: .isPresented($failError)) {
            Button("OK", role: .cancel){}
        } message: {
            Text(failError.debugDescription)
        }
    }
    
    @ViewBuilder
    private func dismissButton() -> some View {
        if !isPushIn {
            Button {
                presentState = false
            } label: {
                Image(systemName: "xmark.circle")
                    .imageScale(.large)
                    .symbolVariant(.fill)
                    .foregroundStyle(.regularMaterial)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func loadingHud() -> some View {
        if let loadingMsg {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 240, height: 150)
                    .foregroundStyle(.regularMaterial.opacity(0.95))
                    .shadow(radius: 10)
                VStack(spacing: 30) {
                    ProgressView()
                        .scaleEffect(2.0)
                    Text(loadingMsg)
                        .font(.headline)
                }
            }
            .offset(y: -30)
        }
    }
    
    private func topIcon() -> some View {
        VStack {
            teslaIcon()
                .resizable()
                .scaledToFit()
                .frame(width: 80)
        }
    }
    
    private func textView() -> some View {
        VStack(alignment: .trailing, spacing: 20) {
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.gray)
                ZStack(alignment: .leading) {
                    if username.isEmpty {
                        Text("Enter your Tesla account")
                        .foregroundColor(.gray) }
                    TextField("", text: $username)
                        .foregroundColor(.black)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .ignoresSafeArea(.keyboard)
                        .focused($focusedField, equals: .userName)
                        .overlay(alignment: .trailing) {
                            if !username.isEmpty {
                                Button {
                                    username = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(.gray)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            
            HStack {
                Image(systemName: "lock.rectangle")
                    .foregroundColor(.gray)
                ZStack(alignment: .leading) {
                    if password.isEmpty {
                        Text("Enter password")
                        .foregroundColor(.gray) }
                    SecureField(
                        "",
                        text: $password,
                        onCommit: {
                            // 键盘回车
                            self.startLoginProcess()
                        })
                        .foregroundColor(.black)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .ignoresSafeArea(.keyboard)
                        .focused($focusedField, equals: .password)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            
            regionPicker()
        }
    }
    
    private func regionPicker() -> some View {
        HStack {
            Text("region:").foregroundStyle(.white)
            Picker("", selection: $userRegion) {
                ForEach(UserRegion.allCase) {
                    Text($0.title).tag($0.rawValue)
                }
            }
            .tint(.white)
        }
    }
    
    private func loginButton() -> some View {
        Button(action: startLoginProcess) {
            HStack(alignment: .center) {
                Spacer()
                Text("Login")
                    .fontWeight(.bold)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 80)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.accentColor.opacity(0.8)))
                Spacer()
            }
        }
        .tint(.white)
        .buttonStyle(.plain)
        .padding(.top)
        .padding(.horizontal)
        .frame(height: 60)
        .keyboardShortcut(.defaultAction)
        .disabled(disableButton())
    }
    
    private func serviceLink() -> some View {
        Link(
            "Tesla account service",
            destination: supportLink()
        )
            .padding(.top, -15)
            .foregroundStyle(.regularMaterial)
            .buttonStyle(.plain)
    }
    
    private func teslaIcon() -> Image {
        let path = Bundle.module.path(forResource: "person_tesla", ofType: "png")!
        let image = Image(uiImage: .init(contentsOfFile: path)!)
        return image
    }
}

extension LoginView {
    private func disableButton() -> Bool {
        username.isEmpty || password.isEmpty || loadingMsg != nil
    }
    
    func startLoginProcess() {
        focusedField = nil
        
        if username == "test" && password == "test" {
            finishLogin(.demo)
        }else {
            showLoginWebView = true
            loadingMsg = "进行网站验证"
        }
    }
    
    private func finishLogin(_ state: LoginState) {
        loadingMsg = nil
        switch state {
        case .login:
            KeyChainManager().save(
                username: username,
                password: password
            )
            loginAction(state)
            self.presentState = false
        case .demo:
            loginAction(state)
            self.presentState = false
        case .fail(let error):
            debugPrint("通过网页验证失败: \(error.localizedDescription)")
            failError = error
        }
    }
    
    // 通过网页进行认证
    private func authWebPage() -> some View {
        AuthWebView(
            userRegion: UserRegion(rawValue: userRegion) ?? .china,
            presentState: $showLoginWebView
        ) {
            (result: Result<URL, Error>) in
            switch result {
                case let .success(location):
                loadingMsg = "正在获取权鉴"
                transferLocation(location.absoluteString)
                case let .failure(error):
                finishLogin(.fail(error))
            }
        }
        .overlay(alignment: .topLeading) {
            // 直接退出
            Button {
                loadingMsg = nil
                showLoginWebView = false
            } label: {
                Image(systemName: "xmark.circle")
                    .imageScale(.large)
                    .symbolVariant(.fill)
                    .foregroundStyle(.gray)
            }
            .padding()
        }
    }
    
    // 将网站编码转换为 Token
    private func transferLocation(_ location: String) {
        if let code = location.parseLocationCode() {
            Task {
                do {
                    try await AuthManager().transferToken(code)
                    finishLogin(.login)
                }catch {
                    finishLogin(.fail(error))
                }
            }
        }
    }
}

extension LoginView {
    @ToolbarContentBuilder
    private func keyboardToolbarMenu() -> some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button(action: previousField) {
                Label("Previous", systemImage: "chevron.up")
            }.disabled(!hasPreviousField())
            Button(action: nextField) {
                Label("Next", systemImage: "chevron.down")
            }.disabled(!hasNextField())
            Spacer()
            Button(action: {
                focusedField = nil
            }) {
                Label("Dismiss keyboard", 
                      systemImage: "keyboard.chevron.compact.down")
            }.imageScale(.small)
        }
    }
    
    private func previousField() {
        focusedField = focusedField.map {
            FieldType(rawValue: $0.rawValue - 1)!
        }
    }
    private func hasPreviousField() -> Bool {
        if let currentFocusedField = focusedField {
            return currentFocusedField.rawValue > 0
        }else {
            return false
        }
    }

    private func nextField() {
        focusedField = focusedField.map {
            FieldType(rawValue: $0.rawValue + 1)!
        }
    }
    private func hasNextField() -> Bool {
        if let currentFocusedField = focusedField {
            return currentFocusedField.rawValue + 1 < FieldType.allCases.count
        }else {
            return false
        }
    }
    
    private func supportLink() -> URL {
        if Locale.current.identifier.hasPrefix("zh") {
            return URL(string: "https://service.tesla.cn/user/login")!
        }else {
            return URL(string: "https://service.teslamotors.com/user/login")!
        }
    }
}

#Preview("Login", body: {
    LoginView(
        presentState: .constant(true),
        isPushIn: false
    ) { _ in }
})