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
                
                Text("**File** - \(editor.file?.url.lastPathComponent ?? "No file")")
                    .foregroundColor(editor.file == nil ? .red : .white)
                
                Text("**Length** - \(timeStringFromSeconds(Int(editor.file?.length ?? 0) / 60000))")
                
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
        return "\(h != 0 ? "\(h) h" : "") \(m != 0 ? "\(m) m" : "") \(s != 0 ? "\(s) s" : "")"
    }
}
