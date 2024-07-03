//
//  DateConverter.swift
//  ToDoApp
//
//  Created by Владимир on 29.06.2024.
//

import Foundation

extension DateFormatter {
    static func convertToStringDayMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    static func convertToStringDayMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
