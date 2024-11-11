import SwiftUI

struct RecordButton: View {
    @Binding var isRecording: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red : Color.blue)
                    .frame(width: 80, height: 80)
                    .shadow(radius: 5)
                
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isRecording ? 1.2 : 1.0)
        .animation(.spring(), value: isRecording)
    }
} 