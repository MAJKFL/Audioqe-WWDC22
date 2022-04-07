//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 07/04/2022.
//

import SwiftUI

struct ExitTileView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.red)
            .frame(width: 220, height: 160)
            .overlay(VStack(alignment: .leading) {
                HStack {
                    Label("Exit", systemImage: "speaker.wave.3.fill")
                        .font(.largeTitle)
                    
                    Spacer()
                }
                
                Spacer()
            }.padding())
            .foregroundColor(.white)
    }
}
