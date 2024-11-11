import SwiftUI

struct WaveformView: View {
    @State private var waveform: [CGFloat] = Array(repeating: 0.2, count: 30)
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(waveform.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red)
                    .frame(width: 3, height: 20 + waveform[index] * 40)
                    .animation(.spring(dampingFraction: 0.5), value: waveform[index])
            }
        }
        .onReceive(timer) { _ in
            // 模拟音量波动
            for i in waveform.indices {
                waveform[i] = CGFloat.random(in: 0.1...1.0)
            }
        }
    }
} 