//
//  NetworkProtocol.swift
//  ToDoApp
//
//  Created by Владимир on 17.07.2024.
//

import Foundation

protocol NetworkProtocol {
    func getItemsList(completion: @escaping ([TodoItem]?, Error?) -> Void)
    func updateItemList(itemList: [TodoItem], completion: @escaping ([TodoItem]?, Error?) -> Void)
    func getItem(id: String, completion: @escaping (TodoItem?, Error?) -> Void)
    func updateItem(_ item: TodoItem, completion: @escaping (TodoItem?, Error?) -> Void)
    func removeItem(_ item: TodoItem, completion: @escaping (TodoItem?, Error?) -> Void)
}
