//
//  FileCache.swift
//  ToDoApp
//
//  Created by Владимир on 21.06.2024.
//

import Foundation

final class FileCache {
    enum FileType {
        case json
        case csv
    }
    
    private(set) var items: [TodoItem] = []
    
    private var cacheDirectory: URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    func addItem(_ item: TodoItem) {
        if !items.contains(where: { $0.id == item.id }) {
            items.append(item)
        }
    }
    
    @discardableResult
    func removeItem(_ itemId: String) -> TodoItem? {
        let index = items.firstIndex(where: { $0.id == itemId })
        if let index = index {
            return items.remove(at: index)
        }
        return nil
    }
    
    func updateItem(_ newItem: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == newItem.id }) {
            items[index] = newItem
        }
    }
    
    func saveItemsToFile(_ fileName: String, fileType: FileType = .json) {
        switch fileType {
        case .json:
            saveItemsToJSONFile(fileName)
        case .csv:
            saveItemsToCSVFile(fileName)
        }
    }
    
    func loadItemsFromFile(_ fileName: String, fileType: FileType = .json) {
        items = []
        switch fileType {
        case .json:
            loadItemsFromJSONFile(fileName)
        case .csv:
            loadItemsFromCSVFile(fileName)
        }
    }
}

extension FileCache {
    private func saveItemsToJSONFile(_ fileName: String) {
        let jsonObjects: [Any] = items.compactMap({ $0.json })
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObjects)
            guard let directoryPath = cacheDirectory else {
                LoggerSetup.shared.logError("saveItemsToJSONFile: Caches directory does not exist")
                return
            }
            let fileURL = directoryPath.appendingPathComponent("\(fileName).json", conformingTo: .json)
            try data.write(to: fileURL)
        } catch {
            LoggerSetup.shared.logError("saveItemsToJSONFile: \(error.localizedDescription)")
            return
        }
    }
    
    private func loadItemsFromJSONFile(_ fileName: String) {        
        guard let directoryPath = cacheDirectory else {
            LoggerSetup.shared.logError("loadItemsFromJSONFile: Caches directory does not exist")
            return
        }
        let fileURL = directoryPath.appendingPathComponent("\(fileName).json", conformingTo: .json)
        do {
            let data = try Data(contentsOf: fileURL)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [Any] else {
                LoggerSetup.shared.logError("loadItemsFromJSONFile: File is empty. Path: \(fileURL)")
                return
            }
            for jsonObject in json {
                if let item = TodoItem.parse(json: jsonObject) {
                    addItem(item)
                }
            }
        } catch {
            LoggerSetup.shared.logError("loadItemsFromJSONFile: \(error.localizedDescription)")
            return
        }
    }
}

extension FileCache {
    private func saveItemsToCSVFile(_ fileName: String) {
        let csvObjects = items.map { $0.csv }.joined(separator: "\n")
        let csvString = TodoItem.csvHeader + csvObjects
        guard let directoryPath = cacheDirectory else {
            LoggerSetup.shared.logError("saveItemsToCSVFile: Caches directory does not exist")
            return
        }
        let fileURL = directoryPath.appendingPathComponent("\(fileName).csv")

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            LoggerSetup.shared.logError("saveItemsToCSVFile: \(error.localizedDescription)")
            return
        }
    }
    
    private func loadItemsFromCSVFile(_ fileName: String) {
        guard let directoryPath = cacheDirectory else {
            LoggerSetup.shared.logError("loadItemsFromCSVFile: Caches directory does not exist")
            return
        }
        let fileURL = directoryPath.appendingPathComponent("\(fileName).csv")
        do {
            let csvString = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = csvString.split(separator: "\n").map { String($0) }
            for i in 1 ..< lines.count {
                if let item = TodoItem.parse(csv: lines[i]) {
                    addItem(item)
                }
            }
        } catch {
            LoggerSetup.shared.logError("loadItemsFromCSVFile: \(error.localizedDescription)")
            return
        }
    }
}
