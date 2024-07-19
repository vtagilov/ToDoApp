//
//  RequestTypes.swift
//  ToDoApp
//
//  Created by Владимир on 20.07.2024.
//

import Foundation

extension NetworkService {
    enum RequestTypes: String {
        case GET
        case POST
        case PATCH
        case DELETE
        case PUT
    }
}
