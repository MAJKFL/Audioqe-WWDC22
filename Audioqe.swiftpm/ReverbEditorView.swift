//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 06/04/2022.
//

import SwiftUI
import AVFoundation

struct ReverbEditorView: View {
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
        
        return HStack {
            VStack(alignment: .leading) {
                Text("Wet dry mix")
                Slider(value: wetDryMix, in: 0...100)
            }
            
            Picker("preset", selection: preset) {
                ForEach(0..<13, id: \.self) { key in
                    Text(TrackEditor.reverbPresetNames[key] ?? "UNKNOWN")
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: 300)
        }
    }
}
