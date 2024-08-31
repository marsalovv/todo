//
//  NetworkService.swift
//  ToDo
//
//  Created by Sergey Marsalov on 31.08.2024.
//

import Foundation


import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private let urlString = "https://dummyjson.com/todos"
    
    private init() {}
    
    func getToDoList(completion: @escaping (ToDos?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let todos = try decoder.decode(ToDos.self, from: data)
                    completion(todos)
                } catch {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
}
