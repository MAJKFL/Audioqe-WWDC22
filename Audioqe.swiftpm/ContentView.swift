import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var queueList = QueueList()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(queueList.queues) { queue in
                    NavigationLink(destination: MainEditorView(editor: queue), label: { Label(queue.name, systemImage: "arrow.right.square") })
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Queues")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        queueList.add(QueueEditor())
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
