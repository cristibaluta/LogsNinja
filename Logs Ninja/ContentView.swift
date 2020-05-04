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
    @State var keywords: [String] = ["ActivityManager", "RestClient", "-x post"]
    @State var query: String = ""
    @State var isAnimating: Bool = true
    @State var keepMatches = true {
        didSet {
            print("wifi status will change")
        }
    }
    
    var body: some View {
        return VSplitView {
            Divider()
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    TextField("Enter filter...", text: $query, onEditingChanged: { (changed) in
                    }) {
                        self.store.filterLogs(filters: self.query.components(separatedBy: ","), keepOnlyMatches: self.keepMatches)
                    }
                    Button(action: {
                        self.isAnimating = true
                        self.store.filterLogs(filters: self.query.components(separatedBy: ","), keepOnlyMatches: self.keepMatches)
                    }) {
                        Text("Apply filter")
                    }
                    .disabled(self.query.count == 0)
                }
                
                Toggle(isOn: $keepMatches) {
                    Text("Keep only matches")
                }
                .onTapGesture {
                    print("Keep matches only")
                }
                
                // Filters list
//                ScrollView {
//                    ForEach(self.keywords.indices, id:\.self) {
//                        TextField("", text: self.$keywords[$0], onEditingChanged: { (changed) in
//                        }) {
//                            self.query  = self.keywords.joined()
//                        }
//                        .textFieldStyle(PlainTextFieldStyle())
//                        .padding(0)
//                    }
//                }
            }
            .frame(height: 80)
            .padding()
            
            ZStack {
                GeometryReader { geometry in
                    List(self.items) { log in
                        LogRow(log: log)
                            .background((log.index % 2 == 0) ? Color(red: 0.95, green: 0.95, blue: 0.95) : Color(.white))
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
//                ProgressIndicator(isAnimating: isAnimating).frame(width: 300)
            }
        }
    }
    
    func heightWithConstrainedWidth(_ width: CGFloat, text: String) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: NSString.DrawingOptions.usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12)],
                                            context: nil)
        return boundingBox.height + 8
    }
}

struct LogRow: View {
    var log: Log
    let leftColumnWidth = CGFloat(30)
    let nonHighlightedColor = Color(red: 0.8, green: 0.8, blue: 0.8)

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Text("●")
                .frame(width: self.leftColumnWidth)
                .foregroundColor(self.log.isSelected ? .red : (self.log.isHighlighted ? .gray : self.nonHighlightedColor))
                
                Text(self.log.content)
                .frame(width: geometry.size.width - self.leftColumnWidth, alignment: .leading)
                .font(.system(size: 12))
                    .foregroundColor(self.log.isSelected ? .red : (self.log.isHighlighted ? .black : self.nonHighlightedColor))
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
