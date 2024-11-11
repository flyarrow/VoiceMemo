import Foundation

class TextPolishService {
    enum PolishError: Error {
        case invalidURL
        case invalidResponse
        case requestFailed(String)
    }
    
    static func polishText(_ text: String) async throws -> String {
        guard let url = URL(string: APIConfig.chatCompletionsAPIURL) else {
            throw PolishError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIConfig.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 构建请求体
        let requestBody: [String: Any] = [
            "model": "Qwen/Qwen2.5-Coder-7B-Instruct",
            "messages": [
                [
                    "role": "system",
                    "content": "你是一个文字润色助手，你的任务是优化用户的文本，使其更加流畅、专业，同时保持原意。请直接返回润色后的文本，不要添加任何解释。"
                ],
                [
                    "role": "user",
                    "content": "请润色以下文本：\n\(text)"
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 512,
            "top_p": 0.7,
            "frequency_penalty": 0.5,
            "stream": false
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        print("开始发送润色请求...")
        print("原始文本: \(text)")
        print("请求体: \(String(data: jsonData, encoding: .utf8) ?? "")")
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PolishError.invalidResponse
        }
        
        print("HTTP状态码: \(httpResponse.statusCode)")
        
        if let responseString = String(data: responseData, encoding: .utf8) {
            print("API响应: \(responseString)")
        }
        
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: responseData, encoding: .utf8) ?? "Unknown error"
            print("润色请求失败: \(errorMessage)")
            throw PolishError.requestFailed(errorMessage)
        }
        
        let result = try JSONDecoder().decode(PolishResponse.self, from: responseData)
        let polishedText = result.choices.first?.message.content ?? ""
        print("润色成功: \(polishedText)")
        return polishedText
    }
}

struct PolishResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
} 