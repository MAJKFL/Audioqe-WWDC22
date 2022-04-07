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
    
    func removeBank(_ bank: BankViewModel) {
        effectBanks.removeAll(where: { $0.id == bank.id })
        
        if let index = effectBanks.firstIndex(where: { $0.effect == nil }) {
            effectBanks.insert(BankViewModel(sampleRate: bank.sampleRate), at: index)
        } else {
            effectBanks.append(BankViewModel(sampleRate: bank.sampleRate))
        }
    }
}
