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
    override func canAsynchronouslyWrite (to url: URL,
                                          ofType typeName: String,
                                          for saveOperation: NSDocument.SaveOperationType) -> Bool {
        return true
    }
    
    // This enables asynchronous reading.
    override class func canConcurrentlyReadDocuments (ofType: String) -> Bool {
        return ofType == "public.plain-text"
    }
    
    override func makeWindowControllers() {
//        print(self.fileType)
//        print(self.fileURL)
       
        let logsManager = LogsManager(url: self.fileURL)
        let store = LogsStore()
        let presenter = LogsPresenter(delegate: store, logsManager: logsManager)
        let contentView = LogsView(store: store, presenter: presenter)
        NSToolbar.taskListToolbar.delegate = self
        // Create the window and set the content view.
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView, .unifiedTitleAndToolbar],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.setFrameAutosaveName("Logs Ninja")
        window.toolbar = .taskListToolbar
        window.contentView = NSHostingView(rootView: contentView)
        window.title = self.fileURL?.path ?? "No file"
//        window.titleVisibility = .hidden
        window.makeKeyAndOrderFront(nil)
        
        addWindowController(NSWindowController(window: window))
    }
    
    override func read (from data: Data, ofType typeName: String) throws {
        
    }
}
