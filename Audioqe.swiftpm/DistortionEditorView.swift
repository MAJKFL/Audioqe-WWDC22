import SwiftUI
import AVFoundation

struct DistortionEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var editor: QueueEditor
    @ObservedObject var bank: Bank
    
    @Binding var editingMessage: String?
    @Binding var helpWindowSetting: HelpWindowSetting?
    
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
                editingMessage = String(format: "%.2f dB", $0)
                save()
            }
        )
        
        let wetDryMix = Binding(
            get: { distortion.wetDryMix },
            set: {
                distortion.wetDryMix = $0
                editingMessage = "\(String(format: "%.0f", $0))%"
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
                
                Slider(value: preGain, in: -80...20) {
                    Text("Pre gain")
                } minimumValueLabel: {
                    Text("-80 dB")
                } maximumValueLabel: {
                    Text("20 dB")
                } onEditingChanged: { isEditing in
                    withAnimation {
                        editingMessage = isEditing ? "" : nil
                    }
                }

                
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
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    helpWindowSetting = .distortion
                }, label: { Label("Help", systemImage: "questionmark.circle") })
                
                Spacer()
                
                Button(role: .destructive, action: { editor.clearBank(bank) }, label: { Label("Remove", systemImage: "trash") })
            }
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
