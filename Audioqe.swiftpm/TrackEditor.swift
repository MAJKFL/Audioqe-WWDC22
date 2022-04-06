//
//  TrackEditor.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import Foundation
import AVFoundation

class TrackEditor: ObservableObject, Identifiable {
    let id: String
    let engine = AVAudioEngine()
    
    @Published var effectBanks = [BankViewModel]()
    @Published var draggedBank: BankViewModel?
    
    @Published var audioPlayer = AVAudioPlayerNode()
    @Published var file: AVAudioFile
    
    @Published var isPlaying = false
    
    init(fileURL: URL) {
        self.id = fileURL.lastPathComponent
        
        self.file = try! AVAudioFile(forReading: fileURL)
        
        engine.attach(audioPlayer)
        
        audioPlayer.volume = 0.5
        
        let format = file.processingFormat
        
        effectBanks = [
            BankViewModel(sampleRate: file.fileFormat.sampleRate),
            BankViewModel(sampleRate: file.fileFormat.sampleRate),
            BankViewModel(sampleRate: file.fileFormat.sampleRate),
            BankViewModel(sampleRate: file.fileFormat.sampleRate),
            BankViewModel(sampleRate: file.fileFormat.sampleRate),
            BankViewModel(sampleRate: file.fileFormat.sampleRate)
        ]
        
        engine.connect(audioPlayer, to: engine.mainMixerNode, format: format)
        
        connectNodes()
    }
    
    func connectNodes() {
        let format = file.processingFormat
        
        let nodes = effectBanks.compactMap { $0.effect }

        for node in nodes {
            engine.attach(node)
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
            isPlaying = false
        } else {
            audioPlayer.scheduleFile(file, at: nil)
            
            try? engine.start()
            audioPlayer.play()
            isPlaying = true
        }
    }
}
