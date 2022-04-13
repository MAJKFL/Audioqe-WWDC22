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
                    NavigationLink(destination: MainEditorView(editor: queues[index]), tag: index, selection: $selectedQueue, label: { SidebarRow(queueList: queueList, editor: queues[index]) })
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

struct SidebarRow: View {
    @ObservedObject var queueList: QueueList
    @ObservedObject var editor: QueueEditor
    
    var body: some View {
        Label(editor.name, systemImage: "arrow.right.square")
            .contextMenu {
                Button {
                    textFieldAlert(title: editor.name, message: "Enter new name", hintText: "New name", primaryTitle: "Done", secondaryTitle: "Cancel", primaryAction: rename, secondaryAction: {})
                } label: {
                    Label("Rename", systemImage: "pencil")
                }

            }
    }
    
    func rename(_ newName: String) {
        guard !newName.isEmpty else { return }
        guard !queueList.queues.map({ $0.name }).contains(newName) else { return }
        editor.name = newName
        editor.save()
    }
}
