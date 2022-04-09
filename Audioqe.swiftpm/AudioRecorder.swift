//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 09/04/2022.
//

import SwiftUI
import AVKit
import Combine

struct AudioRecorder: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var editor: TrackEditor
    
    @State var isRecording = false
    
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
            
            Button(action: {
                if isRecording {
                    recorder.stop()
                    withAnimation {
                        isRecording.toggle()
                    }
                    getRecordings()
                    return
                }
                
                let names: [String] = audios.map { url in
                    url.deletingPathExtension().lastPathComponent
                }
                
                let filteredNames = names.filter({ $0.contains("Recording") })
                
                let filName = url.appendingPathComponent("Recording\(filteredNames.count + 1).m4a")
                
                let settings = [
                    AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey : 12000,
                    AVNumberOfChannelsKey : 1,
                    AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
                ]
                
                recorder = try? AVAudioRecorder(url: filName, settings: settings)
                recorder.record()
                withAnimation {
                    isRecording.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: isRecording ? 5 : 90)
                        .fill(Color.red)
                        .frame(width: isRecording ? 33 : 63, height: isRecording ? 33 : 63)
                    
                    Circle()
                        .stroke(colorScheme == .light ? Color.gray : Color.white, lineWidth: 4)
                        .frame(width: 75, height: 75)
                }
                .padding(.trailing)
                .padding(.leading, 5)
            }
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
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            self.audios.removeAll()
            
            for i in result {
                self.audios.append(i)
            }
            
            audios.sort(by: { $0.lastPathComponent < $1.lastPathComponent })
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
