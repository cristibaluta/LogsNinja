//
//  CheckboxButton.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 30/11/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import SwiftUI
import AppKit

struct CheckboxButton: NSViewRepresentable {

    var title: String?
    var isOn: Bool = false
    let action: (Bool) -> Void

    init(_ title: String, isOn: Bool, action: @escaping (Bool) -> Void) {
        self.title = title
        self.isOn = isOn
        self.action = action
    }

    func makeNSView (context: NSViewRepresentableContext<Self>) -> NSButton {
        let button = NSButton(title: "", target: nil, action: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setButtonType(.switch)
        button.state = isOn ? .on : .off
        return button
    }

    func updateNSView (_ nsView: NSButton, context: NSViewRepresentableContext<Self>) {
        nsView.title = title ?? ""
        nsView.state = isOn ? .on : .off
        nsView.onAction { sender in
            self.action(sender.state == .on)
        }
    }
}



// MARK: - Action closure for controls
private var controlActionClosureProtocolAssociatedObjectKey: UInt8 = 0

protocol ControlActionClosureProtocol: NSObjectProtocol {
    var target: AnyObject? { get set }
    var action: Selector? { get set }
}

private final class ActionTrampoline<T>: NSObject {
    let action: (T) -> Void

    init(action: @escaping (T) -> Void) {
        self.action = action
    }

    @objc
    func action(sender: AnyObject) {
        action(sender as! T)
    }
}

extension ControlActionClosureProtocol {
    func onAction(_ action: @escaping (Self) -> Void) {
        let trampoline = ActionTrampoline(action: action)
        self.target = trampoline
        self.action = #selector(ActionTrampoline<Self>.action(sender:))
        objc_setAssociatedObject(self, &controlActionClosureProtocolAssociatedObjectKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
    }
}

extension NSControl: ControlActionClosureProtocol {}
