//
//  TodoItem.swift
//  ToDoApp
//
//  Created by Владимир on 21.06.2024.
//

import Foundation
import SwiftUI
import FileCache

struct TodoItem: Identifiable, Cashable {
    enum Importance: String {
        case unimportant
        case common
        case important
    }
    enum Category: String, Identifiable {
        case work
        case study
        case hobby
        case other
        
        var id: String {
            self.rawValue
        }
        var color: Color {
            switch self {
            case .work:
                return Color.Palette.Red.color
            case .study:
                return Color.Palette.Blue.color
            case .hobby:
                return Color.Palette.Green.color
            case .other:
                return .clear
            }
        }
    }
    
    let id: String
    let text: String
    let importance: Importance
    let isDone: Bool
    let category: Category
    let creationDate: Date
    let deadline: Date?
    let editedDate: Date?
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance = .common,
        isDone: Bool = false,
        category: Category = .other,
        creationDate: Date = Date(),
        deadline: Date? = nil,
        editedDate: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.isDone = isDone
        self.category = category
        self.creationDate = creationDate
        self.deadline = deadline
        self.editedDate = editedDate
    }
}
