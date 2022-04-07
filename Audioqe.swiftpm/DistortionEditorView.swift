//
//  DistortionEditorView.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import SwiftUI
import AVFoundation

struct DistortionEditorView: View {
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
        
        return VStack(alignment: .leading) {
            Picker("preset", selection: preset) {
                ForEach(0..<22, id: \.self) { key in
                    Text(TrackEditor.distortionPresetNames[key] ?? "UNKNOWN")
                }
            }
            
            Text("Pre gain")
            Slider(value: preGain, in: -80...20)
            
            Text("Wet dry mix")
            Slider(value: wetDryMix, in: 0...100)
        }
    }
}
