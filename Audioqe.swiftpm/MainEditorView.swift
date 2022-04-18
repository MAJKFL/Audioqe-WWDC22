import SwiftUI
import AVFoundation

struct MainEditorView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var editor: QueueEditor
    
    @Binding var selectedQueueID: String?
    
    @State private var selectedBank: Bank?
    @State private var isShowingImporter = false
    @State private var isShowingRecorder = false
    
    let portraitColumns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    let landscapeColumns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 100) {
                Spacer()
                
                LazyVGrid(columns: geo.size.width > geo.size.height ? landscapeColumns : portraitColumns, spacing: 50) {
                    HStack(spacing: 0) {
                        StartTileView(editor: editor, isShowingRecorder: $isShowingRecorder, isShowingImporter: $isShowingImporter, viewSize: geo.size)
                        
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
                                .overlay {
                                    Image(systemName: "play.fill").opacity((geo.size.width < geo.size.height ? [1, 3, 5] : [3]).contains(where: { $0 == editor.effectBanks.firstIndex(where: { $0.id == bank.id }) }) ? 1 : 0)
                                }
                            
                            if bank.effect != nil {
                                TileView(selectedBank: $selectedBank, bank: bank, editor: editor, viewSize: geo.size)
                                    .onDrag {
                                        editor.draggedBank = bank
                                        return NSItemProvider(contentsOf: URL(string: bank.id)!)!
                                    }
                                    .onDrop(of: [.url], delegate: TileDropDelegate(editor: editor, bank: bank))
                            } else {
                                TileView(selectedBank: $selectedBank, bank: bank, editor: editor, viewSize: geo.size)
                            }
                            
                            Rectangle()
                                .fill(Color.primary)
                                .frame(maxWidth: .infinity, maxHeight: 1)
                                .transaction { transaction in
                                    transaction.animation = nil
                                }
                                .overlay {
                                    Image(systemName: "play.fill").opacity((geo.size.width < geo.size.height ? [0, 2, 4] : [2]).contains(where: { $0 == editor.effectBanks.firstIndex(where: { $0.id == bank.id }) }) ? 1 : 0)
                                }
                        }
                    }
                    
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.primary)
                            .frame(maxWidth: .infinity, maxHeight: 1)
                        
                        ExitTileView(editor: editor, viewSize: geo.size)
                    }
                }
                .animation(.default.speed(1.5), value: editor.activeBanksCount)
                
                Spacer()
            }
            .navigationTitle(editor.name)
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
                                if AVAudioSession.sharedInstance().recordPermission == .undetermined {
                                    let session = AVAudioSession.sharedInstance()
                                    try? session.setCategory(.playAndRecord)
                                    session.requestRecordPermission { _ in }
                                } else {
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
                            .disabled(editor.file == nil)
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
                    
                    if FileManager.default.fileExists(atPath: destination.path) {
                        try FileManager.default.removeItem(at: destination)
                    }
                    
                    try FileManager.default.copyItem(at: fileURL, to: destination)
                    
                    editor.loadFile(url: destination)
                    
                    fileURL.stopAccessingSecurityScopedResource()
                } catch {
                    print(error.localizedDescription)
                }
            })
            .onChange(of: scenePhase) { newPhase in
                if newPhase != .active {
                    editor.pause()
                }
            }
            .onChange(of: selectedQueueID) { _ in
                editor.pause()
            }
        }
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
