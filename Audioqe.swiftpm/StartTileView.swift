import SwiftUI
import AVFoundation

struct StartTileView: View {
    @StateObject var editor: QueueEditor
    
    @State private var isShowingImporter = false
    @State private var isShowingRecorder = false
    
    let viewSize: CGSize
    
    var sizeMultiplier: Double {
        viewSize.width <= 873.5 && viewSize.width > viewSize.height ? 0.9 : 1.1
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.green)
            .frame(width: 220 * sizeMultiplier, height: 160 * 1.1)
            .overlay(VStack(alignment: .leading) {
                HStack {
                    Button {
                        editor.playPause()
                    } label: {
                        Image(systemName: editor.isPlaying ? "stop.fill" : "play.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 20, height: 20)
                    }
                    .padding(.horizontal, 5)
                    
                    Text("Start")
                    
                    Spacer()
                    
                    Button {
                        if editor.playbackOptions == .loops {
                            editor.playbackOptions = .interrupts
                        } else {
                            editor.playbackOptions = .loops
                        }
                    } label: {
                        Image(systemName: editor.playbackOptions == .loops ? "repeat" : "arrow.right")
                            .foregroundColor(.accentColor)
                    }
                    .disabled(editor.isPlaying)
                }
                .font(.largeTitle)
                .disabled(editor.file == nil)
                
                if let file = editor.file {
                    Text("File - **\(file.url.lastPathComponent)**")
                        .lineLimit(1)
                    
                    Text("Length - **\(timeStringFromSeconds(Int(file.duration)))**")
                }
                
                Menu {
                    Button {
                        isShowingImporter.toggle()
                    } label: {
                        Label("Import file", systemImage: "doc.fill.badge.plus")
                    }
                    
                    Button {
                        if AVAudioSession.sharedInstance().recordPermission == .undetermined {
                            let session = AVAudioSession.sharedInstance()
                            try? session.setCategory(.playAndRecord)
                            session.requestRecordPermission { _ in }
                        } else {
                            isShowingRecorder.toggle()
                        }
                    } label: {
                        Label("Choose recording", systemImage: "mic.fill.badge.plus")
                    }
                } label: {
                    Label(editor.file == nil ? "Add recording" : "Change recording", systemImage: "waveform.path.badge.plus")
                        .foregroundColor(.accentColor)
                        .font(.headline)
                }
                
                Spacer()
            }.padding())
            .foregroundColor(.white)
            .padding(.leading)
            .fileImporter(isPresented: $isShowingImporter, allowedContentTypes: [.audio], onCompletion: { result in
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentsURL = URL(string: path)!
                let recordingsURL = documentsURL.appendingPathComponent("recordings")
                
                if !FileManager.default.fileExists(atPath: recordingsURL.path) {
                    do {
                        try FileManager.default.createDirectory(atPath: recordingsURL.path, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                do {
                    let fileURL = try result.get()
                    
                    let _ = fileURL.startAccessingSecurityScopedResource()
                    
                    let destination = URL(string: "file://\(recordingsURL.appendingPathComponent(fileURL.lastPathComponent).absoluteString)")!
                    
                    if FileManager.default.fileExists(atPath: destination.path) {
                        try FileManager.default.removeItem(at: destination)
                    }
                    
                    try FileManager.default.copyItem(at: fileURL, to: destination)
                    
                    editor.loadFile(url: destination)
                    
                    fileURL.stopAccessingSecurityScopedResource()
                } catch {
                    print(error.localizedDescription)
                }
            })
            .popover(isPresented: $isShowingRecorder, content: { AudioRecorder(editor: editor) })
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func timeStringFromSeconds(_ seconds: Int) -> String {
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds)
        return "\(h != 0 ? "\(h) h" : "") \(m != 0 ? "\(m) m" : "") \(s) s"
    }
}
