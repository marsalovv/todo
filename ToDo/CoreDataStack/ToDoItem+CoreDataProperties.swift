//
//  ToDoItem+CoreDataProperties.swift
//  ToDo
//
//  Created by Sergey Marsalov on 31.08.2024.
//
//

import Foundation
import CoreData


extension ToDoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoItem> {
        return NSFetchRequest<ToDoItem>(entityName: "ToDoItem")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: Int32
    @NSManaged public var isCompleted: Bool
    @NSManaged public var toDo: String?
    @NSManaged public var toDoDescription: String?
    @NSManaged public var userId: Int64

}

extension ToDoItem : Identifiable {

}
