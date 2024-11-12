import SwiftUI

struct MemoDetailView: View {
    let record: MemoRecord
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var memoStore: MemoStore
    @State private var showDeleteAlert = false
    
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
    }
} 