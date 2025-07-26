import Foundation

struct Question: Codable, Identifiable {
    let id: Int
    let text: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

enum QuizState {
    case start
    case inProgress
    case completed
}

enum AnswerState {
    case notAnswered
    case correct
    case incorrect
}