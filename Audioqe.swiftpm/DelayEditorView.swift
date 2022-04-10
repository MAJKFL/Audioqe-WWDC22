//
//  DelayEditorView.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import SwiftUI
import AVFoundation

struct DelayEditorView: View {
    @ObservedObject var editor: QueueEditor
    @ObservedObject var bank: Bank
    
    @State private var debounceTimer: Timer?
    
    var body: some View {
        guard let delay = bank.effect as? AVAudioUnitDelay else { fatalError() }
        
        let feedback = Binding(
            get: { delay.feedback },
            set: {
                delay.feedback = $0
                save()
            }
        )
        
        let delayTime = Binding(
            get: { delay.delayTime },
            set: {
                delay.delayTime = $0
                save()
            }
        )
        
        let lowPassCutoff = Binding(
            get: { delay.lowPassCutoff },
            set: {
                delay.lowPassCutoff = $0
                save()
            }
        )
        
        let wetDryMix = Binding(
            get: { delay.wetDryMix },
            set: {
                delay.wetDryMix = $0
                save()
            }
        )
        
        return VStack {
            VStack(alignment: .leading) {
                Text("Feedback:")
                    .font(.headline)
                
                Slider(value: feedback, in: -100...100, minimumValueLabel: Text("-100%"), maximumValueLabel: Text("100%")) {
                    EmptyView()
                }
                
                Text("Delay time:")
                    .font(.headline)
                
                Slider(value: delayTime, in: 0...2, minimumValueLabel: Text("0"), maximumValueLabel: Text("2")) {
                    EmptyView()
                }
                
                Text("Low pass cutoff:")
                    .font(.headline)
                
                Slider(value: lowPassCutoff, in: 10...Float((bank.editor.file?.fileFormat.sampleRate ?? 20) / 2), minimumValueLabel: Text("10 Hz"), maximumValueLabel: Text(String(format: "%.0f Hz", Float((bank.editor.file?.fileFormat.sampleRate ?? 20) / 2)))) {
                    EmptyView()
                }
                
                Text("Wet dry mix:")
                    .font(.headline)
                
                Slider(value: wetDryMix, in: 0...100, minimumValueLabel: Text("0%"), maximumValueLabel: Text("100%")) {
                    EmptyView()
                }
            }
            
            Button(role: .destructive, action: { editor.clearBank(bank) }, label: { Label("Remove", systemImage: "trash") })
                .padding()
        }
        .frame(width: 300)
        .padding()
    }
    
    func save() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            editor.save()
        }
    }
}
