//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 06/04/2022.
//

import SwiftUI
import AVFoundation

struct EqualiserEditorView: View {
    @ObservedObject var bank: BankViewModel
    
    var body: some View {
        guard let equaliser = bank.effect as? AVAudioUnitEQ else { fatalError() }
        
        let preset = Binding(
            get: { Int(bank.equaliserFilterType.rawValue) },
            set: { bank.equaliserFilterType = AVAudioUnitEQFilterType(rawValue: $0) ?? .parametric }
        )
        
        let bandwidth = Binding(
            get: { equaliser.bands.first?.bandwidth ?? 0 },
            set: { equaliser.bands.first?.bandwidth = $0 }
        )
        
        let bypass = Binding(
            get: { equaliser.bands.first?.bypass ?? false },
            set: { equaliser.bands.first?.bypass = $0 }
        )
        
        let frequency = Binding(
            get: { equaliser.bands.first?.frequency ?? 0 },
            set: { equaliser.bands.first?.frequency = $0 }
        )
        
        let gain = Binding(
            get: { equaliser.bands.first?.gain ?? 0 },
            set: { equaliser.bands.first?.gain = $0 }
        )
        
        return VStack(alignment: .leading) {
            Picker("Filter type", selection: preset) {
                ForEach(0..<11, id: \.self) { key in
                    Text(TrackEditor.eqFilterNames[key] ?? "UNKNOWN")
                }
            }
            
            Text("Bandwidth")
            Slider(value: bandwidth, in: 0.05...5.0)
            
            Text("Bypass")
            Toggle(isOn: bypass) { Text("") }
            
            Text("Frequency")
            Slider(value: frequency, in: 20...Float(bank.sampleRate / 2))
            
            Text("Gain")
            Slider(value: gain, in: -96...24)
        }
    }
}
