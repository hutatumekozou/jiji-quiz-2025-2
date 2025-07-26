import Foundation
import SwiftUI

class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var quizState: QuizState = .start
    @Published var selectedAnswerIndex: Int? = nil
    @Published var answerState: AnswerState = .notAnswered
    @Published var showExplanation = false
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    var progressText: String {
        "問題 \(currentQuestionIndex + 1) / \(questions.count)"
    }
    
    var scorePercentage: Int {
        guard questions.count > 0 else { return 0 }
        return Int(Double(score) / Double(questions.count) * 100)
    }
    
    var resultMessage: String {
        let percentage = scorePercentage
        if percentage >= 80 {
            return "素晴らしい！時事問題に詳しいですね！"
        } else if percentage >= 60 {
            return "よくできました！"
        } else if percentage >= 40 {
            return "もう少し頑張りましょう！"
        } else {
            return "また挑戦してみてください！"
        }
    }
    
    init() {
        loadQuestions()
    }
    
    func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let loadedQuestions = try? JSONDecoder().decode([Question].self, from: data) else {
            print("Failed to load questions.json")
            return
        }
        
        self.questions = loadedQuestions.shuffled()
    }
    
    func startQuiz() {
        currentQuestionIndex = 0
        score = 0
        quizState = .inProgress
        selectedAnswerIndex = nil
        answerState = .notAnswered
        showExplanation = false
        questions = questions.shuffled()
    }
    
    func selectAnswer(_ index: Int) {
        guard selectedAnswerIndex == nil else { return }
        
        selectedAnswerIndex = index
        
        if let currentQuestion = currentQuestion {
            if index == currentQuestion.correctIndex {
                answerState = .correct
                score += 1
            } else {
                answerState = .incorrect
            }
        }
        
        showExplanation = true
    }
    
    func nextQuestion() {
        if isLastQuestion {
            quizState = .completed
        } else {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            answerState = .notAnswered
            showExplanation = false
        }
    }
    
    func restartQuiz() {
        quizState = .start
        currentQuestionIndex = 0
        score = 0
        selectedAnswerIndex = nil
        answerState = .notAnswered
        showExplanation = false
    }
}