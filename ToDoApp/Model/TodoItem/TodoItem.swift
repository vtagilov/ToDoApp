//
//  TodoItem.swift
//  ToDoApp
//
//  Created by Владимир on 21.06.2024.
//

import Foundation

struct TodoItem: Identifiable {
    enum Importance: String {
        case unimportant
        case common
        case important
    }
    
    let id: String
    let text: String
    let importance: Importance
    let isDone: Bool
    let creationDate: Date
    let deadline: Date?
    let editedDate: Date?
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance = .common,
        isDone: Bool = false,
        creationDate: Date = Date(),
        deadline: Date? = nil,
        editedDate: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.isDone = isDone
        self.creationDate = creationDate
        self.deadline = deadline
        self.editedDate = editedDate
    }
}
