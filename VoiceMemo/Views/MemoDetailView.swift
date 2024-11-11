import SwiftUI

struct MemoDetailView: View {
    let record: MemoRecord
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var memoStore: MemoStore
    
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
                
                // 创建时间
                Text(record.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
                
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
    }
} 