import SwiftUI
import AVFoundation

struct EqualiserEditorView: View {
    @ObservedObject var editor: QueueEditor
    @ObservedObject var bank: Bank
    
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
                save()
            }
        )
        
        let bypass = Binding(
            get: { equaliser.bands.first?.bypass ?? false },
            set: {
                equaliser.bands.first?.bypass = $0
                save()
            }
        )
        
        let frequency = Binding(
            get: { equaliser.bands.first?.frequency ?? 0 },
            set: {
                equaliser.bands.first?.frequency = $0
                save()
            }
        )
        
        let gain = Binding(
            get: { equaliser.bands.first?.gain ?? 0 },
            set: {
                equaliser.bands.first?.gain = $0
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
                
                Text("Bandwidth:")
                    .font(.headline)
                
                Slider(value: bandwidth, in: 0.05...5.0, minimumValueLabel: Text("0.05"), maximumValueLabel: Text("5.00")) {
                    EmptyView()
                }
                
                Text("Frequency:")
                    .font(.headline)
                
                Slider(value: frequency, in: 20...Float((bank.editor.file?.fileFormat.sampleRate ?? 40) / 2), minimumValueLabel: Text("20 Hz"), maximumValueLabel: Text(String(format: "%.0f Hz", Float((bank.editor.file?.fileFormat.sampleRate ?? 40) / 2)))) {
                    EmptyView()
                }
                
                Text("Gain:")
                    .font(.headline)
                
                Slider(value: gain, in: -96...24, minimumValueLabel: Text("-96 dB"), maximumValueLabel: Text("24 dB")) {
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
