import Foundation

struct QuestionBank {
    static func loadQuestions(for month: QuizMonth) -> [Question] {
        // 月別JSONファイルからの読み込みを試行
        if let questions = loadFromJSON(month.jsonFileName) {
            return Array(questions.prefix(10)) // 必ず10問に制限
        }
        
        // フォールバック: デフォルトのquestions.jsonから月番号に基づいて10問を選択
        return loadDefaultQuestions(for: month)
    }
    
    private static func loadFromJSON(_ fileName: String) -> [Question]? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questions = try? JSONDecoder().decode([Question].self, from: data) else {
            return nil
        }
        return questions
    }
    
    private static func loadDefaultQuestions(for month: QuizMonth) -> [Question] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let allQuestions = try? JSONDecoder().decode([Question].self, from: data) else {
            print("Failed to load default questions.json")
            return []
        }
        
        // 月番号に基づいて異なる10問セットを返す（シード値として利用）
        var randomGenerator = SeededRandomNumberGenerator(seed: UInt64(month.rawValue))
        let shuffled = allQuestions.shuffled(using: &randomGenerator)
        return Array(shuffled.prefix(10))
    }
}

// 月ごとに一貫した問題セットを保証するためのシード付きランダム生成器
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}