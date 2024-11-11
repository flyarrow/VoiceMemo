import SwiftUI

struct RecordingView: View {
    @Binding var tabSelection: Int
    @StateObject private var audioManager = AudioManager()
    @State private var isRecording = false
    @State private var showTranscription = false
    @State private var showPolishedText = false
    @State private var audioURL: URL?
    @State private var transcribedText = ""
    @State private var polishedText = ""
    @State private var recordingDuration: TimeInterval = 0
    @State private var recordingTimer: Timer?
    
    // 新增状态变量
    @State private var isTranscribing = false
    @State private var isPolishing = false
    @State private var transcriptionCompleted = false
    @State private var polishingCompleted = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 录音状态显示区域
                if isRecording {
                    VStack {
                        RecordingTimerView(duration: recordingDuration)
                        WaveformView()
                    }
                    .transition(.opacity)
                }
                
                // 录音文件显示区域
                if let audioURL = audioURL {
                    AudioPlayerView(audioURL: audioURL)
                        .frame(height: 60)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .transition(.scale.combined(with: .opacity))
                    
                    // 转写按钮
                    Button(action: {
                        startTranscribing()
                    }) {
                        HStack {
                            if isTranscribing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            Image(systemName: "text.bubble")
                            Text(isTranscribing ? "正在转写..." : "转换为文字")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isTranscribing)
                    .transition(.scale)
                }
                
                // 转写文本显示区域
                if showTranscription {
                    TranscriptionView(text: transcribedText)
                        .transition(.opacity)
                    
                    // 润色按钮
                    Button(action: {
                        startPolishing()
                    }) {
                        HStack {
                            if isPolishing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            Image(systemName: "wand.and.stars")
                            Text(isPolishing ? "正在润色..." : "润色文本")
                        }
                        .padding()
                        .background(transcriptionCompleted ? Color.purple : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(!transcriptionCompleted || isPolishing)
                    .transition(.scale)
                }
                
                // 润色后文本显示区域
                if showPolishedText {
                    PolishedTextView(text: polishedText)
                        .transition(.opacity)
                    
                    // 保存按钮
                    Button(action: {
                        handleSave()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("保存")
                        }
                        .padding()
                        .background(polishingCompleted ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(!polishingCompleted)
                    .transition(.scale)
                }
                
                Spacer()
            }
            .padding()
            .animation(.spring(), value: isRecording)
            .animation(.spring(), value: showTranscription)
            .animation(.spring(), value: showPolishedText)
        }
        
        // 底部录音按钮
        .overlay(
            RecordButton(isRecording: $isRecording) {
                handleRecordingButton()
            }
            .padding(.bottom, 30),
            alignment: .bottom
        )
    }
    
    // 模拟转写过程
    private func startTranscribing() {
        isTranscribing = true
        showTranscription = true
        
        // 模拟3秒后完成转写
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            transcribedText = "这是一段示例转写文本，展示转写功能完成后的效果。"
            isTranscribing = false
            transcriptionCompleted = true
        }
    }
    
    // 模拟润色过程
    private func startPolishing() {
        isPolishing = true
        showPolishedText = true
        
        // 模拟3秒后完成润色
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            polishedText = "这是经过AI润色后的文本，更加流畅自然，没有错别字。"
            isPolishing = false
            polishingCompleted = true
        }
    }
    
    private func handleRecordingButton() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        if let url = audioManager.startRecording() {
            // 清除之前的录音URL
            audioURL = nil
            isRecording = true
            recordingDuration = 0
            resetStates()
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                recordingDuration += 1
            }
        }
    }
    
    private func stopRecording() {
        audioManager.stopRecording()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // 获取录音文件的URL
        if let recorder = audioManager.audioRecorder {
            audioURL = recorder.url
            print("Recording saved to: \(recorder.url.path)") // 添加调试信息
        }
    }
    
    private func resetStates() {
        showTranscription = false
        showPolishedText = false
        transcribedText = ""
        polishedText = ""
        isTranscribing = false
        isPolishing = false
        transcriptionCompleted = false
        polishingCompleted = false
        audioURL = nil
    }
    
    private func handleSave() {
        // 重置所有状态
        resetStates()
        // 切换到历史标签页
        tabSelection = 1
    }
}

#Preview {
    RecordingView(tabSelection: .constant(0))
} 