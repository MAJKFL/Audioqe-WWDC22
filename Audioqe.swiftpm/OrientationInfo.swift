//
//  File.swift
//  Audioqe
//
//  Created by Jakub Florek on 08/04/2022.
//

import SwiftUI

class OrientationInfo: ObservableObject {
    enum Orientation {
        case portrait
        case landscape
    }
    
    @Published var orientation: Orientation
    
    private var _observer: NSObjectProtocol?
    
    init() {
        if UIDevice.current.orientation.isPortrait {
            self.orientation = .portrait
        } else {
            self.orientation = .landscape
        }
        
        _observer = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [unowned self] note in
            guard let device = note.object as? UIDevice else { return }
            
            if device.orientation.isPortrait {
                self.orientation = .portrait
            } else if device.orientation.isLandscape {
                self.orientation = .landscape
            }
        }
    }
    
    deinit {
        if let observer = _observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
