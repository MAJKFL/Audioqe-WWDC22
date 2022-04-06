//
//  DelayEditorView.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import SwiftUI
import AVFAudio

struct DelayEditorView: View {
    @ObservedObject var bank: EffectBankViewModel
    
    var body: some View {
        guard let delay = bank.effect as? AVAudioUnitDelay else { fatalError() }
        
        let feedback = Binding(
            get: { delay.feedback },
            set: { delay.feedback = $0 }
        )
        
        let delayTime = Binding(
            get: { delay.delayTime },
            set: { delay.delayTime = $0 }
        )
        
        let lowPassCutoff = Binding(
            get: { delay.lowPassCutoff },
            set: { delay.lowPassCutoff = $0 }
        )
        
        let wetDryMix = Binding(
            get: { delay.wetDryMix },
            set: { delay.wetDryMix = $0 }
        )
        
        return VStack(alignment: .leading) {
            Text("Feedback")
            Slider(value: feedback, in: -100...100)
            Text("Delay time")
            Slider(value: delayTime, in: 0...2)
            Text("Low pass cutoff")
            Slider(value: lowPassCutoff, in: 10...Float(delay.lastRenderTime?.sampleRate ?? 0 / 2))
            Text("Wet dry mix")
            Slider(value: wetDryMix, in: 0...100)
        }
    }
}
