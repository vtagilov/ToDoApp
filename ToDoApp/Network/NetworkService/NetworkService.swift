//
//  NetworkingService.swift
//  ToDoApp
//
//  Created by Владимир on 15.07.2024.
//

import Foundation
import FileCache

final class NetworkService: NSObject, NetworkProtocol {
    private let baseURL = "https://hive.mrdekk.ru/todo/list"
    private let token = "Maeglin"
    private let isDirtyKey = "isDirty"
    private var revision: Int?
    private let cache = FileCache<TodoItem>(errorHandler: { error in
        LoggerSetup.shared.logError("CacheError: \(error.errorDescription)")
    })
    private let cacheFileName = "TodoItemList"
    weak var viewModel: TodoItemsViewModel?
    
    func getItemsList(completion: @escaping ([TodoItem]?, Error?) -> Void) {
        let requestCompletion: (ListNetworkResponseModel?, Error?) -> Void = { responce, error in
            DispatchQueue.main.async {
                guard let networkList = responce?.list else {
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }
                    completion(nil, NetworkError.badServerResponse)
                    return
                }
                completion(networkList.map({ $0.getTodoItem() }), nil)
            }
        }
        
        makeUniversalRequest(
            type: .GET,
            isRevisionNeeded: false,
            completion: requestCompletion
        )
    }
    
    func updateItemList(itemList: [TodoItem], completion: @escaping ([TodoItem]?, Error?) -> Void) {
        let requestCompletion: (ListNetworkResponseModel?, Error?) -> Void = { response, error in
            DispatchQueue.main.async {
                guard let networkList = response?.list else {
                    UserDefaults.standard.setValue(true, forKey: self.isDirtyKey)
                    itemList.forEach({ self.cache.addItem($0) })
                    self.cache.saveItemsToFile(self.cacheFileName)
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }
                    completion(nil, NetworkError.badServerResponse)
                    return
                }
                completion(networkList.map({ $0.getTodoItem() }), nil)
                UserDefaults.standard.setValue(false, forKey: self.isDirtyKey)
            }
        }
        
        makeUniversalRequest(
            type: .PATCH,
            bodyModel: ListNetworkRequestModel(list: itemList.map({ ItemNetworkModel($0) })),
            isRevisionNeeded: true,
            completion: requestCompletion
        )
    }

    func getItem(id: String, completion: @escaping (TodoItem?, Error?) -> Void) {
        let requestCompletion: (ItemNetworkResponseModel?, Error?) -> Void = { response, error in
            DispatchQueue.main.async {
                guard let networkItem = response?.element else {
                    UserDefaults.standard.setValue(true, forKey: self.isDirtyKey)
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }
                    completion(nil, NetworkError.badServerResponse)
                    return
                }
                if UserDefaults.standard.bool(forKey: self.isDirtyKey) {
                    self.updateItemList(itemList: self.cache.items, completion: { items,_ in
                        if items != nil {
                            self.viewModel?.reloadItemsFromCache()
                            self.cache.items.forEach({ self.cache.removeItem($0.id) })
                        }
                    })
                    self.cache.items.forEach({ self.cache.removeItem($0.id) })
                }
                completion(networkItem.getTodoItem(), nil)
            }
        }
        
        makeUniversalRequest(
            type: .GET,
            id: id,
            isRevisionNeeded: true,
            completion: requestCompletion
        )
    }
    
    func addItem(_ item: TodoItem, completion: @escaping (TodoItem?, Error?) -> Void) {
        let requestCompletion: (ItemNetworkResponseModel?, Error?) -> Void = { response, error in
            DispatchQueue.main.async {
                guard let networkItem = response?.element else {
                    UserDefaults.standard.setValue(true, forKey: self.isDirtyKey)
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }
                    completion(nil, NetworkError.badServerResponse)
                    return
                }
                if UserDefaults.standard.bool(forKey: self.isDirtyKey) {
                    self.updateItemList(itemList: self.cache.items, completion: { items,_ in
                        if items != nil {
                            self.viewModel?.reloadItemsFromCache()
                            self.cache.items.forEach({ self.cache.removeItem($0.id) })
                        }
                    })
                    self.cache.items.forEach({ self.cache.removeItem($0.id) })
                }
                completion(networkItem.getTodoItem(), nil)
            }
        }
        
        makeUniversalRequest(
            type: .POST,
            bodyModel: ItemNetworkRequestModel(element: ItemNetworkModel(item)),
            isRevisionNeeded: true,
            completion: requestCompletion
        )
    }
    
    func updateItem(_ item: TodoItem, completion: @escaping (TodoItem?, Error?) -> Void) {
        let requestCompletion: (ItemNetworkResponseModel?, Error?) -> Void = { response, error in
            DispatchQueue.main.async {
                guard let networkItem = response?.element else {
                    UserDefaults.standard.setValue(true, forKey: self.isDirtyKey)
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }
                    completion(nil, NetworkError.badServerResponse)
                    return
                }
                if UserDefaults.standard.bool(forKey: self.isDirtyKey) {
                    self.updateItemList(itemList: self.cache.items, completion: { items,_ in
                        if items != nil {
                            self.viewModel?.reloadItemsFromCache()
                            self.cache.items.forEach({ self.cache.removeItem($0.id) })
                        }
                    })
                    self.cache.items.forEach({ self.cache.removeItem($0.id) })
                }
                completion(networkItem.getTodoItem(), nil)
            }
        }
        
        makeUniversalRequest(
            type: .PUT,
            bodyModel: ItemNetworkRequestModel(element: ItemNetworkModel(item)),
            id: item.id,
            isRevisionNeeded: true,
            completion: requestCompletion
        )
    }
    
    func removeItem(_ item: TodoItem, completion: @escaping (TodoItem?, Error?) -> Void) {
        let requestCompletion: (ItemNetworkResponseModel?, Error?) -> Void = { response, error in
            DispatchQueue.main.async {
                guard let networkItem = response?.element else {
                    UserDefaults.standard.setValue(true, forKey: self.isDirtyKey)
                    guard error == nil else {
                        completion(nil, error)
                        return
                    }
                    completion(nil, NetworkError.badServerResponse)
                    return
                }
                if UserDefaults.standard.bool(forKey: self.isDirtyKey) {
                    self.updateItemList(itemList: self.cache.items, completion: { items,_ in
                        if items != nil {
                            self.viewModel?.reloadItemsFromCache()
                            self.cache.items.forEach({ self.cache.removeItem($0.id) })
                        }
                    })
                    self.cache.items.forEach({ self.cache.removeItem($0.id) })
                }
                completion(networkItem.getTodoItem(), nil)
            }
        }
        
        makeUniversalRequest(
            type: .DELETE,
            bodyModel: ItemNetworkRequestModel(element: ItemNetworkModel(item)),
            id: item.id,
            isRevisionNeeded: true,
            completion: requestCompletion
        )
    }
}

extension NetworkService {
    private func makeUniversalRequest<RequestType: Encodable, ResponseType: Revisionable>(
        type: RequestTypes,
        bodyModel: RequestType,
        id: String? = nil,
        isRevisionNeeded: Bool,
        completion: @escaping (ResponseType?, Error?) -> Void
    ) {
        Task {
            do {
                let requestConfigurator = self.configureRequest(id)
                guard requestConfigurator.error == nil,
                    var request = requestConfigurator.request else {
                    completion(nil, NetworkError.creationResponseError)
                    return
                }
                
                request.httpMethod = type.rawValue
                
                let dataBody = try JSONEncoder().encode(
                    bodyModel
                )
                request.httpBody = dataBody
                
                if isRevisionNeeded {
                    guard let revision = self.revision else {
                        completion(nil, NetworkError.invalidRevision)
                        return
                    }
                    request.addValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
                }
                
                let response = try await URLSession.shared.dataTask(for: request)
                let data = response.data
                guard let response = response.response as? HTTPURLResponse else {
                    completion(nil, NetworkError.badServerResponse)
                    return
                }
                if response.statusCode >= 300 || response.statusCode < 200 {
                    completion(nil, URLError(URLError.Code(rawValue: response.statusCode)))
                    return
                }
                
                let model = try JSONDecoder().decode(ResponseType.self, from: data)
                
                self.revision = model.revision
                completion(model, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    private func makeUniversalRequest<ResponseType: Revisionable>(
        type: RequestTypes,
        id: String? = nil,
        isRevisionNeeded: Bool,
        completion: @escaping (ResponseType?, Error?) -> Void
    ) {
        Task {
            do {
                let requestConfigurator = self.configureRequest(id)
                guard requestConfigurator.error == nil,
                    var request = requestConfigurator.request else {
                    completion(nil, NetworkError.creationResponseError)
                    return
                }
                
                request.httpMethod = type.rawValue
                                
                if isRevisionNeeded {
                    guard let revision = self.revision else {
                        completion(nil, NetworkError.invalidRevision)
                        return
                    }
                    request.addValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
                }
                
                let response = try await URLSession.shared.dataTask(for: request)
                let data = response.data
                guard let response = response.response as? HTTPURLResponse else {
                    completion(nil, NetworkError.badServerResponse)
                    return
                }
                if response.statusCode >= 300 || response.statusCode < 200 {
                    completion(nil, URLError(URLError.Code(rawValue: response.statusCode)))
                    return
                }
                
                let model = try JSONDecoder().decode(ResponseType.self, from: data)
                
                self.revision = model.revision
                completion(model, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    private func configureRequest(_ id: String? = nil) -> (request: URLRequest?, error: Error?) {
        var urlStr = baseURL
        if let id = id {
            urlStr += "/\(id)"
        }
        guard let url = URL(string: urlStr) else {
            return (nil, NetworkError.invalidURL)
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return (request, nil)
    }
}
