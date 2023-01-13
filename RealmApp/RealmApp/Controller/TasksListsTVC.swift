//
//  TasksListsTVC.swift
//  RealmApp
//
//  Created by dzmitry on 11.01.23.
//

import UIKit
import RealmSwift

class TasksListsTVC: UITableViewController {
    
    var tasksLists: Results<TasksList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // выгрузка из БД + сортировка
        tasksLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")

        let add = UIBarButtonItem(barButtonSystemItem: .add,
                                  target: self,
                                  action: #selector(addBarButtonSystemItemSelector))
        self.navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
    }
    
    
    @IBAction func segmentedControlChanget(_ sender: UISegmentedControl) {
        let byKeyPath = sender.selectedSegmentIndex == 0 ? "name" : "date"
        tasksLists = tasksLists.sorted(byKeyPath: byKeyPath)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let taskList = tasksLists[indexPath.row]
        cell.textLabel?.text = taskList.name
        cell.detailTextLabel?.text = taskList.tasks.count.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Свайп ячейки
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Вытащить текущий лист
        let currentList = tasksLists[indexPath.row]

        // Создание кнопок в ячейке
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        let editeContextItem = UIContextualAction(style: .destructive, title: "Edite") { _, _, _ in
            self.alertForAddAndUpdatesListTasks(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
//            StorageManager.makeAllDone(currentList)
//            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        editeContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green

        let swipeAtions = UISwipeActionsConfiguration(actions: [deleteContextItem, editeContextItem, doneContextItem])

        return swipeAtions
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TasksTVC,
           let index = tableView.indexPathForSelectedRow {
            let tasksList = tasksLists[index.row]
            destinationVC.currentTasksList = tasksList
        }
    }
    
    @objc func addBarButtonSystemItemSelector() {
        alertForAddAndUpdatesListTasks { [weak self] in
            print("List added or edited")
            self?.tableView.reloadData()
        }
    }
    
    // Делаем alertForAddAndUpdatesListTasks универсальной функцией
    private func alertForAddAndUpdatesListTasks(_ tasksList: TasksList? = nil,
                                                complition: @escaping () -> Void)
    {
        // Заголовок Alerta
        let title = tasksList == nil ? "New List" : "Edit List"
        let message = "Please insert list name"
        // Название кнопок
        let doneButtonName = tasksList == nil ? "Save" : "Update"

        // Создание Alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        var alertTextField: UITextField!
        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { _ in
            
            guard let newListName = alertTextField.text, !newListName.isEmpty else {
                return
            }

            // логика редактирования
            if let tasksList = tasksList {
                StorageManager.editList(tasksList, newListName: newListName, complition: complition)
            // логика создания нового списка
            } else {
                let tasksList = TasksList()
                tasksList.name = newListName
                StorageManager.saveTasksList(tasksList: tasksList)
                complition()
                // Анимированное появление ячейки
//                self.tableView.insertRows(at: [IndexPath(row: self.tasksLists.count - 1, section: 0)], with: .automatic)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        // Настройка Alert
        alert.addTextField { textField in
            alertTextField = textField
            if let listName = tasksList {
                alertTextField.text = listName.name
            }
            alertTextField.placeholder = "List Name"
        }
        present(alert, animated: true)
    }
}
