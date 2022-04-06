//
//  DistortionEditorView.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import SwiftUI
import AVFoundation

struct DistortionEditorView: View {
    @ObservedObject var track: TrackEditor
    
    let presetNames = [
        0:  "drums bit brush",
        1:  "drums buffer beats",
        2:  "drums lo fi",
        3:  "multi broken speaker",
        4:  "multi cell phone speaker",
        5:  "multi decimated 1",
        6:  "multi decimated 2",
        7:  "multi decimated 3",
        8:  "multi decimated 4",
        9:  "multi distorted funk",
        10: "multi distorted cube",
        11: "multi distorted squared",
        12: "multi echo 1",
        13: "multi echo 2",
        14: "multi echo tight 1",
        15: "multi echo tight 2",
        16: "multi everything is broken",
        17: "speech alien chatter",
        18: "speech cosmic interference",
        19: "speech golden pi",
        20: "speech radio tower",
        21: "speech waves"
    ]
    
    var body: some View {
        let preset = Binding(
            get: { Int(track.distortionPreset.rawValue) },
            set: { track.distortionPreset = AVAudioUnitDistortionPreset(rawValue: $0) ?? .multiBrokenSpeaker }
        )
        
        let preGain = Binding(
            get: { track.distortion.preGain },
            set: { track.distortion.preGain = $0 }
        )
        
        let wetDryMix = Binding(
            get: { track.distortion.wetDryMix },
            set: { track.distortion.wetDryMix = $0 }
        )
        
        return VStack(alignment: .leading) {
            Picker("preset", selection: preset) {
                ForEach(0..<22, id: \.self) { key in
                    Text(presetNames[key] ?? "UNKNOWN")
                }
            }
            Text("Pre gain")
            Slider(value: preGain, in: -80...20)
            Text("Wet dry mix")
            Slider(value: wetDryMix, in: 0...100)
        }
    }
}
