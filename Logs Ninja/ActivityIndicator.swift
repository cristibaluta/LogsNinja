//
//  ActivityIndicator.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 01/05/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import SwiftUI
import AppKit

struct ProgressIndicator: NSViewRepresentable {

    @State var isAnimating: Bool
    
    func makeNSView(context: NSViewRepresentableContext<ProgressIndicator>) -> NSProgressIndicator {
        let view = NSProgressIndicator()
        view.style = .spinning
//        view.minValue = 0
//        view.maxValue = 100
//        view.doubleValue = 70
//        view.isIndeterminate = false
        return view
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ProgressIndicator>) {
//        isAnimating ? nsView.startAnimation(nil) : nsView.stopAnimation(nil)
//        nsView.isHidden = !isAnimating
    }
}
