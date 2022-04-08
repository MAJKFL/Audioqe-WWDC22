//
//  TrackEditor.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import Foundation
import AVFoundation
import SwiftUI

class TrackEditor: ObservableObject, Identifiable {
    let id: String
    let engine = AVAudioEngine()
    
    @Published var effectBanks = [Bank]()
    @Published var draggedBank: Bank?
    
    @Published var audioPlayer = AVAudioPlayerNode()
    
    @Published var file: AVAudioFile?
    @Published var buffer: AVAudioPCMBuffer?
    
    @Published var isPlaying = false
    @Published var playbackOptions = AVAudioPlayerNodeBufferOptions.loops
    
    var activeBanksCount: Int {
        effectBanks.compactMap({ $0.effect }).count
    }
    
    static let reverbPresetNames = [
        0:  "Small room",
        1:  "Medium room",
        2:  "Large room",
        3:  "Medium hall",
        4:  "Large hall",
        5:  "Plate",
        6:  "Medium chamber",
        7:  "Large chamber",
        8:  "Cathedral",
        9:  "Large room 2",
        10: "Medium hall 2",
        11: "Medium hall 3",
        12: "Large hall 2"
    ]
    
    static let eqFilterNames = [
        0:  "Parametric",
        1:  "Low pass",
        2:  "High pass",
        3:  "Resonant low pass",
        4:  "Resonant high pass",
        5:  "Band pass",
        6:  "Band stop",
        7:  "Low shelf",
        8:  "High shelf",
        9:  "Resonant low shelf",
        10: "Resonant high shelf"
    ]
    
    static let distortionPresetNames = [
        0:  "Drums bit brush",
        1:  "Drums buffer beats",
        2:  "Drums lo fi",
        3:  "Multi broken speaker",
        4:  "Multi cell phone speaker",
        5:  "Multi decimated 1",
        6:  "Multi decimated 2",
        7:  "Multi decimated 3",
        8:  "Multi decimated 4",
        9:  "Multi distorted funk",
        10: "Multi distorted cube",
        11: "Multi distorted squared",
        12: "Multi echo 1",
        13: "Multi echo 2",
        14: "Multi echo tight 1",
        15: "Multi echo tight 2",
        16: "Multi everything is broken",
        17: "Speech alien chatter",
        18: "Speech cosmic interference",
        19: "Speech golden pi",
        20: "Speech radio tower",
        21: "Speech waves"
    ]
    
    init() {
        self.id = UUID().uuidString
        
        engine.attach(audioPlayer)
        audioPlayer.volume = 1
        
        effectBanks = [
            Bank(editor: self),
            Bank(editor: self),
            Bank(editor: self),
            Bank(editor: self),
            Bank(editor: self),
            Bank(editor: self)
        ]
    }
    
    func loadFile(url: URL) {
        file = try? AVAudioFile(forReading: url)
        
        guard let file = file else { return }
        
        buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        
        guard let buffer = buffer else { return }

        do {
            print("read")
            try file.read(into: buffer)
        } catch {
            print(error)
        }
        
        connectNodes()
    }
    
    func connectNodes() {
        guard let format = file?.processingFormat else { return }
        
        let nodes = effectBanks.compactMap { $0.effect }

        for node in nodes {
            engine.attach(node)
        }
        
        if nodes.isEmpty {
            engine.connect(audioPlayer, to: engine.mainMixerNode, format: format)
        }

        for index in nodes.indices {
            if nodes.count == 1 {
                engine.connect(audioPlayer, to: nodes[0], format: format)
                engine.connect(nodes[0], to: engine.mainMixerNode, format: format)
                break
            }
            
            switch index {
            case 0: engine.connect(audioPlayer, to: nodes[index], format: format)
            case nodes.count - 1:
                engine.connect(nodes[index - 1], to: nodes[index], format: format)
                engine.connect(nodes[index], to: engine.mainMixerNode, format: format)
            default: engine.connect(nodes[index - 1], to: nodes[index], format: format)
            }
        }
        
        isPlaying = false
    }
    
    func playPause() {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            engine.stop()
            isPlaying = false
        } else {
            scheduleBuffer()
            
            try? engine.start()
            audioPlayer.play()
            isPlaying = true
        }
    }
    
    func clearBank(_ bank: Bank) {
        effectBanks.removeAll(where: { $0.id == bank.id })
        
        if let index = effectBanks.firstIndex(where: { $0.effect == nil }) {
            effectBanks.insert(Bank(editor: self), at: index)
        } else {
            effectBanks.append(Bank(editor: self))
        }
        
        connectNodes()
    }
    
    func scheduleBuffer() {
        guard let buffer = buffer else { return }

        audioPlayer.scheduleBuffer(buffer, at: nil, options: playbackOptions, completionHandler: {
            DispatchQueue.main.async {
                withAnimation {
                    self.isPlaying = false
                }
            }
        })
    }
    
    func render() -> URL? {
        guard let file = file else { return nil }
        let format = file.processingFormat
        
        scheduleBuffer()
        
        let maxFrames: AVAudioFrameCount = 4096
        
        do {
            try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: maxFrames)
        } catch {
            fatalError("Enabling manual rendering mode failed: \(error).")
        }
        
        do {
            try engine.start()
            audioPlayer.play()
        } catch {
            fatalError("Unable to start audio engine: \(error).")
        }
        
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat, frameCapacity: engine.manualRenderingMaximumFrameCount)!
        let outputFile: AVAudioFile
        
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentsURL.appendingPathComponent("\(file.url.deletingPathExtension().lastPathComponent)-processed.m4a")
            outputFile = try AVAudioFile(forWriting: outputURL, settings: file.fileFormat.settings)
        } catch {
            fatalError("Unable to open output audio file: \(error).")
        }
        
        while engine.manualRenderingSampleTime < file.length {
            do {
                let frameCount = file.length - engine.manualRenderingSampleTime
                let framesToRender = min(AVAudioFrameCount(frameCount), outputBuffer.frameCapacity)
                
                let status = try engine.renderOffline(framesToRender, to: outputBuffer)
                
                switch status {
                case .success: try outputFile.write(from: outputBuffer)
                case .insufficientDataFromInputNode: break
                case .cannotDoInCurrentContext: break
                case .error: fatalError("The manual rendering failed.")
                @unknown default: fatalError("Unknown error")
                }
            } catch {
                fatalError("The manual rendering failed: \(error).")
            }
        }

        audioPlayer.stop()
        engine.stop()
        engine.disableManualRenderingMode()
        
        return outputFile.url
    }
}
