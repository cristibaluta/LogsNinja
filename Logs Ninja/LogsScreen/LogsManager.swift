//
//  Log.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 24/04/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import AppKit

struct Log: Identifiable {
    var id = UUID()
    var content: String
    var attributedString: NSAttributedString
    var index: Int
    var originalIndex: Int
    var isSelected = false
    var isHighlighted = true
}

struct Filter {
    var words: [String]
    var isPositive = true
}

final class LogsManager {
    
    var filePath: String
    var originalLogs = [String]()
    var originalLogsSelected: [Int]
    private let queue = DispatchQueue(label: "LogsManager.queue", qos: .background)
    
    init (url: URL? = nil) {
        filePath = url?.path ?? ""
        originalLogsSelected = UserDefaults.standard.object(forKey: "selectedLines-\(filePath)") as? [Int] ?? []
    }
    
    convenience init (logs: [String]) {
        self.init(url: nil)
        originalLogs = logs
    }
    
    func loadLogs (at url: URL? = nil,
                   query: String = "",
                   dateFormat: String,
                   completion: @escaping ([Log]) -> Void) {
        
        let input = url?.path ?? filePath
        filePath = input
        print("Load logs at: \(input) query:\(query)  keywords:\(query)")
        
        queue.async {
            self.originalLogs = []
            let startDate = Date()
                    
            if freopen(input, "r", stdin) == nil {
                perror(input)
            }
            while let line = readLine() {
                self.originalLogs.append(line)
            }
            print("Load logs from file in \(Date().timeIntervalSince(startDate)) sec")
            
            self.filterLogs(query: query, dateFormat: dateFormat, completion: completion)
        }
    }
    
    func filterLogs (query: String,
                     keepOnlyMatches: Bool = true,
                     dateFormat: String,
                     completion: @escaping ([Log]) -> Void) {
        
        UserDefaults.standard.set(query, forKey: "query")
        UserDefaults.standard.set(dateFormat, forKey: "dateFormat")
        UserDefaults.standard.set(keepOnlyMatches, forKey: "keepOnlyMatches")
        UserDefaults.standard.synchronize()
        
        queue.async {
            let filters = self.filters(from: query)
            var filteredLogs: [Log] = []
            var lines = [String]()// lines of a log
            var index = 0
            var originalIndex = -1
            var lineLowercased = ""
            let startDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            let allKeywords: [String] = filters.flatMap({$0.words})
            
            for line in self.originalLogs + [""] {
                originalIndex += 1
                lineLowercased = line.lowercased()
                var isStartOfLogLine = false
                if lineLowercased.hasPrefix(" ") {
                    isStartOfLogLine = false
                }
                else if dateFormat != "" && lineLowercased.count > dateFormat.count {
                    let range = lineLowercased.startIndex..<dateFormat.endIndex
                    let dateString = String(lineLowercased[range])
                    if dateFormatter.date(from: dateString) != nil {
                        isStartOfLogLine = true
                    }
                } else {
                    isStartOfLogLine = true
                }
                guard isStartOfLogLine else {
                    // This line has no date prefix, it means it belongs to the previous line
                    lines.append(line)
                    continue
                }
                // We have a line or multiline text ready, check if meets any search criteria
                if lines.count > 0 {
                    if filters.count > 0 && filters.first?.words.first != "" {
                        let text = lines.joined(separator: "\n").lowercased()
                        // Check for matches based on the words and operator
                        var lineMatched = false
                        for filter in filters {
                            var keywordsMatched = 0// How many keywords matched
                            for keyword in filter.words {
                                if text.contains(keyword.lowercased()) {
                                    keywordsMatched += 1
                                }
                            }
                            if filter.isPositive {
                                // All keywords require a match
                                lineMatched = keywordsMatched == filter.words.count
                            } else {
                                // At lest one keyword require a match
                                lineMatched = keywordsMatched > 0
                            }
                            if lineMatched {
                                break
                            }
                        }
                        // End filter
                        let string = lines.joined(separator: "\n")
                        if lineMatched {
                            filteredLogs.append(Log(content: string,
                                                    attributedString: self.buildAttributedString(string: string, keywords: allKeywords),
                                                    index: index,
                                                    originalIndex: originalIndex,
                                                    isSelected: self.originalLogsSelected.contains(originalIndex),
                                                    isHighlighted: true))
                            index += 1
                        }
                        else if !keepOnlyMatches {
                            // Add unmatched lines unhighlighted
                            filteredLogs.append(Log(content: string,
                                                    attributedString: NSAttributedString(string: string),
                                                    index: index,
                                                    originalIndex: originalIndex,
                                                    isSelected: self.originalLogsSelected.contains(originalIndex),
                                                    isHighlighted:  false))
                            index += 1
                        }
                    } else {
                        let string = lines.joined(separator: "\n")
                        filteredLogs.append(Log(content: string,
                                                attributedString: self.buildAttributedString(string: string, keywords: allKeywords),
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
            print("Filtered logs with query '\(query)' in \(Date().timeIntervalSince(startDate))sec lines found \(filteredLogs.count) from \(lines.count)")
            
            DispatchQueue.main.async {
                completion(filteredLogs)
            }
        }
    }
    
    func selectOriginalIndex (_ originalIndex: Int, selected: Bool) {
        if selected {
            originalLogsSelected.append(originalIndex)
        } else {
            originalLogsSelected.removeAll(where: {$0 == originalIndex})
        }
        UserDefaults.standard.set(originalLogsSelected, forKey: "selectedLines-\(filePath)")
        UserDefaults.standard.synchronize()
        print(originalLogsSelected)
    }
    
    func isOriginalIndexSelected (_ index: Int) -> Bool {
        return originalLogsSelected.contains(index)
    }
    
    private func buildAttributedString (string: String, keywords: [String]) -> NSAttributedString {
        let fullRange: NSRange = NSMakeRange(0, string.count)
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes([NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12)], range: fullRange)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: NSColor.black], range: fullRange)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: fullRange)

        for keyword in keywords {
            guard keyword != "" else {
                continue
            }
            let ranges = string.ranges(of: keyword)
            for range in ranges {
                let attribute = [NSAttributedString.Key.backgroundColor: NSColor(named: "SelectedTextColor") ?? .blue]
                attributedString.addAttributes(attribute, range: range)
            }
        }
        return attributedString
    }
    
    private func filters (from query: String) -> [Filter] {
        
        let comp = query.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})

        let singles: [String] = comp.compactMap({
            return (!$0.contains("&&") && !$0.contains("||")) ? $0 : nil
        })
        let ands: [[String]] = comp.compactMap({
            let c = $0.components(separatedBy: "&&").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
            return c.count > 1 ? c : nil
        })
        let ors: [[String]] = comp.compactMap({
            let c = $0.components(separatedBy: "||").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
            return c.count > 1 ? c : nil
        })

        return singles.map({ Filter(words: [$0], isPositive: true) }) +
            ands.map({ Filter(words: $0, isPositive: true) }) +
            ors.map({ Filter(words: $0, isPositive: false) })
    }
}
