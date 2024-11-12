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
        
        // 修改system prompt以生成更详细的标签说明
        let requestBody: [String: Any] = [
            "model": "Qwen/Qwen2.5-Coder-7B-Instruct",
            "messages": [
                [
                    "role": "system",
                    "content": """
                    你是一个文字润色助手，你的任务是：
                    1. 优化用户的文本，使其更加流畅、专业，同时保持原意
                    2. 为文本添加2-3个主题标签
                    3. 为每个标签提供具体的解释说明，说明为什么添加这个标签
                    
                    请按以下格式返回：
                    润色文本：
                    [这里是润色后的文本内容]
                    
                    主题标签：#标签1 #标签2 #标签3
                    
                    标签说明：
                    1. "#标签1"：[这里解释为什么使用这个标签，标签与内容的关联性]
                    2. "#标签2"：[这里解释为什么使用这个标签，标签与内容的关联性]
                    3. "#标签3"：[这里解释为什么使用这个标签，标签与内容的关联性]
                    """
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
        
        // 解析返回的文本，只获取润色后的文本内容
        if let textContent = extractPolishedText(from: polishedText) {
            print("润色成功，提取的文本内容: \(textContent)")
            return textContent
        }
        
        return polishedText
    }
    
    // 添加提取润色文本的辅助方法
    private static func extractPolishedText(from response: String) -> String? {
        let lines = response.components(separatedBy: .newlines)
        var isPolishedText = false
        var polishedText = ""
        var isTagSection = false
        var isTagExplanation = false
        
        for line in lines {
            if line.hasPrefix("润色文本：") {
                isPolishedText = true
                continue
            } else if line.hasPrefix("主题标签：") {
                isPolishedText = false
                isTagSection = true
                polishedText += "\n\n" + line + "\n"
                continue
            } else if line.hasPrefix("标签说明：") {
                isTagSection = false
                isTagExplanation = true
                polishedText += "\n" + line + "\n"
                continue
            }
            
            if isPolishedText && !line.isEmpty {
                polishedText += line + "\n"
            } else if isTagSection && !line.isEmpty {
                polishedText += line + "\n"
            } else if isTagExplanation && !line.isEmpty {
                polishedText += line + "\n"
            }
        }
        
        return polishedText.trimmingCharacters(in: .whitespacesAndNewlines)
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