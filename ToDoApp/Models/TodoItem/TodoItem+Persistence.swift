//
//  TodoItem+Persistence.swift
//  ToDoApp
//
//  Created by Владимир on 26.07.2024.
//

import Foundation
import FileCache

extension TodoItem {
    init(persistenceModel: TodoItemPersistenceModel) {
        let category = TodoItem.Category(rawValue: persistenceModel.category.rawValue) ?? .other
        let importance = TodoItem.Importance(rawValue: persistenceModel.importance?.rawValue ?? "") ?? .common
        
        self.id = persistenceModel.id
        self.text = persistenceModel.text
        self.importance = importance
        self.isDone = persistenceModel.isDone
        self.category = category
        self.creationDate = persistenceModel.creationDate
        self.deadline = persistenceModel.deadline
        self.editedDate = persistenceModel.editedDate
    }
    
    func getPersistenceModel() -> TodoItemPersistenceModel {
        let importance = TodoItemPersistenceModel.Importance(rawValue: self.importance.rawValue)
        let category = TodoItemPersistenceModel.Category(rawValue: self.category.rawValue)
        return TodoItemPersistenceModel(
            id: self.id,
            text: self.text,
            importance: importance,
            isDone: self.isDone,
            category: category ?? .other,
            creationDate: self.creationDate,
            deadline: self.creationDate,
            editedDate: self.deadline
        )
    }
}
