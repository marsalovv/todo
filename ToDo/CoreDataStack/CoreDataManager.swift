//
//  CoreDataManager.swift
//  ToDo
//
//  Created by Sergey Marsalov on 31.08.2024.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo")
        container.loadPersistentStores { (persistent, error) in
            if let error = error {
                fatalError("Error: " + error.localizedDescription)
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    private lazy var mainContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    private func newBackgroundContext() -> NSManagedObjectContext {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func createToDoItem(id: Int32, userId: Int64, toDo: String, toDoDescription: String, isCompleted: Bool, date: Date, completion: @escaping (Error?) -> Void) {
        let backgroundContext = self.newBackgroundContext()
        backgroundContext.perform {
            let newToDoItem = ToDoItem(context: backgroundContext)
            newToDoItem.id = id
            newToDoItem.userId = userId
            newToDoItem.toDo = toDo
            newToDoItem.toDoDescription = toDoDescription
            newToDoItem.isCompleted = isCompleted
            newToDoItem.date = date
            
            do {
                try backgroundContext.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func fetchToDoItems(completion: @escaping ([ToDoItem]?, Error?) -> Void) {
        mainContext.perform {
            let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            
            do {
                let items = try self.mainContext.fetch(fetchRequest)
                let mainContextItems = items.map { self.mainContext.object(with: $0.objectID) as! ToDoItem }
                DispatchQueue.main.async {
                    completion(mainContextItems, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    func updateToDoItem(id: Int32, completion: @escaping (Error?) -> Void) {
        let backgroundContext = self.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            
            do {
                let items = try backgroundContext.fetch(fetchRequest)
                if let itemToUpdate = items.first {
                    itemToUpdate.isCompleted = !itemToUpdate.isCompleted
                    try backgroundContext.save()
                    completion(nil)
                } else {
                    completion(NSError(domain: "CoreDataManagerError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"]))
                }
            } catch {
                completion(error)
            }
        }
    }
    
    func editToDoItem(id: Int32, newToDo: String, newToDoDescription: String, completion: @escaping (Error?) -> Void) {
        let backgroundContext = self.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            
            do {
                let items = try backgroundContext.fetch(fetchRequest)
                if let itemToEdit = items.first {
                    itemToEdit.toDo = newToDo
                    itemToEdit.toDoDescription = newToDoDescription
                    try backgroundContext.save()
                    completion(nil)
                } else {
                    completion(NSError(domain: "CoreDataManagerError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"]))
                }
            } catch {
                completion(error)
            }
        }
    }
    
    func deleteToDoItem(id: Int32, completion: @escaping (Error?) -> Void) {
        let backgroundContext = self.newBackgroundContext()
        backgroundContext.perform {
            
            let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            
            do {
                let items = try backgroundContext.fetch(fetchRequest)
                if let itemToDelete = items.first {
                    backgroundContext.delete(itemToDelete)
                    try backgroundContext.save()
                    completion(nil)
                } else {
                    completion(NSError(domain: "CoreDataManagerError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"]))
                }
            } catch {
                completion(error)
            }
        }
    }
    
    func saveLoadToDos(_ todos: [ToDoModel], completion: @escaping (Error?) -> Void) {
        let backgroundContext = self.newBackgroundContext()
        backgroundContext.perform {
            for todo in todos {
                let newToDoItem = ToDoItem(context: backgroundContext)
                newToDoItem.id = todo.id
                newToDoItem.userId = todo.userId
                newToDoItem.toDo = todo.todo
                newToDoItem.toDoDescription = ""
                newToDoItem.isCompleted = todo.completed
                newToDoItem.date = Date()
            }
            
            do {
                try backgroundContext.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
}
