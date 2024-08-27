//
//  SwiftUIView.swift
//  
//
//  Created by Amos on 2024/8/26.
//

import SwiftUI

struct LoclizationView: View {
    let testText = "AccountWrongError"
    var zhText01: LocalizedStringKey {
        LocalizedStringKey(testText)
    }
    var zhText02: String {
        String(
            localized: String.LocalizationValue(testText),
            table: "Localizable",
            bundle: .module
        )
    }
    var zhText03: String {
        NSLocalizedString(
            testText,
            tableName: "Localizable",
            bundle: .module,
            value: testText,
            comment: ""
        )
    }
    
    var body: some View {
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
