import Foundation
import AppKit

struct UserIcon: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let image: NSImage
} 