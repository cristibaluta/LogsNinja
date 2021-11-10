//
//  ContentPresenter.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 20/11/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import AppKit

protocol LogsViewProtocol {
    func showLogs (_ logs: [Log])
    func showProgress (_ show: Bool)
}

class LogsPresenter {
    
    var delegate: LogsViewProtocol
    let logsManager: LogsManager
    private var queryString: String
    private var lastQueryInThisSession: String?
    private var dateFormat: String
    
    var lastQuery: String {
        return UserDefaults.standard.string(forKey: "query") ?? ""
    }
    
    init (delegate: LogsViewProtocol, logsManager: LogsManager) {
        self.delegate = delegate
        self.logsManager = logsManager
        self.queryString = UserDefaults.standard.string(forKey: "query") ?? ""
        self.dateFormat = UserDefaults.standard.string(forKey: "dateFormat") ?? "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    func onAppear() {
        self.delegate.showProgress(true)
        logsManager.loadLogs(query: lastQuery, dateFormat: dateFormat, completion: { logs in
            DispatchQueue.main.async {
                self.delegate.showLogs(logs)
                self.delegate.showProgress(false)
            }
        })
    }
    
    func filterLogs (query: String, keepOnlyMatches: Bool = true, dateFormat: String) {
        print(">>>>>> Start filtering with new query:\(query), oldQuery:\(lastQueryInThisSession ?? "")")
        guard lastQueryInThisSession != query else {
            return
        }
        lastQueryInThisSession = query
        
//        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            self.delegate.showLogs([])
            self.delegate.showProgress(true)
//            semaphore.signal()
        }
//        semaphore.wait()
        
        logsManager.filterLogs(query: query,
                               keepOnlyMatches: keepOnlyMatches,
                               dateFormat: dateFormat, completion: { logs in
                                DispatchQueue.main.async {
                                    self.delegate.showLogs(logs)
                                    self.delegate.showProgress(false)
                                }
                        })
    }
    
    func setSelected (_ selected: Bool, originalIndex: Int) {
        logsManager.selectOriginalIndex(originalIndex, selected: selected)
    }
    
    func setPasteboard (_ content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(content, forType: .string)
    }
    
    func backgroundColor (log: Log) -> NSColor {
        return log.isSelected
            ? NSColor(named: "SelectedCellColor")!
            : ((log.index % 2 == 0) ? NSColor(named: "EvenCellColor")! : .clear)
    }
}
