//
//  ToDosModel.swift
//  ToDo
//
//  Created by Sergey Marsalov on 31.08.2024.
//

import Foundation

struct ToDoModel: Codable {
    let id: Int32
    let todo: String
    let completed: Bool
    let userId: Int64
}

struct ToDos: Codable {
    let todos: [ToDoModel]
    let total: Int
    let skip: Int
    let limit: Int
}
