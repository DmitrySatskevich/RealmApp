//
//  StorageManager.swift
//  RealmApp
//
//  Created by dzmitry on 11.01.23.
//

import Foundation
import RealmSwift

let realm = try! Realm()

final class StorageManager {
    
    static func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("deleteAll error: \(error)")
        }
    }
    
    static func getAllTasksLists() -> Results<TasksList> {
        realm.objects(TasksList.self)//.sorted(byKeyPath: "name")
    }
    
    static func saveTasksList(tasksList: TasksList) {
        do {
            try realm.write {
                realm.add(tasksList)
            }
        } catch {
            print("saveTasksList error: \(error)")
        }
    }

    static func deleteList(_ tasksList: TasksList) {
        do {
            try realm.write {
                let tasks = tasksList.tasks
                // последовательно удаляем tasks и tasksList
                realm.delete(tasks)
                realm.delete(tasksList)
            }
        } catch {
            print("deleteList error: \(error)")
        }
    }

    // Редактирование текущего списка
    static func editList(_ tasksList: TasksList,
                         newListName: String,
                         complition: @escaping () -> Void) {
        do {
            try realm.write {
                tasksList.name = newListName
                complition()
            }
        } catch {
            print("editList error: \(error)")
        }
    }
}
