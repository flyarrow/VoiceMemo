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
    @State private var transcriptionError: String?
    @State private var polishError: String?
    
    @EnvironmentObject var memoStore: MemoStore
    
    @State private var showSaveSuccess = false
    
    var body: some View {
        ZStack {
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
                            Task {
                                await startTranscribing()
                            }
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
                        
                        // 如果有错误，显示错误信息
                        if let error = transcriptionError {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    
                    // 转写文本显示区域
                    if showTranscription {
                        TranscriptionView(text: transcribedText)
                            .transition(.opacity)
                        
                        // 润色按钮
                        Button(action: {
                            Task {
                                await startPolishing()
                            }
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
                        
                        // 如果有错误，显示错误信息
                        if let error = polishError {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    
                    // 润色后文本显示区域
                    if showPolishedText {
                        PolishedTextView(text: polishedText)
                            .transition(.opacity)
                        
                        Button(action: {
                            saveToHistory()
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
            
            // 添加保存成功提示
            if showSaveSuccess {
                VStack {
                    Text("已保存至历史记录")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 20)
            }
        }
        .animation(.easeInOut, value: showSaveSuccess)
    }
    
    // 模拟转写过程
    private func startTranscribing() async {
        guard let audioURL = audioURL else { return }
        
        isTranscribing = true
        transcriptionError = nil
        
        do {
            let text = try await TranscriptionService.transcribeAudio(fileURL: audioURL)
            await MainActor.run {
                transcribedText = text
                showTranscription = true
                isTranscribing = false
                transcriptionCompleted = true
            }
        } catch {
            await MainActor.run {
                transcriptionError = "转写失败: \(error.localizedDescription)"
                isTranscribing = false
            }
            print("转写错误: \(error)")
        }
    }
    
    // 模拟润色过程
    private func startPolishing() async {
        guard !transcribedText.isEmpty else { return }
        
        isPolishing = true
        polishError = nil
        
        do {
            let polished = try await TextPolishService.polishText(transcribedText)
            await MainActor.run {
                polishedText = polished
                showPolishedText = true
                isPolishing = false
                polishingCompleted = true
            }
        } catch {
            await MainActor.run {
                polishError = "润色失败: \(error.localizedDescription)"
                isPolishing = false
            }
            print("润色错误: \(error)")
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
    
    private func saveToHistory() {
        guard let audioURL = audioURL,
              !transcribedText.isEmpty,
              !polishedText.isEmpty else {
            return
        }
        
        // 保存到MemoStore
        memoStore.addMemo(audioURL: audioURL,
                         transcribedText: transcribedText,
                         polishedText: polishedText)
        
        // 显示保存成功提示
        showSaveSuccess = true
        
        // 3秒后自动隐藏提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showSaveSuccess = false
            }
        }
        
        // 重置状态
        resetStates()
    }
}

#Preview {
    RecordingView(tabSelection: .constant(0))
} 