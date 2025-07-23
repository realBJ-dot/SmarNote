//
//  SmarNoteApp.swift
//  SmarNote
//
//  Created by 金培元 on 7/13/25.
//

import SwiftUI

@main
struct SmarNoteApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SharedDataManager.shared)
        }
    }
}
