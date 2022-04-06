//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 06/04/2022.
//

import SwiftUI
import AVFoundation

struct EqualiserEditorView: View {
    @ObservedObject var track: TrackEditor
    
    let filterNames = [
        0:  "parametric",
        1:  "low pass",
        2:  "high pass",
        3:  "resonant low pass",
        4:  "resonant high pass",
        5:  "band pass",
        6:  "band stop",
        7:  "low shelf",
        8:  "high shelf",
        9:  "resonant low shelf",
        10: "resonant high shelf"
    ]
    
    var body: some View {
        let preset = Binding(
            get: { Int(track.equaliserFilterType.rawValue) },
            set: { track.equaliserFilterType = AVAudioUnitEQFilterType(rawValue: $0) ?? .parametric }
        )
        
        let bandwidth = Binding(
            get: { track.equaliser.bands.first?.bandwidth ?? 0 },
            set: { track.equaliser.bands.first?.bandwidth = $0 }
        )
        
        let bypass = Binding(
            get: { track.equaliser.bands.first?.bypass ?? false },
            set: { track.equaliser.bands.first?.bypass = $0 }
        )
        
        let frequency = Binding(
            get: { track.equaliser.bands.first?.frequency ?? 0 },
            set: { track.equaliser.bands.first?.frequency = $0 }
        )
        
        let gain = Binding(
            get: { track.equaliser.bands.first?.gain ?? 0 },
            set: { track.equaliser.bands.first?.gain = $0 }
        )
        
        return VStack(alignment: .leading) {
            Picker("Filter type", selection: preset) {
                ForEach(0..<11, id: \.self) { key in
                    Text(filterNames[key] ?? "UNKNOWN")
                }
            }
            Text("Bandwidth")
            Slider(value: bandwidth, in: 0.05...5.0)
            Text("Bypass")
            Toggle(isOn: bypass) { Text("") }
            Text("Frequency")
            Slider(value: frequency, in: 20...Float(track.file.fileFormat.sampleRate / 2))
            Text("Gain")
            Slider(value: gain, in: -96...24)
        }
    }
}
