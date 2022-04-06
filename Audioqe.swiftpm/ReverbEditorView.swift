//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 06/04/2022.
//

import Foundation

import SwiftUI
import AVFoundation

struct ReverbEditorView: View {
    @ObservedObject var bank: EffectBankViewModel
    
    let presetNames = [
        0:  "small room",
        1:  "medium room",
        2:  "large room",
        3:  "medium hall",
        4:  "large hall",
        5:  "plate",
        6:  "medium chamber",
        7:  "large chamber",
        8:  "cathedral",
        9:  "large room 2",
        10: "medium hall 2",
        11: "medium hall 3",
        12: "large hall 2"
    ]
    
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
        
        return VStack(alignment: .leading) {
            Picker("preset", selection: preset) {
                ForEach(0..<13, id: \.self) { key in
                    Text(presetNames[key] ?? "UNKNOWN")
                }
            }
            Text("Wet dry mix")
            Slider(value: wetDryMix, in: 0...100)
        }
    }
}
