//
//  AttributedText.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 28/04/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import SwiftUI
import NSAttributedStringBuilder

/// A custom view to use NSAttributedString in SwiftUI
final public class AttributedText: NSViewRepresentable {
    
    public typealias NSViewType = NSTextView
    var attributedString: NSAttributedString
    
    private init(_ attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
    
    public convenience init(attributedString: NSAttributedString) {
        self.init(attributedString)
    }
    
    public convenience init(@NSAttributedStringBuilder _ builder: () -> NSAttributedString) {
        self.init(builder())
    }
    
    public func makeNSView(context: NSViewRepresentableContext<AttributedText>) -> NSTextView {
        let textView = NSTextView(frame: .zero)
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = .clear
//        textView.font = NSFont.systemFont(ofSize: 13)
//        textView.lineSpacing = 10
        textView.textStorage?.setAttributedString(attributedString)
        return textView
    }
    
    public func updateNSView(_ textView: NSTextView, context: NSViewRepresentableContext<AttributedText>) {
        textView.textStorage?.setAttributedString(attributedString)
    }
}

#if DEBUG
struct AttributedText_Previews : PreviewProvider {
    static var previews: some View {
        AttributedText(attributedString: attributedString)
//        AttributedText {
//            LineBreak()
//                .lineSpacing(20)
//            AText("Hello SwiftUI")
//                .backgroundColor(NSColor(named: "SelectedTextColor") ?? .red)
//                .baselineOffset(10)
//                .font(.systemFont(ofSize: 20))
//                .foregroundColor(.yellow)
//                .expansion(1)
//                .kerning(3)
//                .ligature(.none)
//                .obliqueness(0.5)
//                .shadow(color: .black, radius: 10, x: 4, y: 4)
//                .strikethrough(style: .patternDash, color: .black)
//                .stroke(width: -2, color: .green)
//                .underline(.patternDashDotDot, color: .cyan)
//            AText(" with fun")
//                .paragraphSpacing(10, before: 60)
//                .alignment(.right)
//        }
    }
    static var attributedString: NSAttributedString {
        let string = "Swift wrapper attributedstring and another wrappers of ..."
        let myString = NSMutableAttributedString(string: string, attributes: [:])
        let ranges = string.ranges(of: "wrapper")
        for range in ranges {
            let anotherAttribute = [NSAttributedString.Key.backgroundColor: NSColor(named: "SelectedTextColor") ?? .red]
            myString.addAttributes(anotherAttribute, range: range)
        }
        
        return myString
    }
}
#endif
