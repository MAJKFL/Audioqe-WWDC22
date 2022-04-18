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
            guard let equalizer = effect as? AVAudioUnitEQ else { return }
            equalizerFilterType = equalizer.bands.first?.filterType ?? .parametric
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
    
    @Published var equalizerFilterType = AVAudioUnitEQFilterType.parametric {
        didSet {
            guard let equalizer = effect as? AVAudioUnitEQ else { return }
            guard let band = equalizer.bands.first else { return }
            band.filterType = equalizerFilterType
        }
    }
    
    func toggleBypass() {
        if let equalizer = effect as? AVAudioUnitEQ {
            equalizer.bands.first?.bypass.toggle()
        } else {
            effect?.auAudioUnit.shouldBypassEffect.toggle()
        }
        objectWillChange.send()
        editor.save()
        if effect is AVAudioUnitReverb { editor.connectNodes() } // Reverb bypass bug
    }
}
