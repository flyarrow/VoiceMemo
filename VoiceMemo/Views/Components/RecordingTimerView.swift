import SwiftUI

struct RecordingTimerView: View {
    let duration: TimeInterval
    
    var formattedTime: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        Text(formattedTime)
            .font(.system(.title3, design: .monospaced))
            .foregroundColor(.red)
            .padding(.vertical, 8)
    }
} 