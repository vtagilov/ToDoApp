//
//  TodoItemsViewModel.swift
//  ToDoApp
//
//  Created by Владимир on 02.07.2024.
//

import Foundation

final class TodoItemsViewModel: ObservableObject {
    @Published private(set) var items: [TodoItem] {
        didSet {
            uncompletedItems = items.filter({ !$0.isDone })
        }
    }
    @Published private(set) var uncompletedItems = [TodoItem]()
    
    private let cache = FileCache()
    private let defaultFileName = "TodoItemList"
    
    init() {
        cache.loadItemsFromFile(defaultFileName)
        items = cache.items
        uncompletedItems = items.filter({ !$0.isDone })
    }
    
    func addItem(_ item: TodoItem) {
        if items.contains(where: { $0.id == item.id }) {
            updateItem(item)
        } else {
            items.append(item)
        }
        cache.addItem(item)
        cache.saveItemsToFile(defaultFileName)
    }
    
    func removeItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
        cache.removeItem(item.id)
        cache.saveItemsToFile(defaultFileName)
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
            cache.removeItem(item.id)
            cache.addItem(item)
            cache.saveItemsToFile(defaultFileName)
        }
    }
    
    private func updateItem(_ newItem: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == newItem.id }) {
            items[index] = newItem
        }
        cache.updateItem(newItem)
    }
}