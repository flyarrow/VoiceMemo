//
//  ContentView.swift
//  VoiceMemo
//
//  Created by XIAO HAN CHEN on 2024/11/11.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var memoStore = MemoStore()
    
    var body: some View {
        MainTabView()
            .environmentObject(memoStore)
    }
}

#Preview {
    ContentView()
}
