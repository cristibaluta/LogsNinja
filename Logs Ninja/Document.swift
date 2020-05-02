/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The NSDocument subclass for reading and writing plain text files.
*/
import Foundation
import Cocoa
import SwiftUI

class Document: NSDocument {
    
    override class var autosavesInPlace: Bool {
        return false
    }
    override func canAsynchronouslyWrite(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) -> Bool {
        return true
    }
    
    // This enables asynchronous reading.
    override class func canConcurrentlyReadDocuments(ofType: String) -> Bool {
        return ofType == "public.plain-text"
    }
    
    override func makeWindowControllers() {
//        print(self.fileType)
//        print(self.fileURL)
       
        let logs = LogsStore(url: self.fileURL)
        let contentView = ContentView(store: logs)

        // Create the window and set the content view.
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.setFrameAutosaveName("Logs Ninja")
        window.contentView = NSHostingView(rootView: contentView)
        window.title = self.fileURL?.path ?? "No file"
        window.makeKeyAndOrderFront(nil)
        
        addWindowController(NSWindowController(window: window))
        
        logs.loadLogs()
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        
    }
}
