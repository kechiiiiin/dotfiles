// winowner: CGWindowID ごとの持ち主アプリ名を出す（sanbun レイアウトが使う）
import CoreGraphics
import Foundation
let list = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] ?? []
for w in list {
    if let id = w[kCGWindowNumber as String] as? Int, let owner = w[kCGWindowOwnerName as String] as? String {
        print("\(id)\t\(owner)")
    }
}
