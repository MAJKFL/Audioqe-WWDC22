//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 07/04/2022.
//

import SwiftUI

struct TileDropDelegate: DropDelegate {
    @ObservedObject var editor: TrackEditor
    
    var bank: Bank
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedBank = editor.draggedBank else { return }
        
        let fromIndex = editor.effectBanks.firstIndex(where: { $0.id == bank.id })!
        
        let toIndex = editor.effectBanks.firstIndex(where: { $0.id == draggedBank.id })!
        
        withAnimation {
            if fromIndex != toIndex {
                editor.effectBanks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
        
        editor.connectNodes()
    }
}
