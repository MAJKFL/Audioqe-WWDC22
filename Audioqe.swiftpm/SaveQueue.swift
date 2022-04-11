//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 10/04/2022.
//

import Foundation

enum SavedBankType: String {
    case reverb
    case distortion
    case delay
    case equaliser
    case empty
}

struct SaveQueue: Codable, Identifiable {
    var id: String
    var name: String
    var volume: Float
    var lastOpenedFile: URL?
    var banks: [[String: String]]
}
