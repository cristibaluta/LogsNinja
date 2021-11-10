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

    var isAnimating: Bool
    
    func makeNSView(context: NSViewRepresentableContext<Self>) -> NSProgressIndicator {
        let view = NSProgressIndicator()
        view.style = .spinning
        view.isDisplayedWhenStopped = false
        return view
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<Self>) {
        isAnimating ? nsView.startAnimation(nil) : nsView.stopAnimation(nil)
    }
}
