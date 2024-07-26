//
//  NetworkErrors.swift
//  ToDoApp
//
//  Created by Владимир on 17.07.2024.
//

import Foundation

public enum NetworkError: LocalizedError {
    case invalidURL
    case dataEmpty
    case decodeError
    case invalidRevision
    case creationResponseError
    case badServerResponse
    
    public var errorDescription: String {
        switch self {
        case .invalidURL:
            return "Failed to create a valid URL."
        case .dataEmpty:
            return "Received empty data from the server."
        case .decodeError:
            return "Failed to decode the response data."
        case .invalidRevision:
            return "The provided revision number is invalid."
        case .creationResponseError:
            return "Error occurred while creating the response."
        case .badServerResponse:
            return "Unexpected server response received."
        }
    }
}
