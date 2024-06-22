//
//  ToDoItem.swift
//  ToDoApp
//
//  Created by Владимир on 21.06.2024.
//

import Foundation

struct TodoItem: Codable {
    enum Importance: String, Codable {
        case notImportant = "notImportant"
        case common = "common"
        case important = "important"
    }
    
    let id: String
    let text: String
    let importance: Importance
    let isDone: Bool
    let creationDate: Date
    let deadline: Date?
    let editedDate: Date?
    
    init(id: String = UUID().uuidString, text: String, importance: Importance, isDone: Bool, creationDate: Date, deadline: Date? = nil, editedDate: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.isDone = isDone
        self.creationDate = creationDate
        self.deadline = deadline
        self.editedDate = editedDate
    }
}


extension TodoItem {
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
        
        guard let id = dict["id"] as? String,
              let text = dict["text"] as? String,
              let isDone = dict["isDone"] as? Bool,
              let creationTimeInterval = dict["creationDate"] as? TimeInterval else {
            return nil
        }
        
        let creationDate = Date(timeIntervalSince1970: creationTimeInterval)
        
        let importanceString = dict["importance"] as? String
        let importance = Importance(rawValue: importanceString ?? Importance.common.rawValue) ?? .common
        
        var deadline: Date? = nil
        if let deadlineTimeInterval = dict["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimeInterval)
        }
        
        var editedDate: Date? = nil
        if let editedTimeInterval = dict["editedDate"] as? TimeInterval {
            editedDate = Date(timeIntervalSince1970: editedTimeInterval)
        }
        
        return TodoItem(id: id, text: text, importance: importance, isDone: isDone, creationDate: creationDate, deadline: deadline, editedDate: editedDate)
    }
    
    private func configureDict() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["id"] = id
        dict["text"] = text
        dict["isDone"] = isDone
        if importance != .common {
            dict["importance"] = importance.rawValue
        }
        dict["creationDate"] = creationDate.timeIntervalSince1970
        if let deadline = deadline {
            dict["deadline"] = deadline.timeIntervalSince1970
        }
        if let editedDate = editedDate {
            dict["editedDate"] = editedDate.timeIntervalSince1970
        }
        return dict
    }
}

extension TodoItem {
    var csv: String {
        var text = text
        if text.contains(where: { $0 == "," }) {
            if text.contains(where: { $0 == "\"" }) {
                text = text.replacingOccurrences(of: "\"", with: "\"\"")
            }
            text.insert("\"", at: text.startIndex)
            text.append("\"")
        }
        let deadline = deadline == nil ? " " : "\(deadline!.timeIntervalSince1970)"
        let editedDate = editedDate == nil ? " " : "\(editedDate!.timeIntervalSince1970)"
        return "\(id),\(text),\(isDone.description),\(importance.rawValue),\(creationDate.timeIntervalSince1970),\(deadline),\(editedDate)"
    }
    
    static func parse(csv: String) -> TodoItem? {
        let columns = csv.split(separator: ",").map { String($0) }
        
        if columns.count < 7 {
            return nil
        } else 
        if columns.count > 7 {
            let id = columns[0]
            var text = "\(columns[1]),"
            
            var index = 2
            for i in 2 ..< columns.count {
                text.append(columns[i])
                if columns[i].last == "\"" {
                    index = i + 1
                    break
                }
                text.append(",")
            }
            text.removeFirst()
            text.removeLast()
            text = text.replacingOccurrences(of: "\"\"", with: "\"")
            
            let isDone = Bool(columns[index]) ?? false
            let importance = Importance(rawValue: columns[index + 1]) ?? .common
            let creationDate = Date(timeIntervalSince1970: TimeInterval(columns[index + 2]) ?? 0)
            let deadline = columns[index + 3] == " " ? nil : Date(timeIntervalSince1970: TimeInterval(columns[index + 3]) ?? 0)
            let editedDate = columns[index + 4] == " " ? nil : Date(timeIntervalSince1970: TimeInterval(columns[index + 4]) ?? 0)
            return TodoItem(id: id, text: text, importance: importance, isDone: isDone, creationDate: creationDate, deadline: deadline, editedDate: editedDate)
        }
        
        let id = columns[0]
        let text = columns[1]
        let isDone = Bool(columns[2]) ?? false
        let importance = Importance(rawValue: columns[3]) ?? .common
        let creationDate = Date(timeIntervalSince1970: TimeInterval(columns[4]) ?? 0)
        let deadline = columns[5] == " " ? nil : Date(timeIntervalSince1970: TimeInterval(columns[5]) ?? 0)
        let editedDate = columns[6] == " " ? nil : Date(timeIntervalSince1970: TimeInterval(columns[6]) ?? 0)
        return TodoItem(id: id, text: text, importance: importance, isDone: isDone, creationDate: creationDate, deadline: deadline, editedDate: editedDate)
    }
}
