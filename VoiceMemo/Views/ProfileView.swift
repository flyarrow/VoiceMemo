import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("设置")) {
                    NavigationLink(destination: Text("设置详情")) {
                        Label("通用设置", systemImage: "gear")
                    }
                    
                    NavigationLink(destination: Text("关于详情")) {
                        Label("关于", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("我的")
        }
    }
} 