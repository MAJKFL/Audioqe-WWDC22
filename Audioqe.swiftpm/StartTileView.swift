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
                }
                .font(.largeTitle)
                
                Text("**File** - \(editor.file.url.lastPathComponent)")
                
                Text("**Length** - \(String(format: "%.0f", Double(editor.file.length) / 60000)) s")
                
                Spacer()
            }.padding())
            .foregroundColor(.white)
            .padding(.leading)
    }
}
