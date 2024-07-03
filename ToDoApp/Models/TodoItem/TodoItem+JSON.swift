//
//  TodoItem+JSON.swift
//  ToDoApp
//
//  Created by Владимир on 01.07.2024.
//

import Foundation

extension TodoItem {
    enum CodingKeys: String {
        case id, text, isDone, importance, creationDate, deadline, editedDate
    }
    
    var json: Any? {
        do {
            let dict = configureDict()
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
            return jsonObject
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any] else {
            return nil
        }
        
        guard let id = dict[CodingKeys.id.rawValue] as? String,
              let text = dict[CodingKeys.text.rawValue] as? String,
              let isDone = dict[CodingKeys.isDone.rawValue] as? Bool,
              let creationTimeInterval = dict[CodingKeys.creationDate.rawValue] as? TimeInterval else {
            return nil
        }
        
        let creationDate = Date(timeIntervalSince1970: creationTimeInterval)
        
        let importanceString = dict[CodingKeys.importance.rawValue] as? String
        let importance = Importance(rawValue: importanceString ?? Importance.common.rawValue) ?? .common
        
        var deadline: Date? = nil
        if let deadlineTimeInterval = dict[CodingKeys.deadline.rawValue] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
        }
        
        var editedDate: Date? = nil
        if let editedTimeInterval = dict[CodingKeys.editedDate.rawValue] as? TimeInterval {
            editedDate = Date(timeIntervalSince1970: editedTimeInterval)
        }
        
        return TodoItem(id: id, text: text, importance: importance, isDone: isDone, creationDate: creationDate, deadline: deadline, editedDate: editedDate)
    }
    
    private func configureDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict[CodingKeys.id.rawValue] = id
        dict[CodingKeys.text.rawValue] = text
        dict[CodingKeys.isDone.rawValue] = isDone
        if importance != .common {
            dict[CodingKeys.importance.rawValue] = importance.rawValue
        }
        dict[CodingKeys.creationDate.rawValue] = creationDate.timeIntervalSince1970
        if let deadline = deadline {
            dict[CodingKeys.deadline.rawValue] = deadline.timeIntervalSince1970
        }
        if let editedDate = editedDate {
            dict[CodingKeys.editedDate.rawValue] = editedDate.timeIntervalSince1970
        }
        return dict
    }
}
