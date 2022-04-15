import SwiftUI
import AVFoundation

struct ReverbEditorView: View {
    @ObservedObject var editor: QueueEditor
    @ObservedObject var bank: Bank
    
    @Binding var editingMessage: String?
    
    @State private var debounceTimer: Timer?
    
    var body: some View {
        guard let reverb = bank.effect as? AVAudioUnitReverb else { fatalError() }
        
        let preset = Binding(
            get: { Int(bank.reverbPreset.rawValue) },
            set: {
                bank.reverbPreset = AVAudioUnitReverbPreset(rawValue: $0) ?? .smallRoom
                save()
            }
        )
        
        let wetDryMix = Binding(
            get: { reverb.wetDryMix },
            set: {
                reverb.wetDryMix = $0
                editingMessage = "\(String(format: "%.0f", $0))%"
                save()
            }
        )
        
        let bypass = Binding(
            get: { reverb.bypass },
            set: {
                reverb.bypass = $0
                save()
            }
        )
        
        return VStack {
            VStack(alignment: .leading) {
                Text("Preset:")
                    .font(.headline)
                
                Picker("preset", selection: preset) {
                    ForEach(0..<13, id: \.self) { key in
                        Text(QueueEditor.reverbPresetNames[key] ?? "UNKNOWN")
                    }
                }
                .pickerStyle(.wheel)
                
                Text("Wet dry mix:")
                    .font(.headline)
                
                Slider(value: wetDryMix, in: 0...100) {
                    Text("Wet dry mix")
                } minimumValueLabel: {
                    Text("0%")
                } maximumValueLabel: {
                    Text("100%")
                } onEditingChanged: { isEditing in
                    withAnimation {
                        editingMessage = isEditing ? "" : nil
                    }
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
