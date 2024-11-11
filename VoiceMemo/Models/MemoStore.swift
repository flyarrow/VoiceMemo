import Foundation

class MemoStore: ObservableObject {
    @Published private(set) var memos: [MemoRecord] = []
    private let saveKey = "SavedMemos"
    
    init() {
        loadMemos()
    }
    
    func addMemo(audioURL: URL, transcribedText: String, polishedText: String) {
        let fileName = "\(UUID().uuidString).wav"
        let newAudioURL = getRecordingsDirectory().appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: audioURL, to: newAudioURL)
            print("Audio file copied to: \(newAudioURL.path)")
            
            let newMemo = MemoRecord(
                id: UUID(),
                fileName: fileName,
                transcribedText: transcribedText,
                polishedText: polishedText,
                createdAt: Date()
            )
            
            memos.insert(newMemo, at: 0)
            saveMemos()
            
        } catch {
            print("Failed to copy audio file: \(error)")
        }
    }
    
    private func getRecordingsDirectory() -> URL {
        let containerURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let recordingsDirectory = containerURL.appendingPathComponent("VoiceMemoRecordings", isDirectory: true)
        
        try? FileManager.default.createDirectory(
            at: recordingsDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        let noSyncPath = recordingsDirectory.appendingPathComponent(".nosync")
        if !FileManager.default.fileExists(atPath: noSyncPath.path) {
            try? "".write(to: noSyncPath, atomically: true, encoding: .utf8)
        }
        
        return recordingsDirectory
    }
    
    // 根据文件名获取完整的音频URL
    func getAudioURL(for fileName: String) -> URL {
        return getRecordingsDirectory().appendingPathComponent(fileName)
    }
    
    private func saveMemos() {
        do {
            let data = try JSONEncoder().encode(memos)
            let saveURL = getRecordingsDirectory().appendingPathComponent("memos.json")
            try data.write(to: saveURL)
            print("Memos saved to: \(saveURL.path)")
        } catch {
            print("Failed to save memos: \(error)")
        }
    }
    
    private func loadMemos() {
        let saveURL = getRecordingsDirectory().appendingPathComponent("memos.json")
        
        guard let data = try? Data(contentsOf: saveURL) else {
            print("No saved memos found at: \(saveURL.path)")
            return
        }
        
        do {
            let loadedMemos = try JSONDecoder().decode([MemoRecord].self, from: data)
            
            // 验证每个音频文件是否存在
            memos = loadedMemos.filter { memo in
                let audioURL = getAudioURL(for: memo.fileName)
                let exists = FileManager.default.fileExists(atPath: audioURL.path)
                if !exists {
                    print("Warning: Audio file not found at path: \(audioURL.path)")
                }
                return exists
            }
            
            print("Loaded \(memos.count) memos from: \(saveURL.path)")
            
        } catch {
            print("Failed to load memos: \(error)")
        }
    }
} 