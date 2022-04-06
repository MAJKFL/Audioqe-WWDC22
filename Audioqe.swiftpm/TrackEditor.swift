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
    let engine: AVAudioEngine
    
    @Published var reverb = AVAudioUnitReverb()
    @Published var distortion = AVAudioUnitDistortion()
    @Published var delay = AVAudioUnitDelay()
    @Published var equaliser = AVAudioUnitEQ(numberOfBands: 1)
    
    @Published var audioPlayer = AVAudioPlayerNode()
    
    @Published var file: AVAudioFile
    
    @Published var isActive = true
    
    @Published var distortionPreset = AVAudioUnitDistortionPreset.multiBrokenSpeaker {
        didSet {
            distortion.loadFactoryPreset(distortionPreset)
        }
    }
    
    @Published var reverbPreset = AVAudioUnitReverbPreset.smallRoom {
        didSet {
            reverb.loadFactoryPreset(reverbPreset)
        }
    }
    
    @Published var equaliserFilterType = AVAudioUnitEQFilterType.parametric {
        didSet {
            guard let band = equaliser.bands.first else { return }
            band.filterType = equaliserFilterType
        }
    }
    
    init(engine: AVAudioEngine, fileURL: URL) {
        self.id = fileURL.lastPathComponent
        self.engine = engine
        
        self.file = try! AVAudioFile(forReading: fileURL)
        
        reverb.loadFactoryPreset(.smallRoom)
        reverb.wetDryMix = 50
        
        distortion.loadFactoryPreset(.multiBrokenSpeaker)
        distortion.preGain = -6 // Value from -80...20
        distortion.wetDryMix = 50
        
        delay.delayTime = 1.5 // Value from 0...2
        delay.feedback = 70 // Value from -100...100
        delay.lowPassCutoff = 1500 // Value from 10...Float(file.fileFormat.sampleRate / 2)
        delay.wetDryMix = 50
        
        equaliser.globalGain = 0 // Value from -96...24

        engine.attach(audioPlayer)
        engine.attach(reverb)
        engine.attach(distortion)
        engine.attach(delay)
        engine.attach(equaliser)
        
        audioPlayer.volume = 0.5
        
        let format = file.processingFormat
        
        engine.connect(audioPlayer, to: distortion, format: format)
        
        engine.connect(distortion, to: reverb, format: format)
        
        engine.connect(reverb, to: delay, format: format)
        
        engine.connect(delay, to: equaliser, format: format)
        
        engine.connect(equaliser, to: engine.mainMixerNode, format: format)
    }
    
    func playPause() throws {
        if audioPlayer.isPlaying {
            stop()
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
    
    func stop() {
        audioPlayer.stop()
    }
    
    func setPreset(_ preset: AVAudioUnitReverbPreset) {
        reverb.wetDryMix = 50
        reverb.loadFactoryPreset(preset)
    }
    
    func setPreset(_ preset: AVAudioUnitDistortionPreset) {
        distortion.wetDryMix = 50
        distortion.loadFactoryPreset(preset)
    }
}

