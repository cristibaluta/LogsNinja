//
//  ContentView.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 24/04/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import SwiftUI

struct LogsView: View {
    
    @ObservedObject var store: LogsStore
    @State var query: String = UserDefaults.standard.string(forKey: "query") ?? ""
    @State var dateFormat: String = UserDefaults.standard.string(forKey: "dateFormat") ?? "yyyy-MM-dd HH:mm:ss.SSS"
    @State var keepMatches = true {
        didSet {
            print("value will change")
        }
    }
    
    var presenter: LogsPresenter
    
    init (store: LogsStore, presenter: LogsPresenter) {
        self.store = store
        self.presenter = presenter
    }
    
    var body: some View {
        return VSplitView {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Filter by multiple words separated with comma. Use && or || to add extra conditions for each log.")
                        .font(Font.system(size: 9))
                        .foregroundColor(Color.secondary)
                    TextField("eg. word1, word2 && extraword2, word3 || extraword3", text: $query, onCommit: {
                        self.presenter.filterLogs(query: self.query,
                                                  keepOnlyMatches: self.keepMatches,
                                                  dateFormat: self.dateFormat)
                    })
                    HStack(alignment: .top) {
                        Button(action: {
                            self.presenter.filterLogs(query: self.query,
                                                      keepOnlyMatches: self.keepMatches,
                                                      dateFormat: self.dateFormat)
                        }) {
                            Text("Apply filter")
                        }
                        .disabled(self.query.count == 0)

//                        Toggle(isOn: $keepMatches) {
//                            Text("Show only matches")
//                        }
//                        .onTapGesture {
//                            print("Keep matches only")
//                        }
                        CheckboxButton("Keep matches only", isOn: keepMatches) { state in
                            self.keepMatches = state
                            self.presenter.filterLogs(query: self.query,
                                                      keepOnlyMatches: self.keepMatches,
                                                      dateFormat: self.dateFormat)
                        }.padding(.top, 4)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Lines that don't begin with this date format are grouped together")
                        .font(Font.system(size: 9))
                        .foregroundColor(Color.secondary)
                    TextField("Date format", text: $dateFormat, onEditingChanged: { changed in
                        //
                    }) {
                        self.presenter.filterLogs(query: self.query,
                                                  keepOnlyMatches: self.keepMatches,
                                                  dateFormat: self.dateFormat)
                    }
                }
                .frame(width: 300)
            }
            .frame(height: 80)
            .padding()
            
            ZStack {
                ScrollViewReader { proxy in
                GeometryReader { geometry in
                    List(self.store.logs) { log in
                        LogCell(log: log)
                        .id(log.index)
                        .background(Color(self.presenter.backgroundColor(log: log)))
                        .frame(height: log.content.heightWithConstrainedWidth(geometry.size.width - 50))
                        .clipped()
                        .onTapGesture {
                            self.store.logs[log.index].isSelected.toggle()
                            self.presenter.setSelected(self.store.logs[log.index].isSelected,
                                                       originalIndex: log.originalIndex)
                        }
                        .contextMenu {
                            Button(action: {
                                self.presenter.setPasteboard(log.content)
                            }) {
                                Text("Copy text")
                            }
                            Button(action: {
                            }) {
                                Text("Copy all selected lines")
                            }
                            Button(action: {
                                proxy.scrollTo(log.index, anchor: .center)
                            }) {
                                Text("Scroll")
                            }
                            Button(action: {
                                for log in self.store.logs {
                                    if log.isSelected {
                                        self.store.logs[log.index].isSelected.toggle()
                                        self.presenter.setSelected(false, originalIndex: log.originalIndex)
                                    }
                                }
                            }) {
                                Text("Clear selected lines")
                            }
//                            Button(action: {
//                                for log in self.items {
//                                    if log.isSelected {
//                                        self.items[log.index].isSelected.toggle()
//                                        self.logsManager.selectOriginalIndex(log.originalIndex,
//                                                                       selected: false)
//                                    }
//                                }
//                            }) {
//                                Text("Open selections")
//                            }
                        }
                    }
                    .onAppear(perform: presenter.onAppear)
                }
                }
                ProgressIndicator(isAnimating: store.isAnimating)
                    .frame(width: 300)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Text("...")
//        let presenter = LogsPresenter(logsManager: logs())
//        LogsView(store: ContentStore(presenter: ))
    }
    static func logs() -> LogsManager {
        let logs = LogsManager()
//        logs.logs = [Log(content: "aaaa", index: 0, originalIndex: 0),
//        Log(content: "aaaa\nbbbbbb", index: 1, originalIndex: 1),
//        Log(content: "ccccc\nddddddd\neeeeeee", index: 2, originalIndex: 2, isSelected: true)]
        return logs
    }
}
