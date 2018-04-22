import UIKit

extension UIFont {
    static let title = UIFont.preferredFont(forTextStyle: .title1)
    static let regular = UIFont.preferredFont(forTextStyle: .body)
    static let timestamp = UIFont.preferredFont(forTextStyle: .footnote)
    static let label = UIFont.preferredFont(forTextStyle: .title2)
}

extension UIColor {
    static let background = UIColor(hex: 0xF9F9F9)
    static let entryBackground = UIColor(hex: 0x0A2A46)
    static let entryText = UIColor(hex: 0xEBF2F8)
    static let entryTint = UIColor(hex: 0xFFFFA2)
    static let systemBlue = UIColor(hex: 0x327BF7)
    static let systemGray = UIColor(hex: 0x8E8E93)
    static let systemRed = UIColor(hex: 0xEB4D3D)
}

extension UIImage {

    static let iconSearch = UIImage(named: "Search")!.withRenderingMode(.alwaysTemplate)
    static let iconClear = UIImage(named: "Clear")!.withRenderingMode(.alwaysTemplate)
    static let iconArrowUp = UIImage(named: "ArrowUp")!.withRenderingMode(.alwaysTemplate)
    static let iconCamera = UIImage(named: "Camera")!.withRenderingMode(.alwaysTemplate)
    static let iconTrash = UIImage(named: "Trash")!.withRenderingMode(.alwaysTemplate)
}
