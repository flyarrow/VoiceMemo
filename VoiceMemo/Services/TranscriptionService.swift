import Foundation

class TranscriptionService {
    enum TranscriptionError: Error {
        case invalidURL
        case invalidResponse
        case requestFailed(String)
        case invalidAudioFile
    }
    
    static func transcribeAudio(fileURL: URL) async throws -> String {
        // 检查音频文件是否存在且可读
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let audioData = try? Data(contentsOf: fileURL) else {
            print("音频文件不存在或无法读取")
            throw TranscriptionError.invalidAudioFile
        }
        
        print("音频文件大小: \(audioData.count) bytes")
        
        guard let apiURL = URL(string: APIConfig.transcriptionAPIURL) else {
            throw TranscriptionError.invalidURL
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIConfig.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 准备multipart表单数据
        var data = Data()
        
        // 添加音频文件
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"recording.wav\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        data.append(audioData)
        data.append("\r\n".data(using: .utf8)!)
        
        // 添加模型参数
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        data.append("FunAudioLLM/SenseVoiceSmall\r\n".data(using: .utf8)!)
        
        // 添加语言参数
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
        data.append("zh\r\n".data(using: .utf8)!)
        
        // 添加采样率参数
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"sample_rate\"\r\n\r\n".data(using: .utf8)!)
        data.append("16000\r\n".data(using: .utf8)!)
        
        // 结束标记
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        
        print("开始发送转录请求...")
        print("请求URL: \(apiURL.absoluteString)")
        print("Authorization: Bearer \(APIConfig.apiKey)")
        print("Content-Type: multipart/form-data; boundary=\(boundary)")
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TranscriptionError.invalidResponse
        }
        
        print("HTTP状态码: \(httpResponse.statusCode)")
        
        if let responseString = String(data: responseData, encoding: .utf8) {
            print("API响应: \(responseString)")
        }
        
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: responseData, encoding: .utf8) ?? "Unknown error"
            print("转录请求失败: \(errorMessage)")
            throw TranscriptionError.requestFailed(errorMessage)
        }
        
        let result = try JSONDecoder().decode(TranscriptionResponse.self, from: responseData)
        print("转录成功: \(result.text)")
        return result.text
    }
}

struct TranscriptionResponse: Codable {
    let text: String
} 