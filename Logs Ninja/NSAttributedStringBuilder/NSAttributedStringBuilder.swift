// NSAttributedString does not support SwiftUI Font and color, we still need to use UI/NS Font/Color
#if canImport(UIKit)
import UIKit
public typealias AFont = UIFont
public typealias AColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias AFont = NSFont
public typealias AColor = NSColor
#endif

public typealias Attributes = [NSAttributedString.Key: Any]

@_functionBuilder
public struct NSAttributedStringBuilder {
    public static func buildBlock(_ components: Component...) -> NSAttributedString {
        let mas = NSMutableAttributedString(string: "")
        for component in components {
            mas.append(component.attributedString)
        }
        return mas
    }
}

extension NSAttributedString {
    public convenience init(@NSAttributedStringBuilder _ builder: () -> NSAttributedString) {
        self.init(attributedString: builder())
    }
}
