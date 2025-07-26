import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 15) {
                Text("2025時事クイズ")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(viewModel.progressText)
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
            
            ScrollView {
                VStack(spacing: 30) {
                    // Question
                    if let question = viewModel.currentQuestion {
                        VStack(spacing: 25) {
                            Text(question.text)
                                .font(.title3)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 30)
                            
                            // Options
                            VStack(spacing: 15) {
                                ForEach(0..<question.options.count, id: \.self) { index in
                                    OptionButton(
                                        text: question.options[index],
                                        index: index,
                                        selectedIndex: viewModel.selectedAnswerIndex,
                                        correctIndex: question.correctIndex,
                                        answerState: viewModel.answerState
                                    ) {
                                        viewModel.selectAnswer(index)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Explanation
                            if viewModel.showExplanation {
                                VStack(spacing: 15) {
                                    HStack {
                                        Image(systemName: viewModel.answerState == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(viewModel.answerState == .correct ? .green : .red)
                                            .font(.title2)
                                        
                                        Text(viewModel.answerState == .correct ? "正解！" : "不正解")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(viewModel.answerState == .correct ? .green : .red)
                                        
                                        Spacer()
                                    }
                                    
                                    Text(question.explanation)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                
                                // Next Button
                                Button(action: {
                                    viewModel.nextQuestion()
                                }) {
                                    Text(viewModel.isLastQuestion ? "結果を見る" : "次の問題")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.blue, .purple]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(25)
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                            }
                        }
                    }
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showExplanation)
    }
}

struct OptionButton: View {
    let text: String
    let index: Int
    let selectedIndex: Int?
    let correctIndex: Int
    let answerState: AnswerState
    let action: () -> Void
    
    private var backgroundColor: Color {
        guard let selectedIndex = selectedIndex else {
            return Color(.systemBackground)
        }
        
        if index == correctIndex {
            return .green
        } else if index == selectedIndex && index != correctIndex {
            return .red
        } else {
            return Color(.systemGray5)
        }
    }
    
    private var textColor: Color {
        guard selectedIndex != nil else {
            return .primary
        }
        
        if index == correctIndex || (index == selectedIndex && index != correctIndex) {
            return .white
        } else {
            return .secondary
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(backgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedIndex == nil ? Color(.systemGray4) : Color.clear, lineWidth: 1)
                )
        }
        .disabled(selectedIndex != nil)
        .animation(.easeInOut(duration: 0.2), value: backgroundColor)
    }
}