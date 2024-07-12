//
//  URLSession.swift
//  ToDoApp
//
//  Created by Владимир on 12.07.2024.
//

import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        return try await withUnsafeThrowingContinuation { continuation in
            guard !Task.isCancelled else {
                continuation.resume(throwing: CancellationError())
                return
            }
            dataTask(with: urlRequest) { data, responce, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                if let data = data,
                   let responce = responce {
                    continuation.resume(returning: (data, responce))
                }
            }.resume()
        }
    }
}
