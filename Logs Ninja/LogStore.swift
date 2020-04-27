//
//  Log.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 24/04/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import SwiftUI
import Combine

struct Log: Identifiable {
    var id = UUID()
    var content: String
    var index: Int
    var isSelected = false
}

final class LogsStore: ObservableObject {
    
    let keywords = "rest".components(separatedBy: ",")
    var lastPath = "/Users/cristi/Downloads/debug (1).log"
    var prefix = "2020"
    
    @Published var logs: [Log] = []
    let logsDidChange = PassthroughSubject<(), Never>()
    
    func loadLogs() {
        loadLogs(at: nil, filters: keywords)
    }
    
    func loadLogs(at url: URL?, filters: [String]) {
        
        let input = url?.path ?? lastPath
        lastPath = input
        
        DispatchQueue.global(qos: .background).async {
            var logs: [Log]  = []
            var index = 0
            var text = ""
//            var log = ""
            if freopen(input, "r", stdin) == nil {
                perror(input)
            }
            while let line = readLine() {
                guard filters.count > 0, filters.first != ""  else {
                    logs.append(.init(content: line, index: index))
                    index += 1
                    continue
                }
                text = line.lowercased()
                guard text.hasPrefix(self.prefix) else {
                    // This line has no prefix, it means it belongs to the previous line
                    if index < logs.count {
                        logs[index-1].content += "\n\(line)"
                    }
                    continue
                }
                for key in filters {
                    if text.contains(key.lowercased()) {
                        logs.append(.init(content: line, index: index))
                        index += 1
                        break
                    }
                }
            }
            DispatchQueue.main.async {
                self.logs = logs
                do {
                    self.logsDidChange.send()
                }
            }
        }
    }
}
