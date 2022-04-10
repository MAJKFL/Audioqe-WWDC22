//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 10/04/2022.
//

import Foundation

class QueueList: ObservableObject {
    @Published var queues: [QueueEditor]
    static let saveKey = "SavedData"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode([SaveQueue].self, from: data) {
                queues = decoded.map({ savedQueue in
                    QueueEditor(savedQueue)
                })
                return
            }
        }

        queues = []
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(queues.map({ $0.exportQueue() })) {
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }

    func add(_ queue: QueueEditor) {
        queues.append(QueueEditor(queue.exportQueue()))
        save()
    }
    
    func remove(at offsets: IndexSet) {
        queues.remove(atOffsets: offsets)
        save()
    }
}
