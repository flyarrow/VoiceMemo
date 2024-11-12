import SwiftUI

struct WaveformView: View {
    @ObservedObject var audioManager: AudioManager
    private let numberOfBars = 30
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<numberOfBars, id: \.self) { index in
                WaveformBar(volume: audioManager.currentVolume)
            }
        }
        .frame(height: 100)
        .padding(.vertical, 20)
    }
}

struct WaveformBar: View {
    let volume: Float
    @State private var height: CGFloat = 5
    
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.blue)
            .frame(width: 3, height: height)
            .onAppear {
                height = CGFloat.random(in: 5...15)
            }
            .onChange(of: volume) { newValue in
                withAnimation(.spring(dampingFraction: 0.5, blendDuration: 0.1)) {
                    let baseHeight: CGFloat = 5
                    let maxHeight: CGFloat = 80
                    let randomFactor = CGFloat.random(in: 0.8...1.2)
                    height = baseHeight + (maxHeight - baseHeight) * CGFloat(newValue) * randomFactor
                }
            }
    }
} 