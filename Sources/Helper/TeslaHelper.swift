//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/8/4.
//

import Foundation
import SwiftUI

extension Dictionary {
    func print() -> String {
        var printString = "[\n"
        for (key, value) in self.enumerated() {
            printString += "\(key): \(value)\n"
        }
        printString += "]"
        return printString
    }
}

extension Locale {
    static var zhHans: Locale {
        Locale(identifier: "zh_Hans")
    }
    
    static var zhHanz: Locale {
        Locale(identifier: "zh_Hanz")
    }
    
    static var enUS: Locale {
        Locale(identifier: "en_US")
    }
    
    static var deDE: Locale {
        Locale(identifier: "de_DE")
    }
    
    /// 当前系统设置的Locale（可设置显示的语言和区域）
    static func current(
        langCode: Locale.LanguageCode? = nil,
        region: Locale.Region? = nil
    ) -> Locale {
        var components = Locale.Components(locale: .current)
        if let langCode {
            components.languageComponents.languageCode = langCode
        }
        if let region {
            components.languageComponents.region = region
        }
        
        let myLocale = Locale(components: components)
        return myLocale
    }
}

extension String {
    var urlEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    func toLocalizedKey() -> LocalizedStringKey {
        LocalizedStringKey(self)
    }
    
    func localized() -> String {
        String(
            localized: String.LocalizationValue(self),
            table: "Localizable",
            bundle: .module
        )
    }
}

extension Binding {
    static func isPresented<V>(_ value: Binding<V?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
    
    static func isOptionalPresented<V>(_ value: Binding<V?>) -> Binding<Bool?> {
        Binding<Bool?>(
            get: { value.wrappedValue != nil },
            set: { if $0 == false || $0 == nil { value.wrappedValue = nil } }
        )
    }
}

extension BinaryFloatingPoint {
    func distanceWithLocale(
        _ degit: Int = 1,
        style: Formatter.UnitStyle = .medium,
        withUnit: Bool = true
    ) -> String {
        toUnit(unit: UnitLength.miles, degit: degit, style: style, withUnit: withUnit)
    }
    
    func temperatureWithLocale(
        _ degit: Int = 1,
        options: MeasurementFormatter.UnitOptions = .naturalScale
    ) -> String {
        toUnit(unit: UnitTemperature.celsius, degit: degit, option: options)
    }
    
    // 根据系统的本地化信息显示单位和数值
    func toUnit(
        unit: Dimension,
        outUnit: Dimension? = nil,
        degit: Int = 0,
        style: Formatter.UnitStyle = .medium,
        option: MeasurementFormatter.UnitOptions = .naturalScale,
        locale: Locale = .current,
        withUnit: Bool = true
    ) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.numberFormatter.maximumFractionDigits = degit
        formatter.unitStyle = style
        if outUnit != nil {
            formatter.unitOptions = .providedUnit
        }else {
            formatter.unitOptions = option
        }
        var value = Measurement(value: Double(self), unit: unit)
        if let outUnit {
            value = value.converted(to: outUnit)
        }
        var result = formatter.string(from: value)
        if !withUnit {
            result = result.filter("0123456789.".contains)
        }
        return result
    }
    
    func toDuration(
        units: NSCalendar.Unit = [.hour, .minute],
        style: DateComponentsFormatter.UnitsStyle = .brief,
        locale: Locale = .current
    ) -> String {
        let formatter = DateComponentsFormatter()
        var calendar = Calendar.current
        calendar.locale = locale
        formatter.calendar = calendar
        formatter.unitsStyle = style
        formatter.allowedUnits = units
        
        return formatter.string(from: TimeInterval(self)) ?? "-"
    }
    
    func toLength(
        unit: UnitLength = .meters,
        outUnit: UnitLength? = nil,
        degit: Int = 1,
        style: Formatter.UnitStyle = .medium,
        locale: Locale = .current,
        withUnit: Bool = true
    ) -> String {
        self.toUnit(unit: unit, outUnit: outUnit, degit: degit, style: style, locale: locale, withUnit: withUnit)
    }
}
