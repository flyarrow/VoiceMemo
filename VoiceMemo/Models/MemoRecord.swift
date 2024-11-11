import Foundation

struct MemoRecord: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let transcribedText: String
    let polishedText: String
    let createdAt: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: createdAt)
    }
} 