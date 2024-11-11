import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var memoStore: MemoStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                if memoStore.memos.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("暂无录音记录")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(memoStore.memos) { record in
                            NavigationLink(destination: MemoDetailView(record: record)) {
                                HistoryCard(record: record)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
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
            
            // 显示润色后的文本，限制为一行，设置文本颜色为黑色
            Text(record.polishedText)
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.system(size: 16))
                .foregroundColor(.black)
            
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
        .environmentObject(MemoStore())
} 