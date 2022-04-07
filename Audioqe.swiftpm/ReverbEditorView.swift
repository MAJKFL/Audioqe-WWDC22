//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 06/04/2022.
//

import SwiftUI
import AVFoundation

struct ReverbEditorView: View {
    @ObservedObject var editor: TrackEditor
    @ObservedObject var bank: BankViewModel
    
    var body: some View {
        guard let reverb = bank.effect as? AVAudioUnitReverb else { fatalError() }
        
        let preset = Binding(
            get: { Int(bank.reverbPreset.rawValue) },
            set: { bank.reverbPreset = AVAudioUnitReverbPreset(rawValue: $0) ?? .smallRoom }
        )
        
        let wetDryMix = Binding(
            get: { reverb.wetDryMix },
            set: { reverb.wetDryMix = $0 }
        )
        
        return VStack {
            VStack(alignment: .leading) {
                Text("Preset:")
                    .font(.headline)
                
                Picker("preset", selection: preset) {
                    ForEach(0..<13, id: \.self) { key in
                        Text(TrackEditor.reverbPresetNames[key] ?? "UNKNOWN")
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
