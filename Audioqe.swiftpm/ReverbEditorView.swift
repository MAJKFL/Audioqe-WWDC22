import SwiftUI
import AVFoundation

struct ReverbEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var editor: QueueEditor
    @ObservedObject var bank: Bank
    
    @Binding var editingMessage: String?
    @Binding var helpWindowSetting: HelpWindowSetting?
    
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
                
                HStack {
                    Spacer().overlay(Text("0%"))
                    
                    Slider(value: wetDryMix, in: 0...100) { isEditing in
                        withAnimation {
                            editingMessage = isEditing ? "" : nil
                        }
                    }
                    .frame(width: 200)
                    
                    Spacer().overlay(Text("100%"))
                }
                
                Toggle(isOn: bypass) { Text("Bypass:").font(.headline) }
            }
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    helpWindowSetting = .reverb
                }, label: { Label("Help", systemImage: "questionmark.circle") })
                
                Spacer()
                
                Button(role: .destructive, action: { editor.clearBank(bank) }, label: { Label("Remove", systemImage: "trash") })
            }
            .padding()
        }
        .frame(width: 375)
        .padding()
    }
    
    func save() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            editor.save()
        }
    }
}
