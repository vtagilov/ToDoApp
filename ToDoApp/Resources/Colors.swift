//
//  Colors.swift
//  ToDoApp
//
//  Created by Владимир on 22.06.2024.
//

import Foundation
import SwiftUI

extension Color {
    struct ThemeColors {
        let light: Color
        let dark: Color
        
        var color: Color {
            return Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? UIColor(self.dark) : UIColor(self.light)
            })
        }
    }
    
    private init(_ red: Double, _ green: Double, _ blue: Double, _ alpha: Double) {
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    struct Support {
        static let Separator = ThemeColors(light: Color(0.0, 0.0, 0.0, 0.2), dark: Color(1.0, 1.0, 1.0, 0.2))
        static let Overlay = ThemeColors(light: Color(0.0, 0.0, 0.0, 0.06), dark: Color(0.0, 0.0, 0.0, 0.32))
        static let NavBarBlur = ThemeColors(light: Color(0.98, 0.98, 0.98, 0.8), dark: Color(0.1, 0.1, 0.1, 0.9))
    }
    
    struct Label {
        static let Primary = ThemeColors(light: Color(0.0, 0.0, 0.0, 1.0), dark: Color(1.0, 1.0, 1.0, 1.0))
        static let Secondary = ThemeColors(light: Color(0.0, 0.0, 0.0, 0.6), dark: Color(1.0, 1.0, 1.0, 0.6))
        static let Tertiary = ThemeColors(light: Color(0.0, 0.0, 0.0, 0.3), dark: Color(1.0, 1.0, 1.0, 0.4))
        static let Disable = ThemeColors(light: Color(0.0, 0.0, 0.0, 0.15), dark: Color(1.0, 1.0, 1.0, 0.15))
    }
    
    struct Palette {
        static let Red = ThemeColors(light: Color(1.0, 0.23, 0.19, 1.0), dark: Color(1.0, 0.27, 0.23, 1.0))
        static let Green = ThemeColors(light: Color(0.2, 0.78, 0.35, 1.0), dark: Color(0.2, 0.84, 0.29, 1.0))
        static let Blue = ThemeColors(light: Color(0.0, 0.48, 1.0, 1.0), dark: Color(0.04, 0.52, 1.0, 1.0))
        static let Gray = ThemeColors(light: Color(0.56, 0.56, 0.58, 1.0), dark: Color(0.56, 0.56, 0.58, 1.0))
        static let GrayLight = ThemeColors(light: Color(0.82, 0.82, 0.84, 1.0), dark: Color(0.28, 0.28, 0.29, 1.0))
        static let White = ThemeColors(light: Color(1.0, 1.0, 1.0, 1.0), dark: Color(1.0, 1.0, 1.0, 1.0))
    }
    
    struct Back {
        static let iOSPrimary = ThemeColors(light: Color(0.95, 0.95, 0.97, 1.0), dark: Color(0.0, 0.0, 0.0, 1.0))
        static let Primary = ThemeColors(light: Color(0.97, 0.97, 0.95, 1.0), dark: Color(0.09, 0.09, 0.09, 1.0))
        static let Secondary = ThemeColors(light: Color(1.0, 1.0, 1.0, 1.0), dark: Color(0.14, 0.14, 0.16, 1.0))
        static let Elevated = ThemeColors(light: Color(1.0, 1.0, 1.0, 1.0), dark: Color(0.23, 0.23, 0.25, 1.0))
    }
}
