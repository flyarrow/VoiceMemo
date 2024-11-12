import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let audioURL: URL
    @StateObject private var audioManager = AudioManager()
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: TimeInterval = 0
    
    var body: some View {
        HStack {
            Button(action: {
                if isPlaying {
                    audioManager.pausePlaying()
                } else {
                    audioManager.startPlaying(url: audioURL)
                }
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
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
            
            // 显示剩余时间
            Text(formatTime(isPlaying ? audioManager.remainingTime : audioManager.duration))
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 50)
        }
        .onAppear {
            setupAudioPlayer()
            // 加载音频时获取时长
            audioManager.loadAudioDuration(from: audioURL)
        }
        .onReceive(audioManager.$currentTime) { _ in
            // 进度更新使用currentTime/duration的比例
            progress = audioManager.currentTime / max(audioManager.duration, 1)
        }
        .onReceive(audioManager.$isPlaying) { playing in
            isPlaying = playing
        }
    }
    
    private func setupAudioPlayer() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 