import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var queueList = QueueList()
    
    @State private var searchText = ""
    
    @State private var selectedQueue: String?
    
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
                    NavigationLink(destination: MainEditorView(editor: queue), tag: queue.id, selection: $selectedQueue, label: { SidebarRow(queueList: queueList, editor: queue) })
                }
                .onDelete { offsets in
                    guard let index = offsets.first else { return }
                    queueList.remove(queues[index])
                }
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedQueue = queues.first?.id
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
