//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 09/04/2022.
//

import SwiftUI
import AVKit

struct AudioRecorder: View {
    @ObservedObject var editor: TrackEditor
    
    @State var record = false
    @State var alert = false
    
    @State var session: AVAudioSession!
    @State var recorder: AVAudioRecorder!
    
    @State var audios = [URL]()
    
    let url: URL
    
    init(editor: TrackEditor) {
        self.editor = editor
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(string: path)!
        self.url = documentsURL.appendingPathComponent("recordings")
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        HStack {
            List {
                ForEach(audios, id: \.self) { url in
                    Button {
                        editor.loadFile(url: url)
                    } label: {
                        Text(url.relativeString)
                    }
                }
                .onDelete(perform: removeRecording)
            }
            
            Button(action: {
                do {
                    if record {
                        recorder.stop()
                        withAnimation {
                            record.toggle()
                        }
                        getRecordings()
                        return
                    }
                    
                    let filName = url.appendingPathComponent("\(UUID().uuidString).m4a")
                    
                    let settings = [
                        AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey : 12000,
                        AVNumberOfChannelsKey : 1,
                        AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
                    ]
                    
                    recorder = try AVAudioRecorder(url: filName, settings: settings)
                    recorder.record()
                    withAnimation {
                        record.toggle()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: record ? 5 : 90)
                        .fill(Color.red)
                        .frame(width: record ? 33 : 63, height: record ? 33 : 63)
                    
                    Circle()
                        .stroke(Color.gray, lineWidth: 4)
                        .frame(width: 75, height: 75)
                }
                .padding(.trailing)
            }
        }
        .frame(width: 400, height: 300)
        .background(Material.ultraThin)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .alert(isPresented: $alert, content: {
            Alert(title: Text("Error"), message: Text("Enable Acess"))
        })
        .onAppear {
            do {
                session = AVAudioSession.sharedInstance()
                try session.setCategory(.playAndRecord)
                session.requestRecordPermission { (status) in
                    if !status {
                        alert.toggle()
                    } else {
                        getRecordings()
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getRecordings() {
        do {
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            self.audios.removeAll()
            
            for i in result {
                self.audios.append(i)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
                
    func removeRecording(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        
        try? FileManager.default.removeItem(at: audios[index])
        
        getRecordings()
    }
}
