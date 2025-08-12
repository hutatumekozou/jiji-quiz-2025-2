import Foundation

enum QuizMonth: Int, CaseIterable, Identifiable {
    case jan = 1, feb, mar, apr, may, jun
    
    var id: Int { rawValue }
    
    var title: String { "25年\(rawValue)月" }
    
    var jsonFileName: String {
        switch self {
        case .jan: return "questions-january"
        case .feb: return "questions-february"
        case .mar: return "questions-march"
        case .apr: return "questions-april"
        case .may: return "questions-may"
        case .jun: return "questions-june"
        }
    }
}