//
//  String+Extension.swift
//  Logs Ninja
//
//  Created by Cristian Baluta on 07/05/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Cocoa

extension String {
    
    func heightWithConstrainedWidth(_ width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: NSString.DrawingOptions.usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12)],
                                            context: nil)
        return boundingBox.height + 8// padding
    }
    
    func ranges (of substring: String) -> [NSRange] {
        
        let regex = try! NSRegularExpression(pattern: "\\b\(substring)", options: NSRegularExpression.Options.caseInsensitive)
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        let ranges: [NSRange] = matches.map({$0.range})
        
        return ranges
    }
}
