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
    var isSelected = false
}

final class LogsStore: ObservableObject {
    
    let keywords = "".components(separatedBy: ",")
    var lastPath = ""
    var prefix = "2020"
    
    @Published var logs: [Log] = []
    var originalLogs = [String]()
    let logsDidChange = Signal()
    
    init(url: URL? = nil) {
        lastPath = url?.path ?? ""
    }
    
    func loadLogs() {
        loadLogs(at: nil, filters: keywords)
    }
    
    func loadLogs(at url: URL?, filters: [String]) {
        
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
    
    func filterLogs(filters: [String]) {
        
        DispatchQueue.main.async {
            self.logs = []
            do {
                self.logsDidChange.send()
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            var logs: [Log]  = []
            var lines = [String]()
            var index = 0
            var lineLowercased = ""
            let startDate = Date()
            
            for line in self.originalLogs + [""] {
                lineLowercased = line.lowercased()
                guard lineLowercased.hasPrefix(self.prefix) else {
                    // This line has no prefix, it means it belongs to the previous line
                    lines.append(line)
                    continue
                }
                // We have a line or multiline text ready,  check if meets any search criteria
                if lines.count > 0 {
                    if filters.count > 0 &&  filters.first != "" {
                        let text = lines.joined(separator: "\n").lowercased()
                        for key in filters {
                            if text.contains(key.lowercased()) {
                                logs.append(.init(content: lines.joined(separator: "\n"), index: index))
                                index += 1
                                break
                            }
                        }
                    } else {
                        logs.append(.init(content: lines.joined(separator: "\n"), index: index))
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
}
