import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Logo & Title
            VStack(spacing: 20) {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 10) {
                    Text("2025時事クイズ")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("最新ニュースで知識をチェック！")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            // Description
            VStack(spacing: 15) {
                Text("時事問題にチャレンジ！")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("2025年の最新ニュースに関する問題が10問出題されます")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Start Button
            Button(action: {
                viewModel.startQuiz()
            }) {
                Text("スタート")
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
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: false)
            
            Spacer()
        }
        .padding()
    }
}