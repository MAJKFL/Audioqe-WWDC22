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
        0:  "small room",
        1:  "medium room",
        2:  "large room",
        3:  "medium hall",
        4:  "large hall",
        5:  "plate",
        6:  "medium chamber",
        7:  "large chamber",
        8:  "cathedral",
        9:  "large room 2",
        10: "medium hall 2",
        11: "medium hall 3",
        12: "large hall 2"
    ]
    
    static let eqFilterNames = [
        0:  "parametric",
        1:  "low pass",
        2:  "high pass",
        3:  "resonant low pass",
        4:  "resonant high pass",
        5:  "band pass",
        6:  "band stop",
        7:  "low shelf",
        8:  "high shelf",
        9:  "resonant low shelf",
        10: "resonant high shelf"
    ]
    
    static let distortionPresetNames = [
        0:  "drums bit brush",
        1:  "drums buffer beats",
        2:  "drums lo fi",
        3:  "multi broken speaker",
        4:  "multi cell phone speaker",
        5:  "multi decimated 1",
        6:  "multi decimated 2",
        7:  "multi decimated 3",
        8:  "multi decimated 4",
        9:  "multi distorted funk",
        10: "multi distorted cube",
        11: "multi distorted squared",
        12: "multi echo 1",
        13: "multi echo 2",
        14: "multi echo tight 1",
        15: "multi echo tight 2",
        16: "multi everything is broken",
        17: "speech alien chatter",
        18: "speech cosmic interference",
        19: "speech golden pi",
        20: "speech radio tower",
        21: "speech waves"
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
            scheduldeBuffer()
            
            try? engine.start()
            audioPlayer.play()
            isPlaying = true
        }
    }
    
    func removeBank(_ bank: Bank) {
        effectBanks.removeAll(where: { $0.id == bank.id })
        
        if let index = effectBanks.firstIndex(where: { $0.effect == nil }) {
            effectBanks.insert(Bank(editor: self), at: index)
        } else {
            effectBanks.append(Bank(editor: self))
        }
        
        connectNodes()
    }
    
    func scheduldeBuffer() {
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
        
        scheduldeBuffer()
        
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
