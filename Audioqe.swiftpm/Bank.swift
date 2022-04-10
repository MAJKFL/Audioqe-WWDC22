//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 07/04/2022.
//

import Foundation
import AVFoundation

class Bank: Identifiable, ObservableObject {    
    @Published var id = UUID().uuidString
    @Published var editor: TrackEditor
    @Published var effect: AVAudioUnit?
    
    init(editor: TrackEditor, effect: AVAudioUnit? = nil) {
        self.editor = editor
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