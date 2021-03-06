import SwiftUI
import AVFoundation

struct EqualizerEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var editor: QueueEditor
    @ObservedObject var bank: Bank
    
    @Binding var editingMessage: String?
    @Binding var helpWindowSetting: HelpWindowSetting?
    
    @State private var debounceTimer: Timer?
    
    var body: some View {
        guard let equalizer = bank.effect as? AVAudioUnitEQ else { fatalError() }
        
        let preset = Binding(
            get: { Int(bank.equalizerFilterType.rawValue) },
            set: {
                bank.equalizerFilterType = AVAudioUnitEQFilterType(rawValue: $0) ?? .parametric
                save()
            }
        )
        
        let bandwidth = Binding(
            get: { equalizer.bands.first?.bandwidth ?? 0 },
            set: {
                equalizer.bands.first?.bandwidth = $0
                editingMessage = String(format: "%.2f", $0)
                save()
            }
        )
        
        let bypass = Binding(
            get: { equalizer.bands.first?.bypass ?? false },
            set: {
                equalizer.bands.first?.bypass = $0
                save()
            }
        )
        
        let frequency = Binding(
            get: { equalizer.bands.first?.frequency ?? 0 },
            set: {
                equalizer.bands.first?.frequency = $0
                editingMessage = String(format: "%.0f Hz", $0)
                save()
            }
        )
        
        let gain = Binding(
            get: { equalizer.bands.first?.gain ?? 0 },
            set: {
                equalizer.bands.first?.gain = $0
                editingMessage = String(format: "%.2f dB", $0)
                save()
            }
        )
        
        return VStack {
            VStack(alignment: .leading) {
                Text("Filter type:")
                    .font(.headline)
                
                Picker("Filter type", selection: preset) {
                    ForEach(0..<11, id: \.self) { key in
                        Text(QueueEditor.eqFilterNames[key] ?? "UNKNOWN")
                    }
                }
                .pickerStyle(.wheel)
                
                if ![1, 2, 7, 8].contains(where: { $0 == bank.equalizerFilterType.rawValue }) {
                    Text("Bandwidth:")
                        .font(.headline)
                    
                    HStack {
                        Spacer().overlay(Text("0.05"))
                        
                        Slider(value: bandwidth, in: 0.05...5) { isEditing in
                            withAnimation {
                                editingMessage = isEditing ? "" : nil
                            }
                        }
                        .frame(width: 200)
                        
                        Spacer().overlay(Text("5.00"))
                    }
                }
                
                Text("Frequency:")
                    .font(.headline)
                
                HStack {
                    Spacer().overlay(Text("20 Hz"))
                    
                    Slider(value: frequency, in: 20...Float((bank.editor.file?.fileFormat.sampleRate ?? 44100) / 2), step: 5) { isEditing in
                        withAnimation {
                            editingMessage = isEditing ? "" : nil
                        }
                    }
                    .disabled(editor.file == nil)
                    .frame(width: 200)
                    
                    Spacer().overlay(Text(editor.file == nil ? "No file" : String(format: "%.0f Hz", Float((bank.editor.file?.fileFormat.sampleRate ?? 40) / 2))).foregroundColor(editor.file == nil ? .red : .primary))
                }
                
                if ![1, 2, 3, 4, 5, 6].contains(where: { $0 == bank.equalizerFilterType.rawValue }) {
                    Text("Gain:")
                        .font(.headline)
                    
                    HStack {
                        Spacer().overlay(Text("-96 dB"))
                        
                        Slider(value: gain, in: -96...24) { isEditing in
                            withAnimation {
                                editingMessage = isEditing ? "" : nil
                            }
                        }
                        .frame(width: 200)
                        
                        Spacer().overlay(Text("24 dB"))
                    }
                }
                
                Toggle(isOn: bypass) { Text("Bypass:").font(.headline) }
            }
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    helpWindowSetting = .equalizer
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
