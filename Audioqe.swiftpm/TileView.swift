import SwiftUI
import AVFoundation

struct TileView: View {
    @EnvironmentObject var keyboardState: KeyboardState
    
    @Binding var selectedBank: Bank?
    
    @ObservedObject var bank: Bank
    @ObservedObject var editor: QueueEditor
    
    @State private var isShowingPopover = false
    @State private var oldShowingPopoverValue = false
    
    @State private var editingMessage: String?
    @State private var helpWindowSetting: HelpWindowSetting?
    
    let viewSize: CGSize
    
    var sizeMultiplier: Double {
        viewSize.width <= 873.5 && viewSize.width > viewSize.height ? 0.9 : 1.1
    }
    
    var bgColor: Color? {
        switch bank.effect {
        case is AVAudioUnitReverb: return .cyan
        case is AVAudioUnitDistortion: return .orange
        case is AVAudioUnitDelay: return .indigo
        case is AVAudioUnitEQ: return .yellow
        default: return nil
        }
    }
    
    var imageName: String {
        switch bank.effect {
        case is AVAudioUnitReverb: return "dot.radiowaves.left.and.right"
        case is AVAudioUnitDistortion: return "waveform.path"
        case is AVAudioUnitDelay: return "wave.3.right"
        case is AVAudioUnitEQ: return "slider.vertical.3"
        default: return "questionmark.circle.fill"
        }
    }
    
    var name: String {
        switch bank.effect {
        case is AVAudioUnitReverb: return "Reverb"
        case is AVAudioUnitDistortion: return "Distortion"
        case is AVAudioUnitDelay: return "Delay"
        case is AVAudioUnitEQ: return "Equalizer"
        default: return "UNKNOWN"
        }
    }
    
    var shouldBypass: Bool {
        if let equalizer = bank.effect as? AVAudioUnitEQ {
            return equalizer.bands.first?.bypass ?? false
        } else {
            return bank.effect?.auAudioUnit.shouldBypassEffect ?? false
        }
    }
    
    var detailedView: some View {
        HStack {
            VStack(alignment: .leading) {
                if let reverb = bank.effect as? AVAudioUnitReverb {
                    Text("Preset - **\(QueueEditor.reverbPresetNames[bank.reverbPreset.rawValue] ?? "")**")
                    
                    Text("Wet dry mix - **\(String(format: "%.0f", reverb.wetDryMix))%**")
                } else if let distortion = bank.effect as? AVAudioUnitDistortion {
                    Text("Preset - **\(QueueEditor.distortionPresetNames[bank.distortionPreset.rawValue] ?? "")**")
                    
                    Text("Pre gain - **\(String(format: "%.2f", distortion.preGain)) dB**")
                    
                    Text("Wet dry mix - **\(String(format: "%.0f", distortion.wetDryMix))%**")
                } else if let delay = bank.effect as? AVAudioUnitDelay {
                    Text("Feedback - **\(String(format: "%.0f", delay.feedback))%**")
                    
                    Text("Delay time - **\(String(format: "%.2f", delay.delayTime))**")
                    
                    Text("LP cutoff - **\(String(format: "%.0f", delay.lowPassCutoff)) Hz**")
                    
                    Text("Wet dry mix - **\(String(format: "%.0f", delay.wetDryMix))%**")
                } else if let equalizer = bank.effect as? AVAudioUnitEQ {
                    Text("Filter - **\(QueueEditor.eqFilterNames[bank.equalizerFilterType.rawValue] ?? "")**")
                    
                    if ![1, 2, 7, 8].contains(where: { $0 == equalizer.bands.first?.filterType.rawValue }) {
                        Text("Bandwidth - **\(String(format: "%.2f", equalizer.bands.first?.bandwidth ?? 0))**")
                    }
                    
                    Text("Frequency - **\(String(format: "%.0f", equalizer.bands.first?.frequency ?? 0)) Hz**")
                    
                    if ![1, 2, 3, 4, 5, 6].contains(where: { $0 == equalizer.bands.first?.filterType.rawValue }) {
                        Text("Gain - **\(String(format: "%.1f", equalizer.bands.first?.gain ?? 0)) dB**")
                    }
                }
            }
            .lineLimit(1)
            
            Spacer()
        }
    }
    
    var isSelected: Bool {
        bank.id == selectedBank?.id
    }
    
    var isLastEmptyBank: Bool {
        editor.effectBanks.firstIndex(where: { $0.id == bank.id }) == editor.activeBanksCount
    }
    
    var body: some View {
        if let bgColor = bgColor {
            RoundedRectangle(cornerRadius: 15)
                .fill(bgColor)
                .frame(width: 220 * sizeMultiplier, height: 160 * 1.1)
                .scaleEffect(isSelected ? (editingMessage != nil ? 0.9 : 0.93) : 1)
                .overlay(VStack {
                    HStack {
                        if let editingMessage = editingMessage {
                            Text(editingMessage)
                                .transaction({ $0.animation = nil })
                        } else {
                            Label(name, systemImage: imageName)
                                .lineLimit(1)
                        }
                        
                        if !isSelected {
                            Spacer()
                            
//                            if !(bank.effect is AVAudioUnitReverb) { // Reverb bypass bug
                            Button {
                                bank.toggleBypass()
                            } label: {
                                Image(systemName: shouldBypass ? "power.circle" : "power.circle.fill")
                                    .foregroundColor(shouldBypass ? .red : .green)
                            }
//                            }
                        }
                    }
                    .font(.title)
                    
                    if !isSelected {
                        detailedView
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        
                        Spacer()
                    }
                }
                    .padding()
                )
                .foregroundColor(.white)
                .onTapGesture {
                    if isSelected || selectedBank != nil {
                        selectedBank = nil
                    } else {
                        selectedBank = bank
                    }
                }
                .animation(.spring().speed(2), value: isSelected)
                .animation(.spring().speed(2.7), value: editingMessage)
                .popover(isPresented: $isShowingPopover, content: {
                    switch selectedBank?.effect {
                    case is AVAudioUnitDelay:
                        DelayEditorView(editor: editor, bank: selectedBank!, editingMessage: $editingMessage, helpWindowSetting: $helpWindowSetting)
                    case is AVAudioUnitDistortion:
                        DistortionEditorView(editor: editor, bank: selectedBank!, editingMessage: $editingMessage, helpWindowSetting: $helpWindowSetting)
                    case is AVAudioUnitReverb:
                        ReverbEditorView(editor: editor, bank: selectedBank!, editingMessage: $editingMessage, helpWindowSetting: $helpWindowSetting)
                    case is AVAudioUnitEQ:
                        EqualizerEditorView(editor: editor, bank: selectedBank!, editingMessage: $editingMessage, helpWindowSetting: $helpWindowSetting)
                    default:
                        Text("None")
                    }
                })
                .onChange(of: selectedBank?.id) { newValue in
                    if newValue == bank.id {
                        isShowingPopover = true
                        oldShowingPopoverValue = true
                    } else {
                        isShowingPopover = false
                        oldShowingPopoverValue = false
                    }
                }
                .onChange(of: isShowingPopover) { newValue in
                    if oldShowingPopoverValue && !newValue {
                        withAnimation(.easeInOut.speed(1.5)) {
                            selectedBank = nil
                        }
                    }
                }
                .sheet(item: $helpWindowSetting) { setting in
                    NavigationView {
                        VStack {
                            setting.detailedView
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .navigationTitle(setting.title)
                    }
                }
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.secondary.opacity(isLastEmptyBank ? 0.2 : 0))
                
                Rectangle()
                    .fill(Color.primary.opacity(isLastEmptyBank ? 0 : 1))
                    .frame(maxWidth: .infinity, maxHeight: 1)
            }
            .frame(width: 220 * sizeMultiplier, height: 160 * 1.1)
            .overlay(
                Menu {
                    Button {
                        withAnimation(.easeInOut.speed(2)) {
                            let reverb = AVAudioUnitReverb()
                            reverb.wetDryMix = 50
                            bank.effect = reverb
                        }
                        editor.connectNodes()
                    } label: {
                        Label("Reverb", systemImage: "dot.radiowaves.left.and.right")
                    }

                    Button {
                        withAnimation(.easeInOut.speed(2)) {
                            let distortion = AVAudioUnitDistortion()
                            distortion.wetDryMix = 50
                            distortion.preGain = -22
                            bank.effect = distortion
                        }
                        editor.connectNodes()
                    } label: {
                        Label("Distortion", systemImage: "waveform.path")
                    }
                    
                    Button {
                        withAnimation(.easeInOut.speed(2)) {
                            let newDelay = AVAudioUnitDelay()
                            newDelay.feedback = 50
                            newDelay.delayTime = 0.25
                            newDelay.lowPassCutoff = 1500
                            bank.effect = newDelay
                        }
                        editor.connectNodes()
                    } label: {
                        Label("Delay", systemImage: "wave.3.right")
                    }
                    
                    Button {
                        withAnimation(.easeInOut.speed(2)) {
                            let newEqualizer = AVAudioUnitEQ(numberOfBands: 1)
                            newEqualizer.bands.first?.bandwidth = 1
                            newEqualizer.bands.first?.frequency = 7500
                            newEqualizer.bands.first?.gain = -30
                            newEqualizer.bands.first?.bypass = false
                            bank.effect = newEqualizer
                        }
                        editor.connectNodes()
                    } label: {
                        Label("Equalizer", systemImage: "slider.vertical.3")
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                        .foregroundColor(.white.opacity(isLastEmptyBank ? 1 : 0))
                        .font(Font.system(size: 50, weight: .bold))
                        .padding()
                        .opacity(keyboardState.shown ? 0 : 1)
                }
                .disabled(!isLastEmptyBank)
                .transaction { transaction in
                    transaction.animation = nil
                }
            )
        }
    }
}
