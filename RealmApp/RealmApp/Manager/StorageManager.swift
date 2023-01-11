//
//  StorageManager.swift
//  RealmApp
//
//  Created by dzmitry on 11.01.23.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
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
}
