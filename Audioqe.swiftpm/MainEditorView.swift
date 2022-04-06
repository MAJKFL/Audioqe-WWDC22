//
//  MainEditorView.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import SwiftUI

struct MainEditorView: View {
    @ObservedObject var editor = AudioEditor()
    
    @State private var selectedEditor: SelectedEditor?
    
    @Environment(\.editMode) private var editMode: Binding<EditMode>?
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    editor.playAll()
                } label: {
                    Image(systemName: "play.fill")
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    editor.pauseAll()
                } label: {
                    Image(systemName: "pause.fill")
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    
                } label: {
                    Image(systemName: "doc.fill.badge.plus")
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    
                } label: {
                    Image(systemName: "mic.fill.badge.plus")
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    withAnimation(.easeInOut) {
                        editMode?.wrappedValue = editMode?.wrappedValue == .active ? .inactive : .active
                    }
                } label: {
                    Image(systemName: "waveform.path.badge.minus")
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.borderedProminent)
            }

            Divider()
            
            List {
                ForEach(editor.tracks) { track in
                    TrackView(track: track, selectedEditor: $selectedEditor)
                        .listRowSeparator(.hidden)
                }
                .onDelete(perform: editor.removeTrack)
            }
            .listStyle(.plain)
            
            switch selectedEditor?.focusedOn {
            case .delay:
                DelayEditorView(track: selectedEditor!.track)
            case .distortion:
                DistortionEditorView(track: selectedEditor!.track)
            case .reverb:
                Text("Reverb")
            case .equaliser:
                Text("Equaliser")
            default:
                Text("None")
            }
        }
        .padding()
    }
}
