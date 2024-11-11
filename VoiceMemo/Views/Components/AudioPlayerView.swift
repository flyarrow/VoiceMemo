import SwiftUI

struct AudioPlayerView: View {
    let audioURL: URL
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        HStack {
            Button(action: {
                if audioManager.isPlaying {
                    audioManager.pausePlaying()
                } else {
                    audioManager.startPlaying(url: audioURL)
                }
            }) {
                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(audioManager.currentTime / max(audioManager.duration, 1)), height: 4)
                }
            }
            .frame(height: 4)
            
            // 时间显示
            Text(formatTime(audioManager.currentTime))
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 50)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 