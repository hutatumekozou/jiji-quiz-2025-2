import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    @StateObject private var adMobManager = AdMobManager()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 15) {
                Text("結果発表")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("お疲れ様でした！")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 25)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            Spacer()
            
            // Results
            VStack(spacing: 40) {
                // Score Circle
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.scorePercentage) / 100)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: viewModel.scorePercentage)
                    
                    VStack(spacing: 5) {
                        Text("\(viewModel.score)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("/ \(viewModel.questions.count)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Percentage and Message
                VStack(spacing: 20) {
                    Text("正答率: \(viewModel.scorePercentage)%")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.resultMessage)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Performance Badge
                VStack(spacing: 10) {
                    Image(systemName: performanceIcon)
                        .font(.system(size: 40))
                        .foregroundColor(performanceColor)
                    
                    Text(performanceText)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(performanceColor)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(performanceColor.opacity(0.1))
                )
            }
            
            Spacer()
            
            // Restart Button
            Button(action: {
                // 広告を表示してからクイズを再開
                adMobManager.showInterstitialAd {
                    viewModel.restartQuiz()
                }
            }) {
                Text("最初に戻る")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 55)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 50)
        }
    }
    
    private var performanceIcon: String {
        let percentage = viewModel.scorePercentage
        if percentage >= 80 {
            return "star.fill"
        } else if percentage >= 60 {
            return "hand.thumbsup.fill"
        } else if percentage >= 40 {
            return "lightbulb.fill"
        } else {
            return "arrow.clockwise"
        }
    }
    
    private var performanceColor: Color {
        let percentage = viewModel.scorePercentage
        if percentage >= 80 {
            return .yellow
        } else if percentage >= 60 {
            return .green
        } else if percentage >= 40 {
            return .orange
        } else {
            return .blue
        }
    }
    
    private var performanceText: String {
        let percentage = viewModel.scorePercentage
        if percentage >= 80 {
            return "優秀！"
        } else if percentage >= 60 {
            return "合格！"
        } else if percentage >= 40 {
            return "もう少し！"
        } else {
            return "再挑戦！"
        }
    }
}