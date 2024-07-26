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
    private var revision: Int?
    
    private let listRequestCompletion: (
        _ completion: @escaping ([TodoItem]?, Error?) -> Void,
        ListNetworkResponseModel?,
        Error?
    ) -> Void = { completion, responce, error in
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
    
    private let itemRequestCompletion: (
        _ completion: @escaping (TodoItem?, Error?) -> Void,
        ItemNetworkResponseModel?,
        Error?
    ) -> Void = { completion, response, error in
        DispatchQueue.main.async {
            if let error = error {
                completion(nil, error)
            }
            guard let networkItem = response?.element else {
                completion(nil, NetworkError.badServerResponse)
                return
            }
            completion(networkItem.getTodoItem(), nil)
        }
    }
    
    func getItemsList(completion: @escaping ([TodoItem]?, Error?) -> Void) {
        makeUniversalRequest(
            type: .GET,
            isRevisionNeeded: false,
            completion: { responce, error in
                self.listRequestCompletion(completion, responce, error)
            }
        )
    }
    
    func updateItemList(itemList: [TodoItem], completion: @escaping ([TodoItem]?, Error?) -> Void) {
        makeUniversalRequest(
            type: .PATCH,
            bodyModel: ListNetworkRequestModel(
                list: itemList.map({ ItemNetworkModel($0) })
            ),
            isRevisionNeeded: true,
            completion: { responce, error in
                self.listRequestCompletion(completion, responce, error)
            }
        )
    }

    func getItem(id: String, completion: @escaping (TodoItem?, Error?) -> Void) {
        makeUniversalRequest(
            type: .GET,
            id: id,
            isRevisionNeeded: true,
            completion: { responce, error in
                self.itemRequestCompletion(completion, responce, error)
            }
        )
    }
    
    func addItem(_ item: TodoItem, completion: @escaping (TodoItem?, Error?) -> Void) {
        makeUniversalRequest(
            type: .POST,
            bodyModel: ItemNetworkRequestModel(element: ItemNetworkModel(item)),
            isRevisionNeeded: true,
            completion: { responce, error in
                self.itemRequestCompletion(completion, responce, error)
            }
        )
    }
    
    func updateItem(_ item: TodoItem, completion: @escaping (TodoItem?, Error?) -> Void) {
        makeUniversalRequest(
            type: .PUT,
            bodyModel: ItemNetworkRequestModel(element: ItemNetworkModel(item)),
            id: item.id,
            isRevisionNeeded: true,
            completion: { responce, error in
                self.itemRequestCompletion(completion, responce, error)
            }
        )
    }
    
    func removeItem(_ item: TodoItem, completion: @escaping (TodoItem?, Error?) -> Void) {
        makeUniversalRequest(
            type: .DELETE,
            bodyModel: ItemNetworkRequestModel(element: ItemNetworkModel(item)),
            id: item.id,
            isRevisionNeeded: true,
            completion: { responce, error in
                self.itemRequestCompletion(completion, responce, error)
            }
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
