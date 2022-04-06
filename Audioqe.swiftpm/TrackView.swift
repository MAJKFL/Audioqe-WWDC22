//
//  TrackView.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import SwiftUI

enum FocusedEffect {
    case reverb
    case distortion
    case delay
    case equaliser
    case none
}

struct SelectedEditor: Identifiable {
    let focusedOn: FocusedEffect
    let track: TrackEditor
    
    public var id: String {
        track.id
    }
}

struct TrackView: View {
    @ObservedObject var track: TrackEditor
    
    @Binding var selectedEditor: SelectedEditor?
    
    init(track: TrackEditor, selectedEditor: Binding<SelectedEditor?>) {
        self.track = track
        self._selectedEditor = selectedEditor
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(track.id)
            
            HStack {
                Toggle("", isOn: $track.isActive.animation())
                
                Spacer()
                    .layoutPriority(1)
                
                HStack {
                    Slider(value: $track.audioPlayer.volume, in: 0...1)
                        .frame(width: 200)
                    
                    Button {
                        withAnimation {
                            selectedEditor = SelectedEditor(focusedOn: .reverb, track: track)
                        }
                    } label: {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .frame(width: 15, height: 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                    Button {
                        withAnimation {
                            selectedEditor = SelectedEditor(focusedOn: .distortion, track: track)
                        }
                    } label: {
                        Image(systemName: "waveform.path")
                            .frame(width: 15, height: 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                    Button {
                        withAnimation {
                            selectedEditor = SelectedEditor(focusedOn: .delay, track: track)
                        }
                    } label: {
                        Image(systemName: "wave.3.right")
                            .frame(width: 15, height: 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    
                    Button {
                        withAnimation {
                            selectedEditor = SelectedEditor(focusedOn: .equaliser, track: track)
                        }
                    } label: {
                        Image(systemName: "slider.vertical.3")
                            .frame(width: 15, height: 15)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.yellow)
                }
                .disabled(!track.isActive)
            }
        }
    }
}
