//
//  Log.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 24/04/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import SwiftUI
import Combine

typealias Signal = PassthroughSubject<(), Never>

struct Log: Identifiable {
    var id = UUID()
    var content: String
    var index: Int
    var originalIndex: Int
    var isSelected = false
    var isHighlighted = true
}

final class LogsStore: ObservableObject {
    
    var keywords = [String]()
    var lastPath = ""
    var prefixes = ["2020", "2019"]
    private let queue = DispatchQueue(label: "filter", qos: .background)
    
    @Published var logs: [Log] = []
    var originalLogs = [String]()
    var originalLogsSelected = [Int]()
    let logsDidChange = Signal()
    
    init(url: URL? = nil) {
        lastPath = url?.path ?? ""
        originalLogsSelected = UserDefaults.standard.object(forKey: "selectedLines-\(lastPath)") as? [Int] ?? []
        print(originalLogsSelected)
    }
    
    func loadLogs() {
        loadLogs(at: nil, filters: "ActivityManager&&activityuploadmanager&&308806323998189&&308806323998190".components(separatedBy: "&&"))
    }
    
    func loadLogs(at url: URL?, filters: [String]) {
        print("Filter logs filters:\(filters)  keywords:\(keywords)")
        guard filters != keywords else {
            return
        }
        keywords = filters
        let input = url?.path ?? lastPath
        lastPath = input
        
        DispatchQueue.global(qos: .background).async {
            self.originalLogs = []
            let startDate = Date()
                    
            if freopen(input, "r", stdin) == nil {
                perror(input)
            }
            while let line = readLine() {
                self.originalLogs.append(line)
            }
            print("Read logs in \(Date().timeIntervalSince(startDate)) sec")
            
            self.filterLogs(filters: filters)
        }
    }
    
    func filterLogs(filters: [String], keepOnlyMatches: Bool = true) {
        
        queue.async {
            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.main.async {
                self.logs = []
                self.logsDidChange.send()
                semaphore.signal()
            }
            semaphore.wait()
            
            var logs: [Log]  = []
            var lines = [String]()
            var index = 0
            var originalIndex = -1
            var lineLowercased = ""
            let startDate = Date()
            
            for line in self.originalLogs + [""] {
                originalIndex += 1
                lineLowercased = line.lowercased()
                var hasPrefix = false
                for prefix in self.prefixes {
                    if lineLowercased.hasPrefix(prefix) {
                        hasPrefix = true
                        break
                    }
                }
                guard hasPrefix else {
                    // This line has no prefix, it means it belongs to the previous line
                    lines.append(line)
                    continue
                }
                // We have a line or multiline text ready, check if meets any search criteria
                if lines.count > 0 {
                    if filters.count > 0 && filters.first != "" {
                        let text = lines.joined(separator: "\n").lowercased()
                        var matched = false
                        for key in filters {
                            if text.contains(key.lowercased()) {
                                matched = true
                                break
                            }
                        }
                        if matched {
                            logs.append(.init(content: lines.joined(separator: "\n"),
                                              index: index,
                                              originalIndex: originalIndex,
                                              isSelected: self.originalLogsSelected.contains(originalIndex),
                                              isHighlighted: true))
                            index += 1
                        } else if !keepOnlyMatches {
                            // Add unmatched lines unhighlighted
                            logs.append(.init(content: lines.joined(separator: "\n"),
                                              index: index,
                                              originalIndex: originalIndex,
                                              isSelected: self.originalLogsSelected.contains(originalIndex),
                                              isHighlighted:  false))
                            index += 1
                        }
                    } else {
                        logs.append(.init(content: lines.joined(separator: "\n"),
                                          index: index,
                                          originalIndex: originalIndex,
                                          isSelected: self.originalLogsSelected.contains(originalIndex),
                                          isHighlighted: true))
                        index += 1
                    }
                    lines = []
                }
                // Store the current line for next iteration use
                lines = [line]
            }
            print("Filtering logs by keywords \(filters) in \(Date().timeIntervalSince(startDate)) sec")
            DispatchQueue.main.async {
                self.logs = logs
                do {
                    self.logsDidChange.send()
                }
            }
        }
    }
    
    func selectOriginalIndex(_ index: Int, selected: Bool) {
        let originalIndex = logs[index].originalIndex
        if selected {
            originalLogsSelected.append(originalIndex)
        } else {
            originalLogsSelected.removeAll(where: {$0 == originalIndex})
        }
        UserDefaults.standard.set(originalLogsSelected, forKey: "selectedLines-\(lastPath)")
        UserDefaults.standard.synchronize()
        print(originalLogsSelected)
    }
    
    func isOriginalIndexSelected (_ index: Int) -> Bool {
        return originalLogsSelected.contains(index)
    }
}
