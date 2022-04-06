import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            MainEditorView()
                .navigationTitle("Audioqe")
        }
        .navigationViewStyle(.stack)
    }
}
