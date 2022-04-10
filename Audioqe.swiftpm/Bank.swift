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
    @Published var editor: QueueEditor
    @Published var effect: AVAudioUnit?
    
    init(editor: QueueEditor, effect: AVAudioUnit? = nil) {
        self.editor = editor
        self.effect = effect
        
        switch effect {
        case is AVAudioUnitReverb: reverbPreset = AVAudioUnitReverbPreset(rawValue: effect?.auAudioUnit.currentPreset?.number ?? 0) ?? .smallRoom
        case is AVAudioUnitDistortion: distortionPreset = AVAudioUnitDistortionPreset(rawValue: effect?.auAudioUnit.currentPreset?.number ?? 0) ?? .drumsBitBrush
        case is AVAudioUnitEQ:
            guard let equaliser = effect as? AVAudioUnitEQ else { return }
            equaliserFilterType = equaliser.bands.first?.filterType ?? .parametric
        default: return
        }
    }
    
    @Published var reverbPreset = AVAudioUnitReverbPreset.smallRoom {
        didSet {
            guard let reverb = effect as? AVAudioUnitReverb else { return }
            reverb.loadFactoryPreset(reverbPreset)
        }
    }
    
    @Published var distortionPreset = AVAudioUnitDistortionPreset.drumsBitBrush {
        didSet {
            guard let distortion = effect as? AVAudioUnitDistortion else { return }
            distortion.loadFactoryPreset(distortionPreset)
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
