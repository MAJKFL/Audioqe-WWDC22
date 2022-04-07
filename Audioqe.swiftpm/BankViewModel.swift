//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 07/04/2022.
//

import Foundation
import AVFoundation

class BankViewModel: Identifiable, ObservableObject {    
    @Published var id = UUID().uuidString
    @Published var effect: AVAudioUnit?
    @Published var sampleRate: Double
    
    init(sampleRate: Double, effect: AVAudioUnit? = nil) {
        self.sampleRate = sampleRate
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
}
