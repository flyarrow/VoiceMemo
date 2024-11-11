import SwiftUI

struct TranscriptionView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("转写文本")
                .font(.headline)
            
            Text(text.isEmpty ? "等待转写..." : text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
} 