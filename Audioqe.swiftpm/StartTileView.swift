//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 07/04/2022.
//

import SwiftUI

struct StartTileView: View {
    @StateObject var editor: TrackEditor
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.green)
            .frame(width: 220, height: 160)
            .overlay(VStack(alignment: .leading) {
                HStack {
                    Label("Start", systemImage: editor.isPlaying ? "stop.fill" : "play.fill")
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                }
                
                Text("**File** - \(editor.file.url.lastPathComponent)")
                
                Spacer()
            }.padding())
            .onTapGesture {
                withAnimation {
                    editor.playPause()
                }
            }
            .foregroundColor(.white)
    }
}
