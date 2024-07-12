//
//  TodoItem+CSV.swift
//  ToDoApp
//
//  Created by Владимир on 01.07.2024.
//

import Foundation

extension TodoItem {
    static let csvHeader = """
        \(CodingKeys.id.rawValue),
        \(CodingKeys.text.rawValue),
        \(CodingKeys.isDone.rawValue),
        \(CodingKeys.category.rawValue),
        \(CodingKeys.importance.rawValue),
        \(CodingKeys.creationDate.rawValue),
        \(CodingKeys.deadline.rawValue),
        \(CodingKeys.editedDate.rawValue)
        \n
        """
    
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
        return """
                \(id),
                \(text),
                \(isDone.description),
                \(category.rawValue),
                \(importance.rawValue),
                \(creationDate.timeIntervalSince1970),
                \(deadline),
                \(editedDate)
                """
    }
    
    static func parse(csv: String) -> TodoItem? {
        let columns = csv.split(separator: ",").map { String($0) }
        
        if columns.count < 8 {
            return nil
        }
        if columns.count > 8 {
            return parseWithLongText(columns: columns)
        }
        
        let id = columns[0]
        let text = columns[1]
        let isDone = Bool(columns[2]) ?? false
        let category = Category(rawValue: columns[3]) ?? .other
        let importance = Importance(rawValue: columns[4]) ?? .common
        let creationDate = Date(timeIntervalSince1970: TimeInterval(columns[5]) ?? 0)
        let deadline = columns[6] == " " ? nil : Date(timeIntervalSince1970: TimeInterval(columns[6]) ?? 0)
        let editedDate = columns[7] == " " ? nil : Date(timeIntervalSince1970: TimeInterval(columns[7]) ?? 0)
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            isDone: isDone,
            category: category,
            creationDate: creationDate,
            deadline: deadline,
            editedDate: editedDate
        )
    }
    
    static private func parseWithLongText(columns: [String]) -> TodoItem? {
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
        let category = Category(rawValue: columns[index + 1]) ?? .other
        let importance = Importance(rawValue: columns[index + 2]) ?? .common
        let creationDate = Date(timeIntervalSince1970: TimeInterval(columns[index + 3]) ?? 0)
        let deadline: Date?
        if columns[index + 4] == " " {
            deadline = nil
        } else {
            let timeInterval = TimeInterval(columns[index + 4]) ?? 0
            deadline = Date(timeIntervalSince1970: timeInterval)
        }
        let editedDate: Date?
        if columns[index + 5] == " " {
            editedDate = nil
        } else {
            let timeInterval = TimeInterval(columns[index + 5]) ?? 0
            editedDate = Date(timeIntervalSince1970: timeInterval)
        }
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            isDone: isDone,
            category: category,
            creationDate: creationDate,
            deadline: deadline,
            editedDate: editedDate
        )
    }
}
