import SwiftUI

struct StartView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 30) {
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
                    
                    Text("月別でチャレンジ！")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            // Month Selection Cards (2x3 grid)
            VStack(spacing: 20) {
                Text("挑戦する月を選んでください")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(QuizMonth.allCases) { month in
                        MonthCard(month: month) {
                            viewModel.startQuiz(for: month)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MonthCard: View {
    let month: QuizMonth
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                
                Text(month.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("10問")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}