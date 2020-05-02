//
//  ContentView.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 24/04/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var store: LogsStore
    @State var items: [Log] = []
    @State var query: String = ""
    @State var isAnimating: Bool = true
    
    var body: some View {
        return VSplitView {
            Divider()
            HStack(alignment: .top) {
                Button(action: {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = true
                    panel.canChooseDirectories = false
                    panel.allowsMultipleSelection = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let result = panel.runModal()
                        if result == .OK, let url = panel.url {
                            self.isAnimating = true
                            self.store.loadLogs(at: url, filters: self.query.components(separatedBy: ","))
                        }
                    }
                }) {
                    Text("Browse")
                }
                TextField("Enter filter...", text: $query, onEditingChanged: { (changed) in
                }) {
                    self.store.filterLogs(filters: self.query.components(separatedBy: ","))
                }
                Button(action: {
                    self.isAnimating = true
                    self.store.filterLogs(filters: self.query.components(separatedBy: ","))
                }) {
                    Text("Apply filter")
                }
                .disabled(self.query.count == 0)
                
                AttributedText {
                    LineBreak()
                        .lineSpacing(20)
                    AText("Hello SwiftUI")
                        .backgroundColor(.red)
                        .baselineOffset(10)
                        .font(.systemFont(ofSize: 20))
                        .foregroundColor(.yellow)
                        .expansion(1)
                        .kerning(3)
                        .ligature(.none)
                        .obliqueness(0.5)
                        .shadow(color: .black, radius: 10, x: 4, y: 4)
                        .strikethrough(style: .patternDash, color: .black)
                        .stroke(width: -2, color: .green)
                        .underline(.patternDashDotDot, color: .cyan)
                    LineBreak()
                    AText(" with fun")
                        .paragraphSpacing(10, before: 60)
                        .alignment(.right)
                }
            }
            .frame(height: 50)
            .padding()
            
            ZStack {
                GeometryReader { geometry in
                    List(self.items) { log in
                        LogRow(log: log)
                            .background((log.index % 2 == 0) ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color(.white))
                            //                        .frame(minWidth: 100, minHeight: 30)
                            .frame(height: self.heightWithConstrainedWidth(geometry.size.width - 50, text: log.content))
                            .clipped()
                            .onTapGesture {
                                self.items[log.index].isSelected.toggle()
                        }
                    }
                    .onAppear(perform: {
                        self.items = self.store.logs
                        self.isAnimating = false
                    })
                    .onReceive(self.store.logsDidChange, perform: { _ in
                        self.items = self.store.logs
                        self.isAnimating = false
                    })
                }
                ProgressIndicator(isAnimating: isAnimating).frame(width: 300)
            }
        }
    }
    
    func heightWithConstrainedWidth(_ width: CGFloat, text: String) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: NSString.DrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12)], context: nil)
        return boundingBox.height + 10
    }
}

struct LogRow: View {
    var log: Log
    let leftColumnWidth = CGFloat(30)

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Text("●")
                .frame(width: self.leftColumnWidth)
                .foregroundColor(self.log.isSelected ? .red : .gray)
                
                Text(self.log.content)
                .frame(width: geometry.size.width - self.leftColumnWidth, alignment: .leading)
                .font(.system(size: 12))
                .foregroundColor(self.log.isSelected ? .red : .primary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
//                .background(Color(.blue))
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: logs())
    }
    static func logs() -> LogsStore {
        let logs = LogsStore()
        logs.logs = [Log(content: "aaaa", index: 0),
        Log(content: "aaaa\nbbbbbb", index: 1),
        Log(content: "ccccc\nddddddd\neeeeeee", index: 2, isSelected: true)]
        return logs
    }
}
