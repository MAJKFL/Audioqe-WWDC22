import SwiftUI

enum HelpWindowSetting: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case reverb
    case distortion
    case delay
    case equalizer
    
    var title: String {
        switch self {
        case .reverb:
            return "Reverb"
        case .distortion:
            return "Distortion"
        case .delay:
            return "Delay"
        case .equalizer:
            return "Equalizer"
        }
    }
    
    var detailedView: some View {
        switch self {
        case .reverb:
            return Text("""
        A **reverb** simulates the acoustic characteristics of a particular environment. Use the different **presets** to simulate a particular space and blend it in with the original signal using the **wet dry mix** setting.

        - **Preset** -  The preset that applies reverb to the signal
        - **Wet dry mix** - The blend of the wet and dry signals

        Source: [developer.apple.com](https://developer.apple.com/documentation/avfaudio/avaudiounitreverb)
        """)
        case .distortion:
            return Text("""
        A **distortion** alternates the original shape of a signal. Use different **presets** to simulate a particular distortion, adjust **pre gain** and blend it in with the original signal using the **wet dry mix** setting.

        - **Preset** - The preset that applies distortion to the signal
        - **Pre gain** - The gain that the audio unit applies to the signal before distortion, in decibels
        - **Wet dry mix** - The blend of the distorted and dry signals

        Source: [developer.apple.com](https://developer.apple.com/documentation/avfaudio/avaudiounitdistortion)
        """)
        case .delay:
            return Text("""
        A **delay** delays the input signal by the specified time interval and then blends it with the input signal. You can also control the amount of high-frequency roll-off to simulate the effect of a tape delay.

        - **Feedback** - The amount of the output signal that feeds back into the delay line
        - **Delay time** - The time for the input signal to reach the output
        - **Low pass cutoff** - The cutoff frequency above which high frequency content rolls off, in hertz
        - **Wet dry mix** - The blend of the wet and dry signals

        Source: [developer.apple.com](https://developer.apple.com/documentation/avfaudio/avaudiounitdelay)
        """)
        case .equalizer:
            return Text("""
        An **equaliser** adjusts the volume of different frequency bands within an audio signal. Use different **filters**, adjust its **bandwidth**, **frequency** and **gain**. Not all settings are available for every filter.

        - **Filter** - The equalizer filter type
        - **Bandwidth** - The bandwidth of the equalizer filter, in octaves
        - **Frequency** - The frequency of the equalizer filter, in hertz
        - **Gain** - The gain of the equalizer filter, in decibels

        Source: [developer.apple.com](https://developer.apple.com/documentation/avfaudio/avaudiouniteq)
        """)
        }
    }
}
