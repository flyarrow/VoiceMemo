import Foundation

struct MemoRecord: Identifiable, Codable {
    let id: UUID
    let audioURL: URL
    let transcribedText: String
    let polishedText: String
    let createdAt: Date
    
    init(audioURL: URL, transcribedText: String, polishedText: String) {
        self.id = UUID()
        self.audioURL = audioURL
        self.transcribedText = transcribedText
        self.polishedText = polishedText
        self.createdAt = Date()
    }
    
    // 用于格式化显示时间
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: createdAt)
    }
} 