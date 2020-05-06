//
//  AppDelegate.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 24/04/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let logs = LogsStore(url: URL(fileURLWithPath: "/Users/cristi/Downloads/debug 5.log"))
        let contentView = ContentView(store: logs)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.setFrameAutosaveName("Logs Ninja")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
        logs.loadLogs()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        print(sender)
        return true
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        print(urls)
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        return true
    }
}

