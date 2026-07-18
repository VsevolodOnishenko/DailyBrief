//
//  ContentView.swift
//  DailyBrief
//
//  Created by Vsevolod Onishchenko on 17. 7. 2026..
//

import SwiftUI

struct ContentView: View {
    private let repository: any DigestRepository

    init(repository: any DigestRepository) {
        self.repository = repository
    }

    var body: some View {
        DigestFeedView(repository: repository)
    }
}
