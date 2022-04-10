import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var queueList = QueueList()
    
    @State private var searchText = ""
    
    var queues: [QueueEditor] {
        if searchText == "" {
            return queueList.queues
        } else {
            return queueList.queues.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(queues) { queue in
                    NavigationLink(destination: MainEditorView(editor: queue), label: { Label(queue.name, systemImage: "arrow.right.square") })
                }
                .onDelete(perform: queueList.remove)
                .searchable(text: $searchText)
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
