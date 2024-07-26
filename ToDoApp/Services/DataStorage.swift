//
//  DataStorage.swift
//  ToDoApp
//
//  Created by Владимир on 26.07.2024.
//

import Foundation
import FileCache

final class DataStorage {
    public typealias ManyItemsResult = (items: [TodoItem]?, error: Error?)
    public typealias OneItemResult =  (item: TodoItem?, error: Error?)
    
    var setItems: ([TodoItem]) -> Void
    
    private let networkService = NetworkService()
    private let cache = FileCache()
    
    private(set) var isDirty: Bool {
            get {
                return UserDefaults.standard.bool(forKey: isDirtyKey)
            }
            set {
                UserDefaults.standard.setValue(newValue, forKey: isDirtyKey)
            }
        }
    
    private let isDirtyKey = "isDirtyKey"
    
    private lazy var errorHandler: (Error) -> Void = { error in
        if let error = error as? NetworkError {
            LoggerSetup.shared.logError("NetworkError: \(error.errorDescription)")
            self.isDirty = true
        } else if let error = error as? CacheError {
            LoggerSetup.shared.logError("CacheError: \(error.errorDescription)")
        }
        LoggerSetup.shared.logError("StorageError: \(error)")
    }
    
    init(setItems: @escaping ([TodoItem]) -> Void) {
        self.setItems = setItems
    }
    
    func fetchItems(completion: @escaping (ManyItemsResult) -> Void) {
        getItemsFromCache(completion: completion)
        mergeItemsFromCacheIfNeeded()
        networkService.getItemsList { items, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorHandler(error)
                    return
                }
                guard let items = items else {
                    self.errorHandler(NetworkError.badServerResponse)
                    return
                }
                completion((items, nil))
                
//                self.cache.setItems(items.map({ $0.getPersistenceModel() }))
            }
        }
    }
    
    func addNewItem(_ item: TodoItem) {
        cache.insert(item.getPersistenceModel())
        mergeItemsFromCacheIfNeeded()
        networkService.addItem(item) { item, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorHandler(error)
                    return
                }
                guard item != nil else {
                    self.errorHandler(NetworkError.badServerResponse)
                    return
                }
            }
        }
    }
    
    func updateItem(_ changedItem: TodoItem) {
        cache.update(changedItem.getPersistenceModel())
        mergeItemsFromCacheIfNeeded()
        networkService.updateItem(
            changedItem,
            completion: { item, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorHandler(error)
                        return
                    }
                    guard item != nil else {
                        self.errorHandler(NetworkError.badServerResponse)
                        return
                    }
                }
            }
        )
    }
    
    func removeItem(_ item: TodoItem) {
        cache.delete(item.getPersistenceModel())
        mergeItemsFromCacheIfNeeded()
        networkService.removeItem(
            item,
            completion: { item, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorHandler(error)
                        return
                    }
                    guard item != nil else {
                        self.errorHandler(NetworkError.badServerResponse)
                        return
                    }
                }
        })
    }
    
    private func setItemsToNetwork(_ items: [TodoItem]) {
        self.networkService.updateItemList(
            itemList: items) { items, error in
                if error != nil {
                    return
                }
                guard let items = items else {
                    return
                }
                self.setItems(items)
                self.isDirty = false
            }
    }
    
    private func mergeItemsFromCacheIfNeeded() {
        if isDirty {
            getItemsFromCache { (items, error) in
                if error != nil {
                    return
                }
                guard let items = items else {
                    return
                }
                self.setItemsToNetwork(items)
            }
        }
    }
    
    private func getItemsFromCache(completion: @escaping (ManyItemsResult) -> Void) {
        cache.fetch { (items, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion((nil, error))
                    return
                }
                guard let persistenceItems = items else {
                    completion((nil, error))
                    return
                }
                let items = persistenceItems.map({ TodoItem(persistenceModel: $0) })
                completion((items, nil))
            }
        }
    }
}
