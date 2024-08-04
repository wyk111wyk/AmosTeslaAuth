//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/8/4.
//

import Foundation

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
