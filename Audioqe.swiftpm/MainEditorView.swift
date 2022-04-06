//
//  MainEditorView.swift
//  Audioqe
//
//  Created by Jakub Florek on 05/04/2022.
//

import SwiftUI
import AVFoundation

struct MainEditorView: View {
    @ObservedObject var editor = AudioEditor()
    
    @State private var selectedEditor: SelectedEditor?
    @State private var isShowingImporter = false
    
    var body: some View {
        VStack {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        editor.playAll()
                    } label: {
                        Image(systemName: "play.fill")
                    }

                    Button {
                        editor.pauseAll()
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Menu {
                        Button {
                            isShowingImporter.toggle()
                        } label: {
                            Label("Add file", systemImage: "doc.fill.badge.plus")
                        }
                        
                        Button {
                            
                        } label: {
                            Label("Add recording", systemImage: "mic.fill.badge.plus")
                        }
                    } label: {
                        Image(systemName: "waveform.badge.plus")
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .fileImporter(isPresented: $isShowingImporter, allowedContentTypes: [.audio]) { result in
            do {
                let fileURL = try result.get()
                
                let _ = fileURL.startAccessingSecurityScopedResource()
                
                editor.addNewTrack(at: fileURL)
                
                fileURL.stopAccessingSecurityScopedResource()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
