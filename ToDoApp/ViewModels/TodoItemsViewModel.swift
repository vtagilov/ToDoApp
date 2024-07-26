//
//  TodoItemsViewModel.swift
//  ToDoApp
//
//  Created by Владимир on 02.07.2024.
//

import Foundation
import SwiftUI
import FileCache

final class TodoItemsViewModel: ObservableObject {
    @Published private(set) var items: [TodoItem] {
        didSet {
            uncompletedItems = items.filter({ !$0.isDone })
        }
    }
    @Published private(set) var uncompletedItems = [TodoItem]()
    
    private lazy var storage = DataStorage(setItems: { self.items = $0 })
    
    init() {
        items = []
        getItems()
    }
    
    func addItem(_ item: TodoItem) {
        if items.contains(where: { $0.id == item.id }) {
            updateItem(item)
        } else {
            items.append(item)
            storage.addNewItem(item)
        }
    }
    
    func removeItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            storage.removeItem(item)
        }
    }
    
    func updateItem(_ item: TodoItem, _ isDone: Bool) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            let oldItem = items[index]
            let newItem = TodoItem(
                id: oldItem.id,
                text: oldItem.text,
                importance: oldItem.importance,
                isDone: isDone,
                creationDate: oldItem.creationDate,
                deadline: oldItem.deadline,
                editedDate: oldItem.editedDate
            )
            items[index] = newItem
            storage.updateItem(newItem)
        }
        
    }
    
    func getItems() {
        storage.fetchItems { result in
            if let error = result.error {
                print(error)
            }
            guard let items = result.items else {
                print("items nil")
                return
            }
            self.items = items
        }
    }
    
    private func updateItem(_ newItem: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == newItem.id }) {
            items[index] = newItem
            storage.updateItem(newItem)
        }
    }
}
