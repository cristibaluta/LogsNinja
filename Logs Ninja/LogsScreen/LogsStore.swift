//
//  ContentState.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 20/11/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import SwiftUI
import Combine

//typealias Signal = PassthroughSubject<(), Never>

final class LogsStore: ObservableObject {
    
//    let logsDidChange = Signal()
    @Published var logs: [Log] = []
    @Published var isAnimating = false
}

extension LogsStore: LogsViewProtocol {
    
    func showLogs(_ logs: [Log]) {
        self.logs = logs
    }
    
    func showProgress(_ show: Bool) {
        print("show progress \(show)")
        self.isAnimating = show
    }
}


struct ContentStore_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
