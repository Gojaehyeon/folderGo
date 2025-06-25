import Foundation

enum IconMaskType: String, CaseIterable, Identifiable {
    case roundedSquare, circle, star, heart
    var id: String { self.rawValue }
    var label: String {
        switch self {
        case .roundedSquare: return "Rounded Square"
        case .circle: return "Circle"
        case .star: return "Star"
        case .heart: return "Heart"
        }
    }
} 