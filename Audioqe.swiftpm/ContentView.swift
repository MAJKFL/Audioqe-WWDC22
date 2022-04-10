import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var orientationInfo = OrientationInfo()
    @ObservedObject var editor = TrackEditor()
    
    @State private var selectedBank: Bank?
    @State private var isShowingImporter = false
    @State private var isShowingRecorder = false
    
    var columns: [GridItem] {
        if orientationInfo.orientation == .landscape {
            return [
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0)
            ]
        } else {
            return [
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0)
            ]
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 100) {
                LazyVGrid(columns: columns, spacing: 50) {
                    HStack(spacing: 0) {
                        StartTileView(editor: editor)
                        
                        Rectangle()
                            .fill(Color.primary)
                            .frame(maxWidth: .infinity, maxHeight: 1)
                    }
                    
                    ForEach(editor.effectBanks) { bank in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.primary)
                                .frame(maxWidth: .infinity, maxHeight: 1)
                                .transaction { transaction in
                                    transaction.animation = nil
                                }
                            
                            if bank.effect != nil {
                                TileView(selectedBank: $selectedBank, bank: bank, editor: editor)
                                    .onDrag {
                                        editor.draggedBank = bank
                                        return NSItemProvider(contentsOf: URL(string: bank.id)!)!
                                    }
                                    .onDrop(of: [.url], delegate: TileDropDelegate(editor: editor, bank: bank))
                            } else {
                                TileView(selectedBank: $selectedBank, bank: bank, editor: editor)
                            }
                            
                            Rectangle()
                                .fill(Color.primary)
                                .frame(maxWidth: .infinity, maxHeight: 1)
                                .transaction { transaction in
                                    transaction.animation = nil
                                }
                        }
                    }
                    
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.primary)
                            .frame(maxWidth: .infinity, maxHeight: 1)
                        
                        ExitTileView(editor: editor)
                    }
                }
                .animation(.default.speed(1.5), value: editor.activeBanksCount)
            }
            .navigationTitle("Queue name")
            .toolbar {                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Menu {
                            Button {
                                isShowingImporter.toggle()
                            } label: {
                                Label("Add file", systemImage: "doc.fill.badge.plus")
                            }
                            
                            Button {
                                withAnimation {
                                    isShowingRecorder.toggle()
                                }
                            } label: {
                                Label("Choose recording", systemImage: "mic.fill.badge.plus")
                            }
                        } label: {
                            Image(systemName: "waveform.badge.plus")
                        }
                        .popover(isPresented: $isShowingRecorder, content: { AudioRecorder(editor: editor) })
                        
                        GeometryReader { geo in
                            Button {
                                Task {
                                    await shareFile(url: editor.render(), buttonRect: geo.frame(in: CoordinateSpace.global))
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        .padding(.trailing)
                    }
                }
            }
            .fileImporter(isPresented: $isShowingImporter, allowedContentTypes: [.audio], onCompletion: { result in
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentsURL = URL(string: path)!
                let recordingsURL = documentsURL.appendingPathComponent("recordings")
                
                if !FileManager.default.fileExists(atPath: recordingsURL.path) {
                    do {
                        try FileManager.default.createDirectory(atPath: recordingsURL.path, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                do {
                    let fileURL = try result.get()
                    
                    let _ = fileURL.startAccessingSecurityScopedResource()
                    
                    let destination = URL(string: "file://\(recordingsURL.appendingPathComponent(fileURL.lastPathComponent).absoluteString)")!
                    
                    try FileManager.default.copyItem(at: fileURL, to: destination)
                    
                    editor.loadFile(url: destination)
                    
                    fileURL.stopAccessingSecurityScopedResource()
                } catch {
                    print(error.localizedDescription)
                }
            })
        }
        .navigationViewStyle(.stack)
    }
    
    func shareFile(url: URL?, buttonRect: CGRect) {
        guard let url = url else { return }

        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow
        ac.popoverPresentationController?.sourceRect = buttonRect
        UIApplication.shared.keyWindow?.rootViewController!.present(ac, animated: true)
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
}
