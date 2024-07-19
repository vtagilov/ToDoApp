//
//  ItemNetworkModel.swift
//  ToDoApp
//
//  Created by Владимир on 17.07.2024.
//

import Foundation
import UIKit

struct ItemNetworkResponseModel: Revisionable {
    let status: String
    let element: ItemNetworkModel
    let revision: Int
}

struct ItemNetworkRequestModel: Codable {
    let element: ItemNetworkModel
}

struct ItemNetworkModel: Codable {
    enum Importance: String, Codable {
        case low, basic, important
    }
    let id: String
    let text: String
    let importance: Importance
    let deadline: TimeInterval?
    let done: Bool
    let color: String?
    let created_at: TimeInterval
    let changed_at: TimeInterval
    let last_updated_by: String
}

extension ItemNetworkModel {
    init(_ item: TodoItem) {
        var importance = Importance.basic
        switch item.importance {
        case .important:
            importance = .important
        case .unimportant:
            importance = .low
        case .common:
            importance = .basic
        }
        
        self.id = item.id
        self.text = item.text
        self.importance = importance
        self.deadline = item.deadline?.timeIntervalSinceNow.rounded()
        self.done = item.isDone
        // TODO: color
        self.color = nil
        self.created_at = item.creationDate.timeIntervalSince1970.rounded()
        self.changed_at = item.editedDate?.timeIntervalSince1970.rounded() ?? item.creationDate.timeIntervalSince1970.rounded()
        self.last_updated_by = UIDevice.current.identifierForVendor?.uuidString ?? "0"
    }
}

extension ItemNetworkModel {
    func getTodoItem() -> TodoItem {
        var importance = TodoItem.Importance.common
        switch self.importance {
        case .basic:
            importance = .common
        case .important:
            importance = .important
        case .low:
            importance = .unimportant
        }
        var deadline: Date? = nil
        if let deadlineTimeInterval = self.deadline {
            deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
        }
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            isDone: done,
            category: .other,
            creationDate: Date(timeIntervalSince1970: created_at),
            deadline: deadline,
            editedDate: Date(timeIntervalSince1970: changed_at)
        )
    }
    
}
