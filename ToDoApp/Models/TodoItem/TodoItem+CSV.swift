//
//  TodoItem+CSV.swift
//  ToDoApp
//
//  Created by Владимир on 01.07.2024.
//

import Foundation

extension TodoItem {
    static let csvHeader = "\(CodingKeys.id.rawValue),\(CodingKeys.text.rawValue),\(CodingKeys.isDone.rawValue),\(CodingKeys.importance.rawValue),\(CodingKeys.creationDate.rawValue),\(CodingKeys.deadline.rawValue),\(CodingKeys.editedDate.rawValue)\n"
    
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
