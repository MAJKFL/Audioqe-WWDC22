//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 07/04/2022.
//

import SwiftUI

struct TileDropDelegate: DropDelegate {
    @ObservedObject var editor: TrackEditor
    
    var bank: BankViewModel
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedBank = editor.draggedBank else { return }
        
        let fromIndex = editor.effectBanks.firstIndex(where: { $0.id == bank.id })!
        
        let toIndex = editor.effectBanks.firstIndex(where: { $0.id == draggedBank.id })!
        
        if fromIndex != toIndex {
            let fromBank = editor.effectBanks[fromIndex]
            editor.effectBanks[fromIndex] = editor.effectBanks[toIndex]
            editor.effectBanks[toIndex] = fromBank
        }
        
        editor.connectNodes()
    }
}
