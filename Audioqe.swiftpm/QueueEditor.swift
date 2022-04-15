import Foundation
import AVFoundation
import SwiftUI

class QueueEditor: ObservableObject, Identifiable {
    let id: String
    let engine = AVAudioEngine()
    
    @Published var effectBanks = [Bank]()
    @Published var draggedBank: Bank?
    
    @Published var audioPlayer = AVAudioPlayerNode()
    
    @Published var file: AVAudioFile?
    @Published var buffer: AVAudioPCMBuffer?
    
    @Published var isPlaying = false
    @Published var playbackOptions = AVAudioPlayerNodeBufferOptions.loops
    
    @Published var name = "New editor"
    
    var activeBanksCount: Int {
        effectBanks.compactMap({ $0.effect }).count
    }
    
    static let reverbPresetNames = [
        0:  "Small room",
        1:  "Medium room",
        2:  "Large room",
        3:  "Medium hall",
        4:  "Large hall",
        5:  "Plate",
        6:  "Medium chamber",
        7:  "Large chamber",
        8:  "Cathedral",
        9:  "Large room 2",
        10: "Medium hall 2",
        11: "Medium hall 3",
        12: "Large hall 2"
    ]
    
    static let eqFilterNames = [
        0:  "Parametric",
        1:  "Low pass",
        2:  "High pass",
        3:  "Resonant low pass",
        4:  "Resonant high pass",
        5:  "Band pass",
        6:  "Band stop",
        7:  "Low shelf",
        8:  "High shelf",
        9:  "Resonant low shelf",
        10: "Resonant high shelf"
    ]
    
    static let distortionPresetNames = [
        0:  "Drums bit brush",
        1:  "Drums buffer beats",
        2:  "Drums lo fi",
        3:  "Multi broken speaker",
        4:  "Multi cell phone speaker",
        5:  "Multi decimated 1",
        6:  "Multi decimated 2",
        7:  "Multi decimated 3",
        8:  "Multi decimated 4",
        9:  "Multi distorted funk",
        10: "Multi distorted cube",
        11: "Multi distorted squared",
        12: "Multi echo 1",
        13: "Multi echo 2",
        14: "Multi echo tight 1",
        15: "Multi echo tight 2",
        16: "Multi everything is broken",
        17: "Speech alien chatter",
        18: "Speech cosmic interference",
        19: "Speech golden pi",
        20: "Speech radio tower",
        21: "Speech waves"
    ]
    
    init() {
        self.id = UUID().uuidString
        
        engine.attach(audioPlayer)
        
        engine.mainMixerNode.volume = 1
        
        effectBanks = [
            Bank(editor: self),
            Bank(editor: self),
            Bank(editor: self),
            Bank(editor: self),
            Bank(editor: self),
            Bank(editor: self)
        ]
    }
    
    init(_ savedQueue: SaveQueue) {
        self.id = savedQueue.id
        name = savedQueue.name
        
        engine.attach(audioPlayer)
        audioPlayer.volume = savedQueue.volume
        
        engine.mainMixerNode.volume = 1
        
        if let url = savedQueue.lastOpenedFile {
            loadFile(url: url)
        }
        
        for bank in savedQueue.banks {
            switch bank["type"] {
            case SavedBankType.reverb.rawValue:
                let reverb = AVAudioUnitReverb()
                
                if let preset = AVAudioUnitReverbPreset(rawValue: Int(bank["preset"]!)!) {
                    reverb.loadFactoryPreset(preset)
                }
                reverb.wetDryMix = Float(bank["wetDryMix"]!)!
                reverb.bypass = bank["bypass"] == "On" ? true : false
                
                effectBanks.append(Bank(editor: self, effect: reverb))
            case SavedBankType.distortion.rawValue:
                let distortion = AVAudioUnitDistortion()
                
                if let preset = AVAudioUnitDistortionPreset(rawValue: Int(bank["preset"]!)!) {
                    distortion.loadFactoryPreset(preset)
                }
                distortion.preGain = Float(bank["preGain"]!)!
                distortion.wetDryMix = Float(bank["wetDryMix"]!)!
                distortion.bypass = bank["bypass"] == "On" ? true : false
                
                effectBanks.append(Bank(editor: self, effect: distortion))
            case SavedBankType.delay.rawValue:
                let delay = AVAudioUnitDelay()
                
                delay.feedback = Float(bank["feedback"]!)!
                delay.delayTime = Double(bank["delayTime"]!)!
                delay.lowPassCutoff = Float(bank["lowPassCutoff"]!)!
                delay.wetDryMix = Float(bank["wetDryMix"]!)!
                delay.bypass = bank["bypass"] == "On" ? true : false
                
                effectBanks.append(Bank(editor: self, effect: delay))
            case SavedBankType.equaliser.rawValue:
                let equaliser = AVAudioUnitEQ(numberOfBands: 1)
                
                if let filter = AVAudioUnitEQFilterType(rawValue: Int(bank["filter"]!)!) {
                    equaliser.bands.first?.filterType = filter
                }
                equaliser.bands.first?.bandwidth = Float(bank["bandwidth"]!)!
                equaliser.bands.first?.bypass = bank["bypass"] == "On" ? true : false
                equaliser.bands.first?.frequency = Float(bank["frequency"]!)!
                equaliser.bands.first?.gain = Float(bank["gain"]!)!
                
                effectBanks.append(Bank(editor: self, effect: equaliser))
            default:
                effectBanks.append(Bank(editor: self))
            }
        }
        
        connectNodes()
    }
    
    func exportQueue() -> SaveQueue {
        var savedBanks = [
            ["": ""],
            ["": ""],
            ["": ""],
            ["": ""],
            ["": ""],
            ["": ""]
        ]
        
        for index in effectBanks.indices {
            switch effectBanks[index].effect {
            case is AVAudioUnitReverb:
                guard let effect = effectBanks[index].effect as? AVAudioUnitReverb else { break }
                savedBanks[index]["type"] = SavedBankType.reverb.rawValue
                savedBanks[index]["preset"] = "\(effectBanks[index].reverbPreset.rawValue)"
                savedBanks[index]["wetDryMix"] = "\(effect.wetDryMix)"
                savedBanks[index]["bypass"] = "\(effect.bypass ? "On" : "Off")"
            case is AVAudioUnitDistortion:
                guard let effect = effectBanks[index].effect as? AVAudioUnitDistortion else { break }
                savedBanks[index]["type"] = SavedBankType.distortion.rawValue
                savedBanks[index]["preset"] = "\(effectBanks[index].distortionPreset.rawValue)"
                savedBanks[index]["preGain"] = "\(effect.preGain)"
                savedBanks[index]["wetDryMix"] = "\(effect.wetDryMix)"
                savedBanks[index]["bypass"] = "\(effect.bypass ? "On" : "Off")"
            case is AVAudioUnitDelay:
                guard let effect = effectBanks[index].effect as? AVAudioUnitDelay else { break }
                savedBanks[index]["type"] = SavedBankType.delay.rawValue
                savedBanks[index]["feedback"] = "\(effect.feedback)"
                savedBanks[index]["delayTime"] = "\(effect.delayTime)"
                savedBanks[index]["lowPassCutoff"] = "\(effect.lowPassCutoff)"
                savedBanks[index]["wetDryMix"] = "\(effect.wetDryMix)"
                savedBanks[index]["bypass"] = "\(effect.bypass ? "On" : "Off")"
            case is AVAudioUnitEQ:
                guard let effect = effectBanks[index].effect as? AVAudioUnitEQ else { break }
                savedBanks[index]["type"] = SavedBankType.equaliser.rawValue
                savedBanks[index]["filter"] = "\(effectBanks[index].equaliserFilterType.rawValue)"
                savedBanks[index]["bandwidth"] = "\(effect.bands.first?.bandwidth ?? 0.05)"
                savedBanks[index]["bypass"] = "\(effect.bands.first?.bypass ?? false ? "On" : "Off")"
                savedBanks[index]["frequency"] = "\(effect.bands.first?.frequency ?? 20)"
                savedBanks[index]["gain"] = "\(effect.bands.first?.gain ?? 0)"
            default:
                savedBanks[index]["type"] = SavedBankType.empty.rawValue
            }
        }
        
        return SaveQueue(id: id, name: name, volume: audioPlayer.volume, lastOpenedFile: file?.url, banks: savedBanks)
    }
    
    func save() {
        let savedQueue = exportQueue()
        
        var allQueues = [SaveQueue]()
        
        if let data = UserDefaults.standard.data(forKey: QueueList.saveKey) {
            if let decoded = try? JSONDecoder().decode([SaveQueue].self, from: data) {
                allQueues = decoded
                if let index = allQueues.firstIndex(where: { $0.id == savedQueue.id }) {
                    allQueues[index] = savedQueue
                } else {
                    return
                }
            }
        }
        
        if let encoded = try? JSONEncoder().encode(allQueues) {
            UserDefaults.standard.set(encoded, forKey: QueueList.saveKey)
        }
    }
    
    func loadFile(url: URL) {
        pause()
        
        file = try? AVAudioFile(forReading: url)
        
        guard let file = file else { return }
        
        buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        
        guard let buffer = buffer else { return }

        do {
            print("read")
            try file.read(into: buffer)
        } catch {
            print(error)
        }
        
        connectNodes()
    }
    
    func connectNodes() {
        let format = file?.processingFormat 
        
        let nodes = effectBanks
            .compactMap { $0.effect }
            .filter({ // Reverb bypass bug
                guard let reverb = $0 as? AVAudioUnitReverb else { return true }
                return !reverb.bypass
            })

        for node in nodes {
            engine.attach(node)
        }
        
        if nodes.isEmpty {
            engine.connect(audioPlayer, to: engine.mainMixerNode, format: format)
        }

        for index in nodes.indices {
            if nodes.count == 1 {
                engine.connect(audioPlayer, to: nodes[0], format: format)
                engine.connect(nodes[0], to: engine.mainMixerNode, format: format)
                break
            }
            
            switch index {
            case 0: engine.connect(audioPlayer, to: nodes[index], format: format)
            case nodes.count - 1:
                engine.connect(nodes[index - 1], to: nodes[index], format: format)
                engine.connect(nodes[index], to: engine.mainMixerNode, format: format)
            default: engine.connect(nodes[index - 1], to: nodes[index], format: format)
            }
        }
        
        isPlaying = false
        
        save()
    }
    
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        scheduleBuffer()
        
        try? engine.start()
        audioPlayer.play()
        isPlaying = true
    }
    
    func pause() {
        audioPlayer.stop()
        engine.stop()
        isPlaying = false
    }
    
    func clearBank(_ bank: Bank) {
        effectBanks.removeAll(where: { $0.id == bank.id })
        
        if let index = effectBanks.firstIndex(where: { $0.effect == nil }) {
            effectBanks.insert(Bank(editor: self), at: index)
        } else {
            effectBanks.append(Bank(editor: self))
        }
        
        connectNodes()
    }
    
    func scheduleBuffer() {
        guard let buffer = buffer else { return }

        audioPlayer.scheduleBuffer(buffer, at: nil, options: playbackOptions, completionHandler: {
            DispatchQueue.main.async {
                withAnimation {
                    self.isPlaying = false
                }
            }
        })
    }
    
    func render() async -> URL? {
        guard let file = file else { return nil }
        let format = file.processingFormat
        
        pause()
        
        scheduleBuffer()
        
        let maxFrames: AVAudioFrameCount = 4096
        
        do {
            try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: maxFrames)
        } catch {
            fatalError("Enabling manual rendering mode failed: \(error).")
        }
        
        do {
            try engine.start()
            audioPlayer.play()
        } catch {
            fatalError("Unable to start audio engine: \(error).")
        }
        
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat, frameCapacity: engine.manualRenderingMaximumFrameCount)!
        let outputFile: AVAudioFile
        
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentsURL.appendingPathComponent("\(file.url.deletingPathExtension().lastPathComponent)-processed.m4a")
            outputFile = try AVAudioFile(forWriting: outputURL, settings: file.fileFormat.settings)
        } catch {
            fatalError("Unable to open output audio file: \(error).")
        }
        
        while engine.manualRenderingSampleTime < file.length {
            do {
                let frameCount = file.length - engine.manualRenderingSampleTime
                let framesToRender = min(AVAudioFrameCount(frameCount), outputBuffer.frameCapacity)
                
                let status = try engine.renderOffline(framesToRender, to: outputBuffer)
                
                switch status {
                case .success: try outputFile.write(from: outputBuffer)
                case .insufficientDataFromInputNode: break
                case .cannotDoInCurrentContext: break
                case .error: fatalError("The manual rendering failed.")
                @unknown default: fatalError("Unknown error")
                }
            } catch {
                fatalError("The manual rendering failed: \(error).")
            }
        }

        audioPlayer.stop()
        engine.stop()
        engine.disableManualRenderingMode()
        
        return outputFile.url
    }
}

extension AVAudioFile{
    var duration: TimeInterval{
        let sampleRateSong = Double(processingFormat.sampleRate)
        let lengthSongSeconds = Double(length) / sampleRateSong
        return lengthSongSeconds
    }
}
