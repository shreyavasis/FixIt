//
//  FixItLocalApp.swift
//  FixItLocal
//
//  Created by Shreya Vasisht on 10/24/26.
//

import SwiftUI
import SwiftData

@main
struct FixItLocalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Report.self)
    }
}
