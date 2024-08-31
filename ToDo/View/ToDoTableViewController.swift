//
//  ToDoTableViewController.swift
//  ToDo
//
//  Created by Sergey Marsalov on 31.08.2024.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ToDoItem> =  {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch items: \(error.localizedDescription)")
        }
        return fetchedResultsController
    }()
    
    private let toDoManager: ToDoManager

    init(toDoManager: ToDoManager) {
        self.toDoManager = toDoManager
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(ToDoTableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        title = "Список дел"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addToDo))
    }
    
    @objc private func addToDo() {
        showToDoAlert(toDo: nil)
    }
    
    @objc private func showToDoAlert(toDo: ToDoItem?) {
        let isEditing = toDo != nil
        
        let alert = UIAlertController(
            title: isEditing ? "Редактировать задачу" : "Новая задача",
            message: isEditing ? "Измените данные задачи" : "Введите данные для новой задачи",
            preferredStyle: .alert
        )
        
        alert.addTextField { (textField) in
            textField.placeholder = "Задача"
            textField.text = toDo?.toDo
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Описание"
            textField.text = toDo?.toDoDescription
        }
        
        let saveActionTitle = isEditing ? "Обновить" : "Сохранить"
        let saveAction = UIAlertAction(title: saveActionTitle, style: .default) { [weak self] _ in
            guard let toDoTitle = alert.textFields?[0].text, !toDoTitle.isEmpty,
                  let toDoDescription = alert.textFields?[1].text, !toDoDescription.isEmpty else {
                return
            }
            
            if let toDo = toDo {
                self?.toDoManager.editToDo(id: toDo.id, toDo: toDoTitle, toDoDescription: toDoDescription)
            } else {
                self?.toDoManager.createToDo(toDo: toDoTitle, toDoDescription: toDoDescription)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ToDoTableViewCell
        
        if let toDos = fetchedResultsController.fetchedObjects {
            let toDo = toDos[indexPath.row]
            cell.configure(toDo: toDo)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let todos = fetchedResultsController.fetchedObjects {
            let todo = todos[indexPath.row]
            toDoManager.updateToDo(id: todo.id)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Редактировать") { [weak self] (action, view, completionHandler) in
            if let todos = self?.fetchedResultsController.fetchedObjects {
                let todo = todos[indexPath.row]
                self?.showToDoAlert(toDo: todo)
            }
            completionHandler(true)
        }
        editAction.backgroundColor = .blue
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (action, view, completionHandler) in
            if let todosCD = self?.fetchedResultsController.fetchedObjects {
                let todo = todosCD[indexPath.row]
                self?.toDoManager.deleteToDo(id: todo.id)
            }
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}

extension ToDoTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        @unknown default:
            fatalError("Unhandled case in NSFetchedResultsControllerDelegate")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
