//
//  ToDomanager.swift
//  ToDo
//
//  Created by Sergey Marsalov on 31.08.2024.
//

import Foundation

final class ToDoManager {
    
    private let keyToDosIsLoaded = "ToDosIsLoaded"
    private let keyNextId = "NextId"
    
    init() {
        if !UserDefaults.standard.bool(forKey: keyToDosIsLoaded) {
            loadToDos()
            UserDefaults.standard.setValue(true, forKey: keyToDosIsLoaded)
        }
    }
    
    
    func createToDo(toDo: String, toDoDescription: String) {
        let id = getId()
        let userId = Int64(42)
        let date = Date()
        
        CoreDataManager.shared.createToDoItem(
            id: id,
            userId: userId,
            toDo: toDo,
            toDoDescription: toDoDescription,
            isCompleted: false,
            date: date
        ) {error in
            self.printError(error)
        }
    }
    
    func deleteToDo(id: Int32) {
        CoreDataManager.shared.deleteToDoItem(id: id) {error in
            self.printError(error)
        }
    }
    
    func updateToDo(id: Int32) {
        CoreDataManager.shared.updateToDoItem(id: id) {error in
            self.printError(error)
        }
    }
    
    func editToDo(id: Int32, toDo: String, toDoDescription: String) {
        CoreDataManager.shared.editToDoItem(id: id, newToDo: toDo, newToDoDescription: toDoDescription) {error in
            self.printError(error)
        }
    }
    
    
    //MARK: Private
    
    private func loadToDos() {
        DispatchQueue.global().async {
            NetworkManager.shared.getToDoList() {toDos in
                guard let toDos = toDos else {return}
                self.saveToDos(toDos.todos)
                self.saveNextId(id: toDos.total + 1)
            }
        }
    }
    
    private func saveToDos(_ toDos: [ToDoModel]) {
        CoreDataManager.shared.saveLoadToDos(toDos) {error in
            self.printError(error)
        }
    }
    
    private func printError(_ error: Error?) {
        guard let error = error else {return}
        print(error.localizedDescription)
    }
    
    private func saveNextId(id: Int) {
        UserDefaults.standard.setValue(id, forKey: keyNextId)
    }
    
    private func getId() -> Int32 {
        let id = UserDefaults.standard.value(forKey: keyNextId) as? Int ?? 1
        saveNextId(id: id + 1)
        return Int32(id)
    }
    
}
