import SwiftUI
import AVFoundation

struct ContentView: View {
    @ObservedObject var editor = TrackEditor()
    
    @State private var selectedBank: Bank?
    @State private var isShowingImporter = false
    @State private var orientation = UIDevice.current.orientation
    
    var columns: [GridItem] {
//        if orientation == .unknown ? UIDevice.current.orientation.isLandscape : orientation.isLandscape {
//            return [
//                GridItem(.flexible(), spacing: 0),
//                GridItem(.flexible(), spacing: 0),
//                GridItem(.flexible(), spacing: 0),
//                GridItem(.flexible(), spacing: 0)
//            ]
//        } else {
//            return [
//                GridItem(.flexible(), spacing: 0),
//                GridItem(.flexible(), spacing: 0)
//            ]
//        }
        
        return [
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0)
        ]
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
                                
                            } label: {
                                Label("Add recording", systemImage: "mic.fill.badge.plus")
                            }
                        } label: {
                            Image(systemName: "waveform.badge.plus")
                        }
                        
                        GeometryReader { geo in
                            Button {
                                shareRenderedFile(url: editor.render(), buttonRect: geo.frame(in: CoordinateSpace.global))
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        .padding(.trailing)
                    }
                }
            }
            .fileImporter(isPresented: $isShowingImporter, allowedContentTypes: [.audio], onCompletion: { result in
                do {
                    let fileURL = try result.get()
                    
                    let _ = fileURL.startAccessingSecurityScopedResource()
                    
                    editor.loadFile(url: fileURL)
                    
                    fileURL.stopAccessingSecurityScopedResource()
                } catch {
                    print(error.localizedDescription)
                }
            })
            .onRotate { newOrientation in
                orientation = newOrientation
            }
        }
        .navigationViewStyle(.stack)
    }
    
    func shareRenderedFile(url: URL?, buttonRect: CGRect) {
        guard let url = url else { return }

        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow
        ac.popoverPresentationController?.sourceRect = buttonRect
        UIApplication.shared.keyWindow?.rootViewController!.present(ac, animated: true)
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
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
