import SwiftUI
import GoogleMobileAds

struct ContentView: View {
    @State private var currentScreen = "home"
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showingResult = false
    @State private var showingExplanation = false
    
    let questions = [
        Question(
            text: "2025年に開催される大阪・関西万博のテーマは何でしょうか？",
            options: [
                "いのち輝く未来社会のデザイン",
                "人類の進歩と調和",
                "よりよい明日のために",
                "みんなで創る持続可能な社会"
            ],
            correctIndex: 0,
            explanation: "2025年大阪・関西万博のテーマは「いのち輝く未来社会のデザイン」です。"
        ),
        Question(
            text: "2025年に予定されている日本の重要な政治イベントは何でしょうか？",
            options: [
                "参議院議員選挙",
                "衆議院議員選挙",
                "都道府県知事選挙",
                "市町村長選挙"
            ],
            correctIndex: 0,
            explanation: "2025年には参議院議員選挙が予定されています。"
        ),
        Question(
            text: "2025年現在、日本の人口に関する大きな話題となっているのは何でしょうか？",
            options: [
                "少子高齢化の加速",
                "人口の急激な増加",
                "外国人労働者の減少",
                "地方への人口移住"
            ],
            correctIndex: 0,
            explanation: "日本では少子高齢化が進行し、人口減少が社会的課題となっています。"
        ),
        Question(
            text: "2025年に注目されている環境問題対策として、日本が目指している目標は何でしょうか？",
            options: [
                "カーボンニュートラル",
                "完全リサイクル社会",
                "全電力の太陽光発電化",
                "プラスチック完全廃止"
            ],
            correctIndex: 0,
            explanation: "日本は2050年までにカーボンニュートラル（温室効果ガス排出量実質ゼロ）を目指しています。"
        ),
        Question(
            text: "2025年現在、日本の経済政策で注目されているデジタル化政策は何でしょうか？",
            options: [
                "DX（デジタルトランスフォーメーション）推進",
                "完全キャッシュレス化",
                "AI完全自動化",
                "メタバース経済移行"
            ],
            correctIndex: 0,
            explanation: "日本政府はDX推進により、社会全体のデジタル化を進めています。"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if currentScreen == "home" {
                    HomeScreen(onStart: {
                        currentScreen = "quiz"
                        currentQuestionIndex = 0
                        score = 0
                        selectedAnswer = nil
                        showingResult = false
                        showingExplanation = false
                    })
                } else if currentScreen == "quiz" {
                    QuizScreen(
                        question: questions[currentQuestionIndex],
                        questionNumber: currentQuestionIndex + 1,
                        totalQuestions: questions.count,
                        selectedAnswer: $selectedAnswer,
                        showingResult: $showingResult,
                        showingExplanation: $showingExplanation,
                        onAnswer: { answerIndex in
                            selectedAnswer = answerIndex
                            showingResult = true
                            showingExplanation = true
                            
                            if answerIndex == questions[currentQuestionIndex].correctIndex {
                                score += 1
                            }
                        },
                        onNext: {
                            if currentQuestionIndex < questions.count - 1 {
                                currentQuestionIndex += 1
                                selectedAnswer = nil
                                showingResult = false
                                showingExplanation = false
                            } else {
                                currentScreen = "result"
                            }
                        }
                    )
                } else if currentScreen == "result" {
                    ResultScreen(
                        score: score,
                        totalQuestions: questions.count,
                        onRestart: {
                            showInterstitialAd {
                                currentScreen = "home"
                            }
                        }
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // AdMobの初期化とインタースティシャル広告の事前読み込み
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            InterstitialAdManager.shared.loadAd()
        }
    }
    
    private func showInterstitialAd(completion: @escaping () -> Void) {
        InterstitialAdManager.shared.showAd(from: UIApplication.shared.windows.first?.rootViewController) {
            completion()
        }
    }
}

struct Question {
    let text: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct HomeScreen: View {
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                Text("2025時事クイズ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("最新ニュースで知識をチェック！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onStart) {
                Text("スタート")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct QuizScreen: View {
    let question: Question
    let questionNumber: Int
    let totalQuestions: Int
    @Binding var selectedAnswer: Int?
    @Binding var showingResult: Bool
    @Binding var showingExplanation: Bool
    let onAnswer: (Int) -> Void
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("問題 \(questionNumber) / \(totalQuestions)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                Text(question.text)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                
                ForEach(0..<question.options.count, id: \.self) { index in
                    Button(action: {
                        if selectedAnswer == nil {
                            onAnswer(index)
                        }
                    }) {
                        HStack {
                            Text(question.options[index])
                                .foregroundColor(getTextColor(for: index))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding()
                        .background(getBackgroundColor(for: index))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(getBorderColor(for: index), lineWidth: 2)
                        )
                    }
                    .disabled(selectedAnswer != nil)
                }
            }
            
            if showingExplanation {
                VStack(spacing: 15) {
                    Text(selectedAnswer == question.correctIndex ? "正解！" : "不正解")
                        .font(.headline)
                        .foregroundColor(selectedAnswer == question.correctIndex ? .green : .red)
                    
                    Text(question.explanation)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button(action: onNext) {
                        Text(questionNumber < totalQuestions ? "次の問題" : "結果を見る")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                }
                .padding(.top)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func getBackgroundColor(for index: Int) -> Color {
        guard let selectedAnswer = selectedAnswer else { return Color(.systemGray6) }
        
        if index == selectedAnswer && showingResult {
            return index == question.correctIndex ? Color.green.opacity(0.3) : Color.red.opacity(0.3)
        } else if index == question.correctIndex && showingResult {
            return Color.green.opacity(0.3)
        }
        return Color(.systemGray6)
    }
    
    private func getTextColor(for index: Int) -> Color {
        guard let selectedAnswer = selectedAnswer else { return .primary }
        
        if index == selectedAnswer && showingResult {
            return index == question.correctIndex ? .green : .red
        } else if index == question.correctIndex && showingResult {
            return .green
        }
        return .primary
    }
    
    private func getBorderColor(for index: Int) -> Color {
        guard let selectedAnswer = selectedAnswer else { return Color.clear }
        
        if index == selectedAnswer && showingResult {
            return index == question.correctIndex ? .green : .red
        } else if index == question.correctIndex && showingResult {
            return .green
        }
        return Color.clear
    }
}

struct ResultScreen: View {
    let score: Int
    let totalQuestions: Int
    let onRestart: () -> Void
    
    var percentage: Int {
        Int(Double(score) / Double(totalQuestions) * 100)
    }
    
    var resultMessage: String {
        if percentage >= 80 { return "素晴らしい！" }
        if percentage >= 60 { return "よくできました！" }
        if percentage >= 40 { return "もう少し頑張りましょう！" }
        return "また挑戦してみてください！"
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("結果発表")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                Text("\(score) / \(totalQuestions)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("正答率: \(percentage)%")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(resultMessage)
                    .font(.title3)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(20)
            
            Button(action: onRestart) {
                Text("最初に戻る")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

// AdMobのインタースティシャル広告管理クラス
class InterstitialAdManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
    static let shared = InterstitialAdManager()
    
    private var interstitialAd: GADInterstitialAd?
    private var completion: (() -> Void)?
    
    override init() {
        super.init()
        loadAd()
    }
    
    func loadAd() {
        let adUnitID = "ca-app-pub-3940256099942544/1033173712" // テスト広告ユニットID
        
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error)")
                return
            }
            
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    func showAd(from viewController: UIViewController?, completion: @escaping () -> Void) {
        self.completion = completion
        
        guard let interstitialAd = interstitialAd else {
            print("Ad wasn't ready")
            completion()
            return
        }
        
        interstitialAd.present(fromRootViewController: viewController)
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.interstitialAd = nil
        completion?()
        completion = nil
        
        // 次回用の広告を事前読み込み
        loadAd()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error)")
        self.interstitialAd = nil
        completion?()
        completion = nil
        
        // 次回用の広告を事前読み込み
        loadAd()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}