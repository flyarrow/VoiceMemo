import Foundation

struct MemoRecord: Identifiable {
    let id = UUID()
    let audioURL: URL
    let transcribedText: String
    let polishedText: String
    let createdAt: Date
    
    // 格式化日期
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: createdAt)
    }
} 