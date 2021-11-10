//
//  LogCell.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 29/11/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import SwiftUI

struct LogCell: View {
    
    var log: Log
    let leftColumnWidth = CGFloat(10)
    let nonHighlightedColor = Color(red: 0.8, green: 0.8, blue: 0.8)
    
    var body: some View {
        GeometryReader { geometry in
//            HStack(spacing: 0) {
//                Text("●")
//                .frame(width: self.leftColumnWidth, alignment: .center)
//                .foregroundColor(self.log.isHighlighted ? .secondary : self.nonHighlightedColor)
                
//                AttributedText(attributedString: self.log.attributedString)
//                .frame(width: geometry.size.width - self.leftColumnWidth, alignment: .leading)
                
                Text(self.log.content)
//                .frame(width: geometry.size.width - self.leftColumnWidth, alignment: .leading)
                .font(.system(size: 12))
                .foregroundColor(self.log.isHighlighted ? .primary : self.nonHighlightedColor)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .padding(.leading, self.leftColumnWidth)
//            }
        }
    }
}
