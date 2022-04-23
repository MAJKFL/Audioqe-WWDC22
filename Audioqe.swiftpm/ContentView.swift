import SwiftUI
import AVFoundation

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var size
    
    @ObservedObject var editorList = QueueEditorList()
    @StateObject var keyboardState = KeyboardState()
    
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
                        NavigationLink(destination: MainEditorView(editor: queue, selectedQueueID: $selectedQueueID).environmentObject(keyboardState), tag: queue.id, selection: $selectedQueueID, label: { SidebarRow(editorList: editorList, editor: queue) })
                    }
                    .onDelete { offsets in
                        guard let index = offsets.first else { return }
                        if selectedQueueID == queues[index].id { selectedQueueID = queues.first?.id }
                        editorList.remove(queues[index])
                    }
                }
                .searchable(text: $searchText)
                .listStyle(.sidebar)
                .environmentObject(keyboardState)
                .navigationTitle("Queues")
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
    @EnvironmentObject var keyboardState: KeyboardState
    
    @ObservedObject var editorList: QueueEditorList
    @ObservedObject var editor: QueueEditor
    
    var body: some View {
        Label(editor.name, systemImage: "arrow.right.square")
            .contextMenu {
                Button {
                    withAnimation(.easeIn.speed(2)) { keyboardState.shown = true }
                    
                    textFieldAlert(title: editor.name, message: "Enter new name", hintText: "New name", primaryTitle: "Done", secondaryTitle: "Cancel", primaryAction: rename, secondaryAction: { withAnimation(.easeIn.speed(2)) { keyboardState.shown = false } })
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
            }
    }
    
    func rename(_ newName: String) {
        withAnimation(.easeIn.speed(2)) { keyboardState.shown = false }
        guard !newName.isEmpty else { return }
        guard !editorList.queues.map({ $0.name }).contains(newName) else { return }
        editor.name = newName
        editor.save()
    }
}

class KeyboardState: ObservableObject {
    @Published var shown = false
}
