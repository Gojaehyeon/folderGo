//
//  folderGoApp.swift
//  folderGo
//
//  Created by Gojaehyun on 6/25/25.
//

import SwiftUI

@main
struct folderGoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 900, height: 700))
            window.minSize = NSSize(width: 600, height: 500)
        }
    }
}
