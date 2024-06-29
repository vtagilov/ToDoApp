//
//  FileCache.swift
//  ToDoApp
//
//  Created by Владимир on 21.06.2024.
//

import Foundation

class FileCache {
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
    
    func removeItem(_ itemId: String) {
        items.removeAll(where: { $0.id == itemId })
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
                print("Caches directory does not exist")
                return
            }
            let fileURL = directoryPath.appendingPathComponent("\(fileName).json", conformingTo: .json)
            try data.write(to: fileURL)
            print("File saved! Directory: \(fileURL)")
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
    }
    
    private func loadItemsFromJSONFile(_ fileName: String) {        
        guard let directoryPath = cacheDirectory else {
            print("Caches directory does not exist")
            return
        }
        let fileURL = directoryPath.appendingPathComponent("\(fileName).json", conformingTo: .json)
        do {
            let data = try Data(contentsOf: fileURL)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [Any] else {
                print("File is empty. Path: \(fileURL)")
                return
            }
            for jsonObject in json {
                if let item = TodoItem.parse(json: jsonObject) {
                    addItem(item)
                }
            }
            print("Items successfully loaded: \(items)")
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
    }
}

extension FileCache {
    private func saveItemsToCSVFile(_ fileName: String) {
        let csvHeader = "id,text,isDone,importance,creationDate,deadline,editedDate\n"
        let csvObjects = items.map { $0.csv }.joined(separator: "\n")
        let csvString = csvHeader + csvObjects
        guard let directoryPath = cacheDirectory else {
            print("Caches directory does not exist")
            return
        }
        let fileURL = directoryPath.appendingPathComponent("\(fileName).csv")

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("File saved! Directory: \(fileURL)")
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
    }
    
    private func loadItemsFromCSVFile(_ fileName: String) {
        guard let directoryPath = cacheDirectory else {
            print("Caches directory does not exist")
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
            print("Items successfully loaded: \(items)")
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
    }
}
