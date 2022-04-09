//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 07/04/2022.
//

import SwiftUI
import AVFoundation

struct TileView: View {
    @Binding var selectedBank: Bank?
    
    @ObservedObject var bank: Bank
    @ObservedObject var editor: TrackEditor
    
    @State private var isShowingPopover = false
    @State private var oldShowingPopoverValue = false
    
    var bgColor: Color? {
        switch bank.effect {
        case is AVAudioUnitReverb: return .mint
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
        case is AVAudioUnitEQ: return "Equaliser"
        default: return "UNKNOWN"
        }
    }
    
    var detailedView: some View {
        HStack {
            VStack(alignment: .leading) {
                if let reverb = bank.effect as? AVAudioUnitReverb {
                    Text("**Preset** - \(TrackEditor.reverbPresetNames[bank.reverbPreset.rawValue] ?? "")")
                    
                    Text("**Wet dry mix** - \(String(format: "%.0f", reverb.wetDryMix))%")
                } else if let distortion = bank.effect as? AVAudioUnitDistortion {
                    Text("**Preset** - \(TrackEditor.distortionPresetNames[bank.distortionPreset.rawValue] ?? "")")
                    
                    Text("**Pre gain** - \(String(format: "%.2f", distortion.preGain)) dB")
                    
                    Text("**Wet dry mix** - \(String(format: "%.0f", distortion.wetDryMix))%")
                } else if let delay = bank.effect as? AVAudioUnitDelay {
                    Text("**Feedback** - \(String(format: "%.0f", delay.feedback))%")
                    
                    Text("**Delay time** - \(String(format: "%.2f", delay.delayTime))")
                    
                    Text("**LP cutoff** - \(String(format: "%.0f", delay.lowPassCutoff)) Hz")
                    
                    Text("**Wet dry mix** - \(String(format: "%.0f", delay.wetDryMix))%")
                } else if let equaliser = bank.effect as? AVAudioUnitEQ {
                    Text("**Filter** - \(TrackEditor.eqFilterNames[bank.equaliserFilterType.rawValue] ?? "")")
                    
                    Text("**Bandwidth** - \(String(format: "%.2f", equaliser.bands.first?.bandwidth ?? 0))")
                    
                    Text("**Bypass** - \(equaliser.bands.first?.bypass ?? false ? "On" : "Off")")
                    
                    Text("**Frequency** - \(String(format: "%.0f", equaliser.bands.first?.frequency ?? 0)) Hz")
                    
                    Text("**Gain** - \(String(format: "%.1f", equaliser.bands.first?.gain ?? 0)) dB")
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
                .frame(width: 220, height: 160)
                .scaleEffect(isSelected ? 0.93 : 1)
                .overlay(VStack {
                    HStack {
                        Label(name, systemImage: imageName)
                            .font(.title)
                        
                        if !isSelected {
                            Spacer()
                        }
                    }
                    
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
                .popover(isPresented: $isShowingPopover, content: {
                    switch selectedBank?.effect {
                    case is AVAudioUnitDelay:
                        DelayEditorView(editor: editor, bank: selectedBank!)
                    case is AVAudioUnitDistortion:
                        DistortionEditorView(editor: editor, bank: selectedBank!)
                    case is AVAudioUnitReverb:
                        ReverbEditorView(editor: editor, bank: selectedBank!)
                    case is AVAudioUnitEQ:
                        EqualiserEditorView(editor: editor, bank: selectedBank!)
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
                .disabled(editor.file == nil)
        } else {
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
                        bank.effect = distortion
                    }
                    editor.connectNodes()
                } label: {
                    Label("Distortion", systemImage: "waveform.path")
                }
                
                Button {
                    withAnimation(.easeInOut.speed(2)) {
                        bank.effect = AVAudioUnitDelay()
                    }
                    editor.connectNodes()
                } label: {
                    Label("Delay", systemImage: "wave.3.right")
                }
                
                Button {
                    withAnimation(.easeInOut.speed(2)) {
                        bank.effect = AVAudioUnitEQ()
                    }
                    editor.connectNodes()
                } label: {
                    Label("Equaliser", systemImage: "slider.vertical.3")
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.secondary.opacity(isLastEmptyBank ? 0.1 : 0))
                        .frame(width: 220, height: 160)
                    
                    Rectangle()
                        .fill(Color.primary)
                        .frame(maxWidth: .infinity, maxHeight: 1)
                }
            }
            .disabled(!isLastEmptyBank || editor.file == nil)
            .transaction { transaction in
                transaction.animation = nil
            }
        }
    }
}
