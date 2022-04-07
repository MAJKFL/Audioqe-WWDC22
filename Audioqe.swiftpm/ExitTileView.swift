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
            .overlay {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.largeTitle)
            }
            .foregroundColor(.white)
    }
}
