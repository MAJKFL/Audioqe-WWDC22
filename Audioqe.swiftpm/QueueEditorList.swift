import Foundation

class QueueEditorList: ObservableObject {
    @Published var queues: [QueueEditor]
    static let saveKey = "SavedData"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode([SaveQueue].self, from: data) {
                queues = decoded.map { savedQueue in
                    QueueEditor(savedQueue)
                }
                return
            }
        }

        if let data = Self.sampleQueuesJSON.data(using: .utf8, allowLossyConversion: false) {
            if let decoded = try? JSONDecoder().decode([SaveQueue].self, from: data) {
                queues = decoded.map { savedQueue in
                    QueueEditor(savedQueue)
                }
                save()
                
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
    
    // TODO: Remove before release
    func printQueues() {
        if let encoded = try? JSONEncoder().encode(queues.map({ $0.exportQueue() })) {
            print(String(data: encoded, encoding: .utf8) ?? "")
        }
    }
}

extension QueueEditorList {
    static let sampleQueuesJSON = """
    [
      {
        "id" : "2D7C0612-5D96-489B-8DD6-CAFBB3AA0F4F",
        "volume" : 1,
        "name" : "Example queue 1",
        "banks" : [
          {
            "gain" : "20.0",
            "filter" : "0",
            "bypass" : "Off",
            "type" : "equalizer",
            "frequency" : "16000.0",
            "bandwidth" : "1.0"
          },
          {
            "bypass" : "Off",
            "type" : "reverb",
            "preset" : "2",
            "wetDryMix" : "25.0"
          },
          {
            "delayTime" : "0.2",
            "lowPassCutoff" : "1600.0",
            "bypass" : "Off",
            "type" : "delay",
            "feedback" : "-65.0",
            "wetDryMix" : "15.0"
          },
          {
            "type" : "empty"
          },
          {
            "type" : "empty"
          },
          {
            "type" : "empty"
          }
        ]
      },
      {
        "id" : "E9E862FA-C72E-4DB8-B164-C43FF4B6E77F",
        "volume" : 1,
        "name" : "Example queue 2",
        "banks" : [
          {
            "preGain" : "-0.5",
            "bypass" : "Off",
            "type" : "distortion",
            "wetDryMix" : "30.0",
            "preset" : "10"
          },
          {
            "bypass" : "Off",
            "type" : "reverb",
            "preset" : "2",
            "wetDryMix" : "55.0"
          },
          {
            "gain" : "0.0",
            "filter" : "1",
            "bypass" : "Off",
            "frequency" : "4200.0",
            "type" : "equalizer",
            "bandwidth" : "0.0"
          },
          {
            "type" : "empty"
          },
          {
            "type" : "empty"
          },
          {
            "type" : "empty"
          }
        ]
      },
      {
        "id" : "6BCDC5B0-633C-4E69-A2C9-7E9A441D9F76",
        "volume" : 1,
        "name" : "Example queue 3",
        "banks" : [
          {
            "preGain" : "-2.8",
            "bypass" : "On",
            "type" : "distortion",
            "wetDryMix" : "40.0",
            "preset" : "14"
          },
          {
            "bandwidth" : "0.0",
            "filter" : "8",
            "bypass" : "Off",
            "type" : "equalizer",
            "frequency" : "7200.0",
            "gain" : "15.0"
          },
          {
            "bandwidth" : "1.8",
            "filter" : "3",
            "bypass" : "Off",
            "type" : "equalizer",
            "frequency" : "14000.0",
            "gain" : "0.0"
          },
          {
            "bypass" : "Off",
            "type" : "reverb",
            "preset" : "4",
            "wetDryMix" : "60.0"
          },
          {
            "type" : "empty"
          },
          {
            "type" : "empty"
          }
        ]
      },
      {
        "id" : "607B899B-159E-4E54-8287-3E8E6E96F6DB",
        "volume" : 1,
        "name" : "Example queue 4",
        "banks" : [
          {
            "preGain" : "-6.0",
            "bypass" : "On",
            "type" : "distortion",
            "wetDryMix" : "60.0",
            "preset" : "4"
          },
          {
            "bypass" : "Off",
            "type" : "reverb",
            "wetDryMix" : "50.0",
            "preset" : "0"
          },
          {
            "frequency" : "18000.0",
            "filter" : "3",
            "bypass" : "Off",
            "type" : "equalizer",
            "bandwidth" : "1.4",
            "gain" : "0.0"
          },
          {
            "type" : "equalizer",
            "filter" : "8",
            "bypass" : "Off",
            "frequency" : "6000.0",
            "bandwidth" : "0.0",
            "gain" : "10.0"
          },
          {
            "delayTime" : "0.13294798135757446",
            "lowPassCutoff" : "1500.0",
            "bypass" : "Off",
            "type" : "delay",
            "feedback" : "18.0",
            "wetDryMix" : "50.0"
          },
          {
            "type" : "empty"
          }
        ]
      }
    ]
    """
}
