//
//  ToDoItemTests.swift
//  ToDoItemTests
//
//  Created by Владимир on 21.06.2024.
//

import XCTest
@testable import ToDoApp

final class ToDoItemTests: XCTestCase {
    
    var item1: TodoItem!
    var item2: TodoItem!
    var itemWithComma: TodoItem!
    var itemWithQuotes: TodoItem!
    var date: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()
        date = Date()
        item1 = TodoItem(
            id: "17451",
            text: "This is my first Task!",
            importance: .important,
            isDone: false,
            creationDate: date,
            deadline: date.addingTimeInterval(10000),
            editedDate: date
        )
        item2 = TodoItem(
            text: "second Task",
            importance: .common,
            isDone: true,
            creationDate: date
        )
        itemWithComma = TodoItem(
            text: "item, with comma",
            importance: .common,
            isDone: true,
            creationDate: date
        )
        itemWithQuotes = TodoItem(
            text: "item, \"with\" comma",
            importance: .common,
            isDone: true,
            creationDate: date
        )
    }

    override func tearDownWithError() throws {
        item1 = nil
        item2 = nil
        itemWithComma = nil
        itemWithQuotes = nil
        date = nil
        try super.tearDownWithError()
    }
    
    func testInitialization() {
        XCTAssertNotNil(item1)
        XCTAssertEqual(item1.id, "17451")
        XCTAssertEqual(item1.text, "This is my first Task!")
        XCTAssertEqual(item1.importance, .important)
        XCTAssertFalse(item1.isDone)
        XCTAssertEqual(item1.creationDate, date)
        XCTAssertEqual(item1.deadline, date.addingTimeInterval(10000))
        XCTAssertEqual(item1.editedDate, date)
        
        XCTAssertNotNil(item2)
        XCTAssert(item2.id != "")
        XCTAssertEqual(item2.text, "second Task")
        XCTAssertEqual(item2.importance, .common)
        XCTAssertTrue(item2.isDone)
        XCTAssertEqual(item2.creationDate, date)
        XCTAssertNil(item2.deadline)
        XCTAssertNil(item2.editedDate)
    }
    
    func testJSONSerialization() throws {
        guard let json1 = item1.json as? [String: Any] else {
            XCTFail("Failed to convert to JSON")
            return
        }
        XCTAssertEqual(json1["id"] as? String, "17451")
        XCTAssertEqual(json1["text"] as? String, "This is my first Task!")
        XCTAssertEqual(json1["importance"] as? String, "important")
        XCTAssertEqual(json1["isDone"] as? Bool, false)
        XCTAssertEqual(json1["creationDate"] as? TimeInterval, date.timeIntervalSince1970)
        XCTAssertEqual(json1["deadline"] as? TimeInterval, date.addingTimeInterval(10000).timeIntervalSince1970)
        XCTAssertEqual(json1["editedDate"] as? TimeInterval, date.timeIntervalSince1970)
        
        guard let json2 = item2.json as? [String: Any] else {
            XCTFail("Failed to convert to JSON")
            return
        }
        XCTAssertEqual(json2["id"] as? String, item2.id)
        XCTAssertEqual(json2["text"] as? String, "second Task")
        XCTAssertNil(json2["importance"])
        XCTAssertEqual(json2["isDone"] as? Bool, true)
        XCTAssertEqual(json2["creationDate"] as? TimeInterval, date.timeIntervalSince1970)
        XCTAssertNil(json2["deadline"])
        XCTAssertNil(json2["editedDate"])
    }

    func testJSONDeserialization() {
        let json1: [String: Any] = [
            "id": "17451",
            "text": "This is my first Task!",
            "importance": "important",
            "isDone": false,
            "creationDate": date.timeIntervalSince1970,
            "deadline": date.addingTimeInterval(10000).timeIntervalSince1970,
            "editedDate": date.timeIntervalSince1970
        ]
        guard let item1 = TodoItem.parse(json: json1) else {
            XCTFail("Failed to parse JSON")
            return
        }
        XCTAssertEqual(item1.id, "17451")
        XCTAssertEqual(item1.text, "This is my first Task!")
        XCTAssertEqual(item1.importance, .important)
        XCTAssertFalse(item1.isDone)
        XCTAssertEqual(item1.creationDate.timeIntervalSince1970, date.timeIntervalSince1970)
        XCTAssertEqual(item1.deadline?.timeIntervalSince1970, date.addingTimeInterval(10000).timeIntervalSince1970)
        XCTAssertEqual(item1.editedDate?.timeIntervalSince1970, date.timeIntervalSince1970)
        
        let json2: [String: Any] = [
            "id": "74115",
            "text": "second Task",
            "isDone": true,
            "creationDate": date.timeIntervalSince1970,
        ]
        guard let item2 = TodoItem.parse(json: json2) else {
            XCTFail("Failed to parse JSON")
            return
        }
        XCTAssertNotNil(item2)
        XCTAssertEqual(item2.id, "74115")
        XCTAssertEqual(item2.text, "second Task")
        XCTAssertEqual(item2.importance, .common)
        XCTAssertTrue(item2.isDone)
        XCTAssertEqual(item2.creationDate.timeIntervalSince1970, date.timeIntervalSince1970)
        XCTAssertNil(item2.deadline)
        XCTAssertNil(item2.editedDate)
        
        let json3: [String: Any] = [
            "text": "second Task",
            "isDone": true,
            "creationDate": date.timeIntervalSince1970,
        ]
        let item3 = TodoItem.parse(json: json3)
        XCTAssertNil(item3)
    }
    
    func testCSVSerialization() {
        let csv1 = item1.csv
        XCTAssertEqual(csv1, "17451,This is my first Task!,false,important,\(date.timeIntervalSince1970),\(date.addingTimeInterval(10000).timeIntervalSince1970),\(date.timeIntervalSince1970)")
        
        let csv2 = item2.csv
        XCTAssertEqual(csv2, "\(item2.id),second Task,true,common,\(date.timeIntervalSince1970), , ")
        
        let csv3 = itemWithComma.csv
        XCTAssertEqual(csv3, "\(itemWithComma.id),\"item, with comma\",true,common,\(date.timeIntervalSince1970), , ")
        
        let csv4 = itemWithQuotes.csv
        XCTAssertEqual(csv4, "\(itemWithQuotes.id),\"item, \"\"with\"\" comma\",true,common,\(date.timeIntervalSince1970), , ")
    }
    
    func testCSVDeserialization() {
        let csv1 = "17451,This is my first Task!,false,important,\(date.timeIntervalSince1970),\(date.addingTimeInterval(10000).timeIntervalSince1970),\(date.timeIntervalSince1970)"
        guard let item1 = TodoItem.parse(csv: csv1) else {
            XCTFail("Failed to parse CSV1")
            return
        }
        XCTAssertEqual(item1.id, "17451")
        XCTAssertEqual(item1.text, "This is my first Task!")
        XCTAssertEqual(item1.importance, .important)
        XCTAssertFalse(item1.isDone)
        XCTAssertEqual(item1.creationDate.timeIntervalSince1970, date.timeIntervalSince1970)
        XCTAssertEqual(item1.deadline?.timeIntervalSince1970, date.addingTimeInterval(10000).timeIntervalSince1970)
        XCTAssertEqual(item1.editedDate?.timeIntervalSince1970, date.timeIntervalSince1970)
        
        let csv2 = "\(item2.id),second Task,true,common,\(date.timeIntervalSince1970), , "
        guard let item2 = TodoItem.parse(csv: csv2) else {
            XCTFail("Failed to parse CSV2")
            return
        }
        XCTAssertEqual(item2.id, item2.id)
        XCTAssertEqual(item2.text, "second Task")
        XCTAssertEqual(item2.importance, .common)
        XCTAssertTrue(item2.isDone)
        XCTAssertEqual(item2.creationDate.timeIntervalSince1970, date.timeIntervalSince1970)
        XCTAssertNil(item2.deadline)
        XCTAssertNil(item2.editedDate)
        
        let csv3 = "\(item2.id),\"item, with comma\",true,common,\(date.timeIntervalSince1970), , "
        guard let itemWithComma = TodoItem.parse(csv: csv3) else {
            XCTFail("Failed to parse CSV3")
            return
        }
        XCTAssertEqual(itemWithComma.id, item2.id)
        XCTAssertEqual(itemWithComma.text, "item, with comma")
        XCTAssertEqual(itemWithComma.importance, .common)
        XCTAssertTrue(itemWithComma.isDone)
        XCTAssertEqual(itemWithComma.creationDate.timeIntervalSince1970, date.timeIntervalSince1970)
        XCTAssertNil(itemWithComma.deadline)
        XCTAssertNil(itemWithComma.editedDate)
        
        let csv4 = "\(item2.id),\"item, \"\"with\"\" comma\",true,common,\(date.timeIntervalSince1970), , "
        guard let itemWithQuotes = TodoItem.parse(csv: csv4) else {
            XCTFail("Failed to parse CSV4")
            return
        }
        XCTAssertEqual(itemWithQuotes.id, item2.id)
        XCTAssertEqual(itemWithQuotes.text, "item, \"with\" comma")
        XCTAssertEqual(itemWithQuotes.importance, .common)
        XCTAssertTrue(itemWithQuotes.isDone)
        XCTAssertEqual(itemWithQuotes.creationDate.timeIntervalSince1970, date.timeIntervalSince1970)
        XCTAssertNil(itemWithQuotes.deadline)
        XCTAssertNil(itemWithQuotes.editedDate)
    }

}
