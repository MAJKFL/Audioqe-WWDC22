import SwiftUI
import AVFoundation

struct DelayEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var editor: QueueEditor
    @ObservedObject var bank: Bank
    
    @Binding var editingMessage: String?
    @Binding var helpWindowSetting: HelpWindowSetting?
    
    @State private var debounceTimer: Timer?
    
    var body: some View {
        guard let delay = bank.effect as? AVAudioUnitDelay else { fatalError() }
        
        let feedback = Binding(
            get: { delay.feedback },
            set: {
                delay.feedback = $0
                editingMessage = "\(String(format: "%.0f", $0))%"
                save()
            }
        )
        
        let delayTime = Binding(
            get: { delay.delayTime },
            set: {
                delay.delayTime = $0
                editingMessage = String(format: "%.2f", $0)
                save()
            }
        )
        
        let lowPassCutoff = Binding(
            get: { delay.lowPassCutoff },
            set: {
                delay.lowPassCutoff = $0
                editingMessage = String(format: "%.0f Hz", $0)
                save()
            }
        )
        
        let wetDryMix = Binding(
            get: { delay.wetDryMix },
            set: {
                delay.wetDryMix = $0
                editingMessage = "\(String(format: "%.0f", $0))%"
                save()
            }
        )
        
        let bypass = Binding(
            get: { delay.bypass },
            set: {
                delay.bypass = $0
                save()
            }
        )
        
        return VStack {
            VStack(alignment: .leading) {
                Text("Feedback:")
                    .font(.headline)
                
                HStack {
                    Spacer().overlay(Text("-100%"))
                    
                    Slider(value: feedback, in: -100...100) { isEditing in
                        withAnimation {
                            editingMessage = isEditing ? "" : nil
                        }
                    }
                    .frame(width: 200)
                    
                    Spacer().overlay(Text("100%"))
                }
                
                Text("Delay time:")
                    .font(.headline)
                
                HStack {
                    Spacer().overlay(Text("0"))
                    
                    Slider(value: delayTime, in: 0...2) { isEditing in
                        withAnimation {
                            editingMessage = isEditing ? "" : nil
                        }
                    }
                    .frame(width: 200)
                    
                    Spacer().overlay(Text("2"))
                }
                
                Text("Low pass cutoff:")
                    .font(.headline)
                
                HStack {
                    Spacer().overlay(Text("10 Hz"))
                    
                    Slider(value: lowPassCutoff, in: 10...Float((bank.editor.file?.fileFormat.sampleRate ?? 44100) / 2), step: 5) { isEditing in
                        withAnimation {
                            editingMessage = isEditing ? "" : nil
                        }
                    }
                    .disabled(editor.file == nil)
                    .frame(width: 200)
                    
                    Spacer().overlay(Text(editor.file == nil ? "No file" : String(format: "%.0f Hz", Float((bank.editor.file?.fileFormat.sampleRate ?? 40) / 2))).foregroundColor(editor.file == nil ? .red : .primary))
                }
                
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
                    helpWindowSetting = .delay
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
