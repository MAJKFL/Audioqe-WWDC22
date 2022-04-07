//
//  DistortionEditorView.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import SwiftUI
import AVFoundation

struct DistortionEditorView: View {
    @ObservedObject var editor: TrackEditor
    @ObservedObject var bank: BankViewModel
    
    var body: some View {
        guard let distortion = bank.effect as? AVAudioUnitDistortion else { fatalError() }
        
        let preset = Binding(
            get: { Int(bank.distortionPreset.rawValue) },
            set: { bank.distortionPreset = AVAudioUnitDistortionPreset(rawValue: $0) ?? .multiBrokenSpeaker }
        )
        
        let preGain = Binding(
            get: { distortion.preGain },
            set: { distortion.preGain = $0 }
        )
        
        let wetDryMix = Binding(
            get: { distortion.wetDryMix },
            set: { distortion.wetDryMix = $0 }
        )
        
        return VStack {
            VStack(alignment: .leading) {
                Text("Pre gain:")
                    .font(.headline)
                
                Slider(value: preGain, in: -80...20, minimumValueLabel: Text("-80 dB"), maximumValueLabel: Text("20 dB")) {
                    EmptyView()
                }
                
                Text("Preset:")
                    .font(.headline)
                
                Picker("preset", selection: preset) {
                    ForEach(0..<22, id: \.self) { key in
                        Text(TrackEditor.distortionPresetNames[key] ?? "UNKNOWN")
                    }
                }
                .pickerStyle(.wheel)
                
                Text("Wet dry mix:")
                    .font(.headline)
                
                Slider(value: wetDryMix, in: 0...100, minimumValueLabel: Text("0%"), maximumValueLabel: Text("100%")) {
                    EmptyView()
                }
            }
            Button(role: .destructive, action: { editor.removeBank(bank) }, label: { Label("Remove", systemImage: "trash") })
                .padding()
        }
        .padding()
    }
}
