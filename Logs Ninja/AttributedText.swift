//
//  AttributedText.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 28/04/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import SwiftUI
//import NSAttributedStringBuilder

/// A custom view to use NSAttributedString in SwiftUI
final public class AttributedText: NSViewRepresentable {
    
    
    public typealias NSViewType = NSTextView
    
    
    
    var attributedString: NSAttributedString

    private init(_ attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }

    public convenience init(@NSAttributedStringBuilder _ builder: () -> NSAttributedString) {
        self.init(builder())
    }

    public func makeNSView(context: NSViewRepresentableContext<AttributedText>) -> NSTextView {
        let textView = NSTextView(frame: .zero)
        textView.string = self.attributedString.string
//        textView.attributedText = self.attributedString
        textView.isEditable = false
        textView.backgroundColor = .clear
//        textView.textAlignment = .center
        return textView
    }
    
    public func updateNSView(_ textView: NSTextView, context: NSViewRepresentableContext<AttributedText>) {
//        textView.attributedText = self.attributedString
        textView.string = self.attributedString.string
    }
}

#if DEBUG
struct AttributedText_Previews : PreviewProvider {
    static var previews: some View {
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
}
#endif
