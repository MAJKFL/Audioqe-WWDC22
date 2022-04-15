import SwiftUI
import AVFoundation

struct EqualiserEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var editor: QueueEditor
    @ObservedObject var bank: Bank
    
    @Binding var editingMessage: String?
    @Binding var helpWindowSetting: HelpWindowSetting?
    
    @State private var debounceTimer: Timer?
    
    var body: some View {
        guard let equaliser = bank.effect as? AVAudioUnitEQ else { fatalError() }
        
        let preset = Binding(
            get: { Int(bank.equaliserFilterType.rawValue) },
            set: {
                bank.equaliserFilterType = AVAudioUnitEQFilterType(rawValue: $0) ?? .parametric
                save()
            }
        )
        
        let bandwidth = Binding(
            get: { equaliser.bands.first?.bandwidth ?? 0 },
            set: {
                equaliser.bands.first?.bandwidth = $0
                editingMessage = String(format: "%.2f", $0)
                save()
            }
        )
        
        let bypass = Binding(
            get: { equaliser.bypass },
            set: {
                equaliser.bypass = $0
                save()
            }
        )
        
        let frequency = Binding(
            get: { equaliser.bands.first?.frequency ?? 0 },
            set: {
                equaliser.bands.first?.frequency = $0
                editingMessage = String(format: "%.0f Hz", $0)
                save()
            }
        )
        
        let gain = Binding(
            get: { equaliser.bands.first?.gain ?? 0 },
            set: {
                equaliser.bands.first?.gain = $0
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
                
                if ![1, 2, 7, 8].contains(where: { $0 == bank.equaliserFilterType.rawValue }) {
                    Text("Bandwidth:")
                        .font(.headline)
                    
                    Slider(value: bandwidth, in: 0.05...5) {
                        Text("Bandwidth")
                    } minimumValueLabel: {
                        Text("0.05")
                    } maximumValueLabel: {
                        Text("5.00")
                    } onEditingChanged: { isEditing in
                        withAnimation {
                            editingMessage = isEditing ? "" : nil
                        }
                    }
                }
                
                Text("Frequency:")
                    .font(.headline)
                
                Slider(value: frequency, in: 20...Float((bank.editor.file?.fileFormat.sampleRate ?? 44100) / 2), step: 5) {
                    Text("Frequency")
                } minimumValueLabel: {
                    Text("20 Hz")
                } maximumValueLabel: {
                    Text(editor.file == nil ? "No file" : String(format: "%.0f Hz", Float((bank.editor.file?.fileFormat.sampleRate ?? 40) / 2)))
                        .foregroundColor(editor.file == nil ? .red : .primary)
                } onEditingChanged: { isEditing in
                    withAnimation {
                        editingMessage = isEditing ? "" : nil
                    }
                }
                .disabled(editor.file == nil)
                
                if ![1, 2, 3, 4, 5, 6].contains(where: { $0 == bank.equaliserFilterType.rawValue }) {
                    Text("Gain:")
                        .font(.headline)
                    
                    Slider(value: gain, in: -96...24) {
                        Text("Gain")
                    } minimumValueLabel: {
                        Text("-96 dB")
                    } maximumValueLabel: {
                        Text("24 dB")
                    } onEditingChanged: { isEditing in
                        withAnimation {
                            editingMessage = isEditing ? "" : nil
                        }
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
        .padding()
    }
    
    func save() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            editor.save()
        }
    }
}
