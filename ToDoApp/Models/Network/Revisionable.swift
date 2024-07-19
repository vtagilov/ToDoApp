//
//  Revisionable.swift
//  ToDoApp
//
//  Created by Владимир on 19.07.2024.
//

import Foundation

protocol Revisionable: Decodable {
    var revision: Int { get }
}
