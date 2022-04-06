//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 07/04/2022.
//

import SwiftUI
import AVFoundation

struct TileView: View {
    @Binding var selectedBank: BankViewModel?
    
    @ObservedObject var bank: BankViewModel
    @ObservedObject var editor: TrackEditor
    
    var bgColor: Color? {
        switch bank.effect {
        case is AVAudioUnitReverb: return .mint
        case is AVAudioUnitDistortion: return .orange
        case is AVAudioUnitDelay: return .indigo
        case is AVAudioUnitEQ: return .yellow
        default: return nil
        }
    }
    
    var body: some View {
        if let bgColor = bgColor {
            RoundedRectangle(cornerRadius: 15)
                .fill(bgColor)
                .frame(width: 200, height: 150)
                .overlay(Text("\(bank.id)"))
                .onTapGesture {
                    withAnimation(.easeInOut.speed(2)) {
                        selectedBank = bank
                    }
                }
        } else {
            Menu {
                Button {
                    bank.effect = AVAudioUnitReverb()
                    editor.connectNodes()
                } label: {
                    Label("Add reverb", systemImage: "dot.radiowaves.left.and.right")
                }

                Button {
                    bank.effect = AVAudioUnitDistortion()
                    editor.connectNodes()
                } label: {
                    Label("Add distortion", systemImage: "waveform.path")
                }
                
                Button {
                    bank.effect = AVAudioUnitDelay()
                    editor.connectNodes()
                } label: {
                    Label("Add delay", systemImage: "wave.3.right")
                }
                
                Button {
                    bank.effect = AVAudioUnitEQ()
                    editor.connectNodes()
                } label: {
                    Label("Add equaliser", systemImage: "slider.vertical.3")
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(width: 200, height: 150)
                    
                    Rectangle()
                        .fill(Color.primary)
                        .frame(maxWidth: .infinity, maxHeight: 1)
                }
            }
        }
    }
}