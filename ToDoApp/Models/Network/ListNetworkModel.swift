//
//  ListNetworkModel.swift
//  ToDoApp
//
//  Created by Владимир on 17.07.2024.
//

import Foundation

struct ListNetworkResponseModel: Revisionable {
    let status: String
    let list: [ItemNetworkModel]
    let revision: Int
}

struct ListNetworkRequestModel: Codable {
    let list: [ItemNetworkModel]
}
