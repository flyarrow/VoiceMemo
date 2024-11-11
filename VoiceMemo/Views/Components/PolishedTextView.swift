import SwiftUI

struct PolishedTextView: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("润色后文本")
                .font(.headline)
            
            Text(text.isEmpty ? "等待润色..." : text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
        }
    }
} 