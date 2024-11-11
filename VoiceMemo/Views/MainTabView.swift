import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecordingView(tabSelection: $selectedTab)
                .tabItem {
                    Image(systemName: "mic.circle.fill")
                    Text("录音")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("历史")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("我的")
                }
                .tag(2)
        }
    }
} 