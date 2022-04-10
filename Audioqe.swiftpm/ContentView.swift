import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var queueList = QueueList()
    
    @State private var searchText = ""
    
    @State private var selectedQueue: Int? = 0
    
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
                ForEach(queues.indices, id: \.self) { index in
                    NavigationLink(destination: MainEditorView(editor: queues[index]), tag: index, selection: $selectedQueue, label: { Label(queues[index].name, systemImage: "arrow.right.square") })
                }
                .onDelete(perform: queueList.remove)
            }
            .searchable(text: $searchText)
            .listStyle(.sidebar)
            .navigationTitle("Saved")
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
