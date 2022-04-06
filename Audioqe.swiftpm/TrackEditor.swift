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
    
    @Published var audioPlayer = AVAudioPlayerNode()
    
    @Published var file: AVAudioFile
    
    @Published var isActive = true
    
    @Published var distortionPreset = AVAudioUnitDistortionPreset.multiBrokenSpeaker {
        didSet {
            distortion.loadFactoryPreset(distortionPreset)
        }
    }
    
    init(engine: AVAudioEngine, fileName: String) {
        self.id = fileName
        self.engine = engine
        
        let sourceFileURL = Bundle.main.url(forResource: fileName, withExtension: "aif")!
        self.file = try! AVAudioFile(forReading: sourceFileURL)
        
        reverb.loadFactoryPreset(.largeChamber)
        reverb.wetDryMix = 50
        
        distortion.loadFactoryPreset(.multiBrokenSpeaker)
        distortion.preGain = -6 // Value from -80...20
        distortion.wetDryMix = 50
        
        delay.delayTime = 1.5 // Value from 0...2
        delay.feedback = 70 // Value from -100...100
        delay.lowPassCutoff = 1500 // Value from 10...Float(file.fileFormat.sampleRate / 2)
        delay.wetDryMix = 50

        engine.attach(audioPlayer)
        engine.attach(reverb)
        engine.attach(distortion)
        engine.attach(delay)
        
        audioPlayer.volume = 0.5
        
        let format = file.processingFormat
        
        engine.connect(audioPlayer, to: distortion, format: format)
        engine.connect(distortion, to: engine.mainMixerNode, format: format)
        
        engine.connect(distortion, to: reverb, format: format)
        engine.connect(reverb, to: engine.mainMixerNode, format: format)
        
        engine.connect(reverb, to: delay, format: format)
        engine.connect(delay, to: engine.mainMixerNode, format: format)
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
    
    func disableAllEffects() {
        reverb.wetDryMix = 0;
        distortion.wetDryMix = 0;
    }
}

