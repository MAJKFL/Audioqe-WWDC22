import SwiftUI
import AVFoundation

struct DistortionEditorView: View {
    @ObservedObject var editor: QueueEditor
    @ObservedObject var bank: Bank
    
    @State private var debounceTimer: Timer?
    
    var body: some View {
        guard let distortion = bank.effect as? AVAudioUnitDistortion else { fatalError() }
        
        let preset = Binding(
            get: { Int(bank.distortionPreset.rawValue) },
            set: {
                bank.distortionPreset = AVAudioUnitDistortionPreset(rawValue: $0) ?? .multiBrokenSpeaker
                save()
            }
        )
        
        let preGain = Binding(
            get: { distortion.preGain },
            set: {
                distortion.preGain = $0
                save()
            }
        )
        
        let wetDryMix = Binding(
            get: { distortion.wetDryMix },
            set: {
                distortion.wetDryMix = $0
                save()
            }
        )
        
        let bypass = Binding(
            get: { distortion.bypass },
            set: {
                distortion.bypass = $0
                save()
            }
        )
        
        return VStack {
            VStack(alignment: .leading) {
                Text("Preset:")
                    .font(.headline)
                
                Picker("preset", selection: preset) {
                    ForEach(0..<22, id: \.self) { key in
                        Text(QueueEditor.distortionPresetNames[key] ?? "UNKNOWN")
                    }
                }
                .pickerStyle(.wheel)
                
                Text("Pre gain:")
                    .font(.headline)
                
                Slider(value: preGain, in: -80...20, minimumValueLabel: Text("-80 dB"), maximumValueLabel: Text("20 dB")) {
                    EmptyView()
                }
                
                Text("Wet dry mix:")
                    .font(.headline)
                
                Slider(value: wetDryMix, in: 0...100, minimumValueLabel: Text("0%"), maximumValueLabel: Text("100%")) {
                    EmptyView()
                }
                
                Toggle(isOn: bypass) { Text("Bypass:").font(.headline) }
            }
            Button(role: .destructive, action: { editor.clearBank(bank) }, label: { Label("Remove", systemImage: "trash") })
                .padding()
        }
        .padding()
    }
    
    func save() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            editor.save()
        }
    }
}
