import Foundation

enum SavedBankType: String {
    case reverb
    case distortion
    case delay
    case equalizer
    case empty
}

struct SaveQueue: Codable, Identifiable {
    var id: String
    var name: String
    var volume: Float
    var lastOpenedFile: URL?
    var banks: [[String: String]]
}
