//
//  Color+Ext.swift
//  VLC Example
//
//  Created by dtrognn on 05/06/2024.
//

import SwiftUI
public extension Color {
    init?(red: Int, green: Int, blue: Int, opacity: Double = 1.0) {
        guard red >= 0, red <= 255 else { return nil }
        guard green >= 0, green <= 255 else { return nil }
        guard blue >= 0, blue <= 255 else { return nil }

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, opacity: opacity)
    }

    init?(hexString: String, opacity: Double = 1.0) {
        var string = ""
        if hexString.lowercased().hasPrefix("0x") {
            string = hexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexString
        }

        if string.count == 3 { // convert hex to 6 digit format if in short format
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }

        guard let hexValue = Int(string, radix: 16) else { return nil }

        let red = (hexValue >> 16) & 0xff
        let green = (hexValue >> 8) & 0xff
        let blue = hexValue & 0xff
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
