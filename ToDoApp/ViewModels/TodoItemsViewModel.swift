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
    
    private let networkService = NetworkService()
    
    private let cache: FileCache<TodoItem>
    private let defaultFileName = "TodoItemList"
    
    init() {
        let cacheErrorHandler: (CacheError) -> Void = { error in
            LoggerSetup.shared.logError("CacheError: \(error.errorDescription)")
        }
        cache = FileCache<TodoItem>(errorHandler: cacheErrorHandler)
        cache.loadItemsFromFile(defaultFileName)
        items = cache.items
        uncompletedItems = items.filter({ !$0.isDone })
        networkService.viewModel = self
        networkService.getItemsList { items, _ in
            if let items = items {
                self.items = items
            }
        }
    }
    
    func addItem(_ item: TodoItem) {
        if items.contains(where: { $0.id == item.id }) {
            updateItem(item)
            return
        }
        items.append(item)
        
        networkService.addItem(item) {  _, _ in }
    }
    
    func removeItem(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
        networkService.removeItem(item) { _, _ in }
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
            items[index] = newItem
            networkService.updateItem(newItem) { _, _ in }
        }
        
    }
    
    func reloadItemsFromCache() {
        cache.loadItemsFromFile(defaultFileName)
        withAnimation {
            items = cache.items
        }
    }
    
    private func updateItem(_ newItem: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == newItem.id }) {
            items[index] = newItem
        }
        networkService.updateItem(newItem) { _, _ in }
    }
}
