import SwiftUI
import AVFoundation

struct MainEditorView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var editor: QueueEditor
    
    @Binding var selectedQueueID: String?
    
    @State private var selectedBank: Bank?
    @State private var shareButtonRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
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
                        StartTileView(editor: editor, viewSize: geo.size)
                        
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
                    Button {
                        Task {
                            await shareFile(url: editor.render(), buttonRect: shareButtonRect)
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(editor.file == nil)
                    .background(rectReader($shareButtonRect))
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase != .active {
                    editor.pause()
                }
            }
            .onChange(of: selectedQueueID) { id in
                editor.pause()
            }
            .onDisappear {
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
    
    func rectReader(_ binding: Binding<CGRect>) -> some View {
        return GeometryReader { (geometry) -> AnyView in
            let rect = geometry.frame(in: .global)
            DispatchQueue.main.async {
                binding.wrappedValue = rect
            }
            return AnyView(Rectangle().fill(Color.clear))
        }
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
