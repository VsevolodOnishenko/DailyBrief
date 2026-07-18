//
//  DailyBriefApp.swift
//  DailyBrief
//
//  Created by Vsevolod Onishchenko on 17. 7. 2026..
//

import SwiftUI

@main
struct DailyBriefApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(repository: BundledDigestRepository())
        }
    }
}
