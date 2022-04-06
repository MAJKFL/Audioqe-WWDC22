//
//  TrackEditor.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import Foundation
import AVFoundation
import AVFAudio

class TrackEditor: ObservableObject, Identifiable {
    let id: String
    let engine = AVAudioEngine()
    
    @Published var effectBanks = [
        EffectBankViewModel(),
        EffectBankViewModel(),
        EffectBankViewModel(),
        EffectBankViewModel(),
        EffectBankViewModel(),
        EffectBankViewModel()
    ]
    
    @Published var draggedBank: EffectBankViewModel?
    
    @Published var audioPlayer = AVAudioPlayerNode()
    
    @Published var file: AVAudioFile
    
    @Published var isActive = true
    
    init(fileURL: URL) {
        self.id = fileURL.lastPathComponent
        
        self.file = try! AVAudioFile(forReading: fileURL)
        
        engine.attach(audioPlayer)
        
        audioPlayer.volume = 0.5
        
        let format = file.processingFormat
        
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
                return
            }
            
            switch index {
            case 0: engine.connect(audioPlayer, to: nodes[index], format: format)
            case nodes.count - 1:
                engine.connect(nodes[index - 1], to: nodes[index], format: format)
                engine.connect(nodes[index], to: engine.mainMixerNode, format: format)
            default: engine.connect(nodes[index - 1], to: nodes[index], format: format)
            }
        }
    }
    
    func playPause() throws {
        if audioPlayer.isPlaying {
            pause()
        } else {
            try play()
        }
    }
    
    func play() throws {
        if isActive {
            audioPlayer.scheduleFile(file, at: nil)
            
            try engine.start()
            audioPlayer.play()
        }
    }
    
    func pause() {
        audioPlayer.stop()
    }
}

class EffectBankViewModel: Identifiable, ObservableObject {
    @Published var id = UUID().uuidString
    @Published var effect: AVAudioUnit?
    
    init(effect: AVAudioUnit? = nil) {
        self.effect = effect
    }
    
    @Published var distortionPreset = AVAudioUnitDistortionPreset.multiBrokenSpeaker {
        didSet {
            guard let distortion = effect as? AVAudioUnitDistortion else { return }
            distortion.loadFactoryPreset(distortionPreset)
        }
    }
    
    @Published var reverbPreset = AVAudioUnitReverbPreset.smallRoom {
        didSet {
            guard let reverb = effect as? AVAudioUnitReverb else { return }
            reverb.loadFactoryPreset(reverbPreset)
        }
    }
    
    @Published var equaliserFilterType = AVAudioUnitEQFilterType.parametric {
        didSet {
            guard let equaliser = effect as? AVAudioUnitEQ else { return }
            guard let band = equaliser.bands.first else { return }
            band.filterType = equaliserFilterType
        }
    }
    
    func setPreset(_ preset: AVAudioUnitReverbPreset) {
        guard let reverb = effect as? AVAudioUnitReverb else { return }
        reverb.loadFactoryPreset(preset)
    }
    
    func setPreset(_ preset: AVAudioUnitDistortionPreset) {
        guard let distortion = effect as? AVAudioUnitDistortion else { return }
        distortion.loadFactoryPreset(preset)
    }
}
