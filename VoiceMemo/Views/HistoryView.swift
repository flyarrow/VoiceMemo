import SwiftUI

struct HistoryView: View {
    @State private var memoRecords: [MemoRecord] = [
        MemoRecord(
            audioURL: URL(string: "dummy0")!,
            transcribedText: "这是最新录音的转写文本...",
            polishedText: "这是最新录音润色后的文本，刚刚添加的...",
            createdAt: Date()
        ),
        MemoRecord(
            audioURL: URL(string: "dummy1")!,
            transcribedText: "这是第一条录音的转写文本...",
            polishedText: "这是第一条录音润色后的文本...",
            createdAt: Date().addingTimeInterval(-3600)
        ),
        MemoRecord(
            audioURL: URL(string: "dummy2")!,
            transcribedText: "这是第二条录音的转写文本...",
            polishedText: "这是第二条录音润色后的文本...",
            createdAt: Date().addingTimeInterval(-7200)
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(memoRecords) { record in
                        NavigationLink(destination: MemoDetailView(record: record)) {
                            HistoryCard(record: record)
                                .opacity(record.id == memoRecords[0].id ? 1 : 0.8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("历史记录")
        }
    }
}

struct HistoryCard: View {
    let record: MemoRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 音频播放器
            AudioPlayerView(audioURL: record.audioURL)
                .frame(height: 40)
            
            // 预览文本（显示润色后的文本前30个字符）
            Text(record.polishedText.prefix(30) + "...")
                .lineLimit(2)
                .font(.body)
            
            // 时间戳
            Text(record.formattedDate)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    HistoryView()
} 