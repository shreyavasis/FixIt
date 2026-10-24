//
//  ContentView.swift
//  FixItLocal
//
//  Created by Shreya Vasisht on 10/24/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView{
            NavigationStack{
                VStack(spacing: 16){
                    Image(systemName: "map")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    Text("Report Map")
                        .font(.title2)
                    Text("Map functionality is coming in a later iteration.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .navigationTitle("Map")
            }
            .tabItem{
                Label("Map", systemImage: "map")
            }
            NavigationStack {
                ReportListView()
            }
            .tabItem {
                Label("Reports", systemImage: "list.bullet")
            }
            NavigationStack {
                ReportFormView()
            }
            .tabItem {
                Label("New Report", systemImage: "plus.circle")
            }
        }
    }
}
#Preview {
    ContentView()
        .modelContainer(for:Report.self, inMemory: true)
}
