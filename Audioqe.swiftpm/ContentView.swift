import SwiftUI
import AVFAudio

struct ContentView: View {
    let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    @ObservedObject var editor = TrackEditor(fileURL: Bundle.main.url(forResource: "CleanGuitar", withExtension: "aif")!)
    
    @State private var selectedBank: EffectBankViewModel?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 100) {
                LazyVGrid(columns: columns, spacing: 50) {
                    HStack(spacing: 0) {
                        StartTileView()
                        
                        Rectangle()
                            .frame(maxWidth: .infinity, maxHeight: 1)
                    }
                    
                    ForEach(editor.effectBanks) { bank in
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(maxWidth: .infinity, maxHeight: 1)
                            
                            TileView(selectedBank: $selectedBank, bank: bank)
                                .onDrag {
                                    editor.draggedBank = bank
                                    return NSItemProvider(contentsOf: URL(string: bank.id)!)!
                                }
                                .onDrop(of: [.url], delegate: DropViewDelegate(editor: editor, bank: bank))
                            
                            Rectangle()
                                .frame(maxWidth: .infinity, maxHeight: 1)
                        }
                    }
                    
                    HStack(spacing: 0) {
                        Rectangle()
                            .frame(maxWidth: .infinity, maxHeight: 1)
                        
                        ExitTileView()
                    }
                }
                
                switch selectedBank?.effect {
                case is AVAudioUnitDelay:
                    DelayEditorView(bank: selectedBank!)
                case is AVAudioUnitDistortion:
                    DistortionEditorView(bank: selectedBank!)
                case is AVAudioUnitReverb:
                    ReverbEditorView(bank: selectedBank!)
                case is AVAudioUnitEQ:
                    EqualiserEditorView(bank: selectedBank!)
                default:
                    Text("None")
                }
            }
            .padding(.horizontal)
            .navigationTitle("Audioqe")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button {
                            try? editor.play()
                        } label: {
                            Image(systemName: "play.fill")
                        }

                        Button {
                            editor.pause()
                        } label: {
                            Image(systemName: "pause.fill")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Menu {
                            Button {
//                                isShowingImporter.toggle()
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
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct StartTileView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.green)
            .frame(width: 200, height: 150)
    }
}

struct TileView: View {
    @Binding var selectedBank: EffectBankViewModel?
    @ObservedObject var bank: EffectBankViewModel
    
    var bgColor: Color? {
        switch bank.effect {
        case is AVAudioUnitReverb: return .mint
        case is AVAudioUnitDistortion: return .orange
        case is AVAudioUnitDelay: return .indigo
        case is AVAudioUnitEQ: return .yellow
        default: return nil
        }
    }
    
    var body: some View {
        if let bgColor = bgColor {
            RoundedRectangle(cornerRadius: 15)
                .fill(bgColor)
                .frame(width: 200, height: 150)
                .overlay(Text("\(bank.id)"))
                .onTapGesture {
                    withAnimation(.easeInOut.speed(2)) {
                        selectedBank = bank
                    }
                }
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 200, height: 150)
                
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
            }
        }
    }
}

struct ExitTileView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.red)
            .frame(width: 200, height: 150)
    }
}

struct DropViewDelegate: DropDelegate {
    @ObservedObject var editor: TrackEditor
    
    var bank: EffectBankViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedBank = editor.draggedBank else { return }
        
        let fromIndex = editor.effectBanks.firstIndex(where: { $0.id == bank.id })!
        
        let toIndex = editor.effectBanks.firstIndex(where: { $0.id == draggedBank.id })!
        
        if fromIndex != toIndex {
            let fromBank = editor.effectBanks[fromIndex]
            editor.effectBanks[fromIndex] = editor.effectBanks[toIndex]
            editor.effectBanks[toIndex] = fromBank
        }
        
        editor.connectNodes()
    }
}
