//
//  AudioEditor.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import Foundation
import AVFoundation

class AudioEditor: ObservableObject {
    let engine: AVAudioEngine
    
    @Published var tracks = [TrackEditor]()
    
    init() {
        self.engine = AVAudioEngine()
        
        tracks = [
            TrackEditor(engine: engine, fileURL: Bundle.main.url(forResource: "CleanGuitar", withExtension: "aif")!)
        ]
    }
    
    func playAll() {
        for track in tracks {
            try? track.play()
        }
    }
    
    func pauseAll() {
        for track in tracks {
            track.stop()
        }
    }
    
    func removeTrack(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
    }
    
    func addNewTrack(at url: URL) {
        tracks.append(TrackEditor(engine: engine, fileURL: url))
    }
}
