import Foundation

class MemoStore: ObservableObject {
    @Published private(set) var memos: [MemoRecord] = []
    private let saveKey = "SavedMemos"
    
    init() {
        loadMemos()
    }
    
    func addMemo(audioURL: URL, transcribedText: String, polishedText: String) {
        // 获取永久存储的音频文件URL
        let newAudioURL = getRecordingsDirectory().appendingPathComponent("\(UUID().uuidString).wav")
        
        do {
            // 复制音频文件到永久存储位置
            try FileManager.default.copyItem(at: audioURL, to: newAudioURL)
            print("Audio file copied to: \(newAudioURL.path)")
            
            // 使用永久存储的URL创建新记录
            let newMemo = MemoRecord(
                audioURL: newAudioURL,
                transcribedText: transcribedText,
                polishedText: polishedText
            )
            
            memos.insert(newMemo, at: 0)
            saveMemos()
            
        } catch {
            print("Failed to copy audio file: \(error)")
        }
    }
    
    private func getRecordingsDirectory() -> URL {
        // 直接使用应用支持目录
        let containerURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let recordingsDirectory = containerURL.appendingPathComponent("recordings", isDirectory: true)
        
        // 确保recordings目录存在
        try? FileManager.default.createDirectory(
            at: recordingsDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return recordingsDirectory
    }
    
    private func saveMemos() {
        do {
            let data = try JSONEncoder().encode(memos)
            // 将数据保存到应用支持目录而不是UserDefaults
            let saveURL = getRecordingsDirectory().appendingPathComponent("memos.json")
            try data.write(to: saveURL)
        } catch {
            print("Failed to save memos: \(error)")
        }
    }
    
    private func loadMemos() {
        let saveURL = getRecordingsDirectory().appendingPathComponent("memos.json")
        
        guard let data = try? Data(contentsOf: saveURL) else {
            print("No saved memos found")
            return
        }
        
        do {
            let loadedMemos = try JSONDecoder().decode([MemoRecord].self, from: data)
            
            // 验证每个音频文件是否存在
            memos = loadedMemos.filter { memo in
                let exists = FileManager.default.fileExists(atPath: memo.audioURL.path)
                if !exists {
                    print("Warning: Audio file not found at path: \(memo.audioURL.path)")
                }
                return exists
            }
            
        } catch {
            print("Failed to load memos: \(error)")
        }
    }
} 