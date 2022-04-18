import SwiftUI
import AVKit

struct AudioRecorder: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var editor: QueueEditor
    
    @State private var session: AVAudioSession!
    @State private var recorder: AVAudioRecorder!
    
    @State private var isRecording = false
    
    @State private var trackURLs = [URL]()
    let trackLocation: URL
    
    @State private var time = 0
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    init(editor: QueueEditor) {
        self.editor = editor
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(string: path)!
        self.trackLocation = documentsURL.appendingPathComponent("recordings")
        
        if !FileManager.default.fileExists(atPath: trackLocation.path) {
            do {
                try FileManager.default.createDirectory(atPath: trackLocation.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        HStack {
            List {
                ForEach(trackURLs, id: \.self) { url in
                    HStack {
                        Text(url.lastPathComponent)
                        
                        Spacer()
                        
                        Button {
                            editor.loadFile(url: url)
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
                .onDelete(perform: removeRecording)
            }
            
            VStack(spacing: 0) {
                Button(action: {
                    guard AVAudioSession.sharedInstance().recordPermission == .granted else { return }
                    
                    if isRecording {
                        recorder.stop()
                        withAnimation {
                            isRecording.toggle()
                            time = 0
                        }
                        getRecordings()
                        return
                    }
                    
                    let maxNumber = trackURLs
                        .map({ $0.deletingPathExtension().lastPathComponent })
                        .filter({ $0.contains("Recording") })
                        .map({ $0.replacingOccurrences(of: "Recording", with: "") })
                        .map({ Int($0) ?? 0 })
                        .max() ?? 0
                    
                    let filName = trackLocation.appendingPathComponent("Recording\(maxNumber + 1).m4a")
                    
                    let settings = [ AVFormatIDKey : kAudioFormatMPEG4AAC,
                          AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                          AVEncoderBitRateKey: 320000,
                          AVNumberOfChannelsKey : 2,
                          AVSampleRateKey : 44100.0 ] as [String : Any]
                    
                    recorder = try? AVAudioRecorder(url: filName, settings: settings)
                    recorder.record()
                    withAnimation {
                        isRecording.toggle()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: isRecording ? 5 : 90)
                            .fill(AVAudioSession.sharedInstance().recordPermission == .denied ? Color.secondary : Color.red)
                            .frame(width: isRecording ? 33 : 63, height: isRecording ? 33 : 63)
                        
                        Circle()
                            .stroke(colorScheme == .light ? Color.gray : Color.white, lineWidth: 4)
                            .frame(width: 75, height: 75)
                    }
                }
                .disabled(AVAudioSession.sharedInstance().recordPermission == .denied)
                
                Text("\(timeStringFromCentiseconds(time))")
                    .padding()
                    .onReceive(timer) { _ in
                        if isRecording {
                            time += 1
                        }
                    }
                    .font(.subheadline.monospaced())
            }
            .padding(.trailing)
        }
        .frame(width: 400, height: 300)
        .onAppear {
            session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playAndRecord)
            session.requestRecordPermission { _ in }
            
            getRecordings()
        }
    }
    
    func getRecordings() {
        do {
            let result = try FileManager.default.contentsOfDirectory(at: trackLocation, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            trackURLs.removeAll()
            
            for i in result {
                trackURLs.append(i)
            }
            
            trackURLs.sort(by: {
                let firstAttributes = try? FileManager.default.attributesOfItem(atPath: $0.path)
                let secondAttributes = try? FileManager.default.attributesOfItem(atPath: $1.path)
                
                guard let firstDate = firstAttributes?[.modificationDate] as? Date else { return true }
                guard let secondDate = secondAttributes?[.modificationDate] as? Date else { return false }
                
                return firstDate > secondDate
            })
        } catch {
            print(error.localizedDescription)
        }
    }
                
    func removeRecording(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        
        try? FileManager.default.removeItem(at: trackURLs[index])
        
        getRecordings()
    }
    
    func secondsToMinutesSecondsCentioseconds(_ centiseconds: Int) -> (Int, Int, Int) {
        return (centiseconds / 6000, (centiseconds % 6000) / 100, (centiseconds % 360000) % 100)
    }
    
    func timeStringFromCentiseconds(_ seconds: Int) -> String {
        let (m, s, c) = secondsToMinutesSecondsCentioseconds(seconds)
        
        let min = "\(m < 10 ? "0" : "")\(m)"
        let sec = "\(s < 10 ? "0" : "")\(s)"
        let csec = "\(c < 10 ? "0" : "")\(c)"
        
        return "\(min):\(sec):\(csec)"
    }
}
