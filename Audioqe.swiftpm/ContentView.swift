import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        NavigationView {
            List(1..<5) { i in
                NavigationLink(destination: MainEditorView(), label: { Label("Queue name", systemImage: "arrow.right.square") })
            }
            .listStyle(.sidebar)
            .navigationTitle("Queues")
        }
    }
}
