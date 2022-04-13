//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 07/04/2022.
//

import SwiftUI

struct StartTileView: View {
    @StateObject var editor: QueueEditor
    
    let viewSize: CGSize
    
    @Binding var isShowingRecorder: Bool
    @Binding var isShowingImporter: Bool
    
    var sizeMultiplier: Double {
        viewSize.width <= 873.5 ? 0.9 : 1.1
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.green)
            .frame(width: 220 * sizeMultiplier, height: 160 * 1.1)
            .overlay(VStack(alignment: .leading) {
                HStack {
                    Button {
                        withAnimation {
                            editor.playPause()
                        }
                    } label: {
                        Image(systemName: editor.isPlaying ? "stop.fill" : "play.fill")
                            .foregroundColor(.accentColor)
                    }
                    
                    Text("Start")
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            if editor.playbackOptions == .loops {
                                editor.playbackOptions = .interrupts
                            } else {
                                editor.playbackOptions = .loops
                            }
                        }
                    } label: {
                        Image(systemName: editor.playbackOptions == .loops ? "repeat" : "arrow.right")
                            .foregroundColor(.accentColor)
                    }
                    .disabled(editor.isPlaying)
                }
                .font(.largeTitle)
                .disabled(editor.file == nil)
                
                if let file = editor.file {
                    Text("**File** - \(file.url.lastPathComponent)")
                    
                    Text("**Length** - \(timeStringFromSeconds(Int(file.duration)))")
                } else {
                    Menu {
                        Button {
                            isShowingImporter.toggle()
                        } label: {
                            Label("Add file", systemImage: "doc.fill.badge.plus")
                        }
                        
                        Button {
                            withAnimation {
                                isShowingRecorder.toggle()
                            }
                        } label: {
                            Label("Choose recording", systemImage: "mic.fill.badge.plus")
                        }
                    } label: {
                        Label("Add file", systemImage: "plus")
                            .foregroundColor(.accentColor)
                            .font(.headline)
                    }
                }
                
                Spacer()
            }.padding())
            .foregroundColor(.white)
            .padding(.leading)
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func timeStringFromSeconds(_ seconds: Int) -> String {
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds)
        return "\(h != 0 ? "\(h) h" : "") \(m != 0 ? "\(m) m" : "") \(s) s"
    }
}
