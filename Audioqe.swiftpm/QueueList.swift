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
        let maxNumber = queues
            .filter({ $0.name.contains("Queue") })
            .map({ $0.name.replacingOccurrences(of: "Queue ", with: "") })
            .map({ Int($0) ?? 0 })
            .max() ?? 0
        
        let newQueue = QueueEditor(queue.exportQueue())
        newQueue.name = "Queue \(maxNumber + 1)"
        
        queues.append(newQueue)
        save()
    }
    
    func remove(_ queue: QueueEditor) {
        queues.removeAll(where: { $0.id == queue.id })
        save()
    }
}
