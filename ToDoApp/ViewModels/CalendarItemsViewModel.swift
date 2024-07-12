//
//  CalendarItemsViewModel.swift
//  ToDoApp
//
//  Created by Владимир on 04.07.2024.
//

import Foundation
import FileCache

final class CalendarItemsViewModel {
    var selectedItem: TodoItem?
    private(set) var items: [TodoItem]
    private(set) var itemsDict = [String: [TodoItem]]() // deadline: [item]
    
    private let cache: FileCache<TodoItem>
    private let defaultFileName = "TodoItemList"
    
    private(set) lazy var uniqueDeadlines = [String]()
    
    init() {
        let cacheErrorHandler: (CacheError) -> Void = { error in
            LoggerSetup.shared.logError("CacheError: \(error.errorDescription)")
        }
        cache = FileCache<TodoItem>(errorHandler: cacheErrorHandler)
        cache.loadItemsFromFile(defaultFileName)
        items = cache.items
        reloadDict()
    }
    
    func addItem(_ item: TodoItem) {
        if items.contains(where: { $0.id == item.id }) {
            updateItem(item)
        } else {
            items.append(item)
        }
        cache.addItem(item)
        cache.saveItemsToFile(defaultFileName)
        reloadDict()
    }
    
    func updateItem(_ item: TodoItem, _ isDone: Bool) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            let oldItem = items.remove(at: index)
            let newItem = TodoItem(
                id: oldItem.id,
                text: oldItem.text,
                importance: oldItem.importance,
                isDone: isDone,
                creationDate: oldItem.creationDate,
                deadline: oldItem.deadline,
                editedDate: oldItem.editedDate
            )
            items.insert(newItem, at: index)
            reloadDict()
            cache.updateItem(newItem)
            cache.saveItemsToFile(defaultFileName)
        }
    }
    
    func removeItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
        cache.removeItem(item.id)
        cache.saveItemsToFile(defaultFileName)
        reloadDict()
    }
    
    func getItemById(itemId: String) -> TodoItem? {
        return items.first(where: { $0.id == itemId })
    }
    
    func selectItemById(itemId: String) {
        selectedItem = items.first(where: { $0.id == itemId })
    }
    
    private func updateItem(_ newItem: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == newItem.id }) {
            items[index] = newItem
        }
        cache.updateItem(newItem)
    }
    
    private func reloadDict() {
        itemsDict = [:]
        uniqueDeadlines = []
        var uniqueDeadlines = [Int]()
        for item in items {
            if let deadline = item.deadline {
                let date = DateFormatter.convertToStringDayMonth(deadline)
                if itemsDict[date] == nil {
                    itemsDict[date] = []
                    uniqueDeadlines.append(Int(deadline.timeIntervalSince1970))
                }
                itemsDict[date]?.append(item)
            } else {
                if itemsDict["Другое"] == nil {
                    itemsDict["Другое"] = []
                    uniqueDeadlines.append(Int.max)
                }
                itemsDict["Другое"]?.append(item)
            }
        }
        uniqueDeadlines = uniqueDeadlines.sorted()
        self.uniqueDeadlines = uniqueDeadlines.map({
            if $0 == Int.max {
                return "Другое"
            }
            return DateFormatter.convertToStringDayMonth(.init(timeIntervalSince1970: TimeInterval($0)))
        })
    }
}
