//
//  SwiftUIView.swift
//  
//
//  Created by Amos on 2024/8/26.
//

import SwiftUI

public struct LoclizationView: View {
    let testText = "AccountWrongError"
    var zhText01: LocalizedStringKey {
        LocalizedStringKey(testText)
    }
    var zhText02: String {
        let value = String.LocalizationValue(testText)
        let text = String(
            localized: value,
            bundle: .module
        )
        return text
    }
    var zhText03: String {
        String(localized: "AccountWrongError", defaultValue: "", bundle: .module)
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey(testText), bundle: .module)
            Text(zhText01, bundle: .module)
            Text(zhText02)
            Text(zhText03)
        }
    }
}

#Preview {
    LoclizationView()
        .environment(\.locale, Locale(identifier: "zh_Hans"))
}
