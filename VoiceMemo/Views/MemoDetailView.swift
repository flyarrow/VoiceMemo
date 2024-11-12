import SwiftUI
import UniformTypeIdentifiers

struct MemoDetailView: View {
    let record: MemoRecord
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var memoStore: MemoStore
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 音频播放器
                AudioPlayerView(audioURL: memoStore.getAudioURL(for: record.fileName))
                    .frame(height: 60)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                // 转写文本
                VStack(alignment: .leading) {
                    Text("转写文本")
                        .font(.headline)
                    
                    Text(record.transcribedText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // 润色文本
                VStack(alignment: .leading) {
                    Text("润色文本")
                        .font(.headline)
                    
                    Text(record.polishedText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // 创建时间和文件大小
                HStack {
                    Text(record.formattedDate)
                    Spacer()
                    Text(memoStore.getAudioFileSize(for: record.fileName))
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                // 操作按钮
                VStack(spacing: 12) {
                    // 分享按钮
                    Button(action: {
                        showShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("分享录音")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    
                    // 删除按钮
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("删除记录")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("返回")
                    }
                }
            }
        }
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                memoStore.deleteMemo(record)
                dismiss()
            }
        } message: {
            Text("确定要删除这条录音记录吗？此操作不可恢复。")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [
                // 创建一个包含音频和文本信息的字符串
                """
                录音文本：
                \(record.polishedText)
                
                录制时间：\(record.formattedDate)
                """,
                try! Data(contentsOf: memoStore.getAudioURL(for: record.fileName))
            ])
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // 创建临时文件
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("shared_audio.wav")
        if let audioData = items.last as? Data {
            try? audioData.write(to: tempURL)
        }
        
        let activityItems: [Any] = [
            items.first as Any, // 文本内容
            tempURL  // 音频文件
        ]
        
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // 清理临时文件
        controller.completionWithItemsHandler = { _, _, _, _ in
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 