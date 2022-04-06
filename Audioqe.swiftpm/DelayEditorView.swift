//
//  DelayEditorView.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import SwiftUI

struct DelayEditorView: View {
    @ObservedObject var track: TrackEditor
    
    init(track: TrackEditor) {
        self.track = track
    }
    
    var body: some View {
        let feedback = Binding(
            get: { track.delay.feedback },
            set: { track.delay.feedback = $0 }
        )
        
        let delayTime = Binding(
            get: { track.delay.delayTime },
            set: { track.delay.delayTime = $0 }
        )
        
        let lowPassCutoff = Binding(
            get: { track.delay.lowPassCutoff },
            set: { track.delay.lowPassCutoff = $0 }
        )
        
        let wetDryMix = Binding(
            get: { track.delay.wetDryMix },
            set: { track.delay.wetDryMix = $0 }
        )
        
        return VStack(alignment: .leading) {
            Text("Feedback")
            Slider(value: feedback, in: -100...100)
            Text("Delay time")
            Slider(value: delayTime, in: 0...2)
            Text("Low pass cutoff")
            Slider(value: lowPassCutoff, in: 10...Float(track.file.fileFormat.sampleRate / 2))
            Text("Wet dry mix")
            Slider(value: wetDryMix, in: 0...100)
        }
    }
}
