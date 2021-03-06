import SwiftUI

struct ExitTileView: View {
    @ObservedObject var editor: QueueEditor
    
    let viewSize: CGSize
    
    var sizeMultiplier: Double {
        viewSize.width <= 873.5 && viewSize.width > viewSize.height ? 0.9 : 1.1
    }
    
    var body: some View {
        let volume = Binding(
            get: { editor.audioPlayer.volume },
            set: { editor.audioPlayer.volume = $0 }
        )
        
        return RoundedRectangle(cornerRadius: 15)
            .fill(Color.red)
            .frame(width: 220 * sizeMultiplier, height: 160 * 1.1)
            .overlay(VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Label("Exit", systemImage: "speaker.wave.3.fill")
                        .font(.largeTitle)
                    
                    Spacer()
                }
                
                Spacer()
                
                Text("Volume:")
                    .font(.headline)
                
                Slider(value: volume, in: 0...1, minimumValueLabel: Text("0%"), maximumValueLabel: Text("100%")) {
                    EmptyView()
                }
                
                Spacer()
            }.padding())
            .foregroundColor(.white)
            .padding(.trailing)
    }
}
