import SwiftUI
import AVFoundation

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var size
    
    @ObservedObject var editorList = QueueEditorList()
    
    @State private var searchText = ""
    @State private var selectedQueueID: String?
    
    var queues: [QueueEditor] {
        if searchText == "" {
            return editorList.queues
        } else {
            return editorList.queues.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
        }
    }
    
    var body: some View {
        if size == .regular {
            NavigationView {
                List {
                    ForEach(queues) { queue in
                        NavigationLink(destination: MainEditorView(editor: queue, selectedQueueID: $selectedQueueID), tag: queue.id, selection: $selectedQueueID, label: { SidebarRow(editorList: editorList, editor: queue) })
                    }
                    .onDelete { offsets in
                        guard let index = offsets.first else { return }
                        if selectedQueueID == queues[index].id { selectedQueueID = queues.first?.id }
                        editorList.remove(queues[index])
                    }
                }
                .searchable(text: $searchText)
                .listStyle(.sidebar)
                .navigationTitle("Saved")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            editorList.add(QueueEditor())
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        } else {
            Text("Please open in full screen 😀")
        }
    }
}

struct SidebarRow: View {
    @ObservedObject var editorList: QueueEditorList
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
        guard !editorList.queues.map({ $0.name }).contains(newName) else { return }
        editor.name = newName
        editor.save()
    }
}
