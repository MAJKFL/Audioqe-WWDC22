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
            .frame(width: 200, height: 150)
            .overlay {
                Image(systemName: editor.isPlaying ? "stop.fill" : "play.fill")
                    .font(.largeTitle)
            }
            .onTapGesture {
                withAnimation {
                    editor.playPause()
                }
            }
    }
}
