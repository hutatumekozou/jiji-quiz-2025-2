import SwiftUI

struct ContentView: View {
    @StateObject private var quizViewModel = QuizViewModel()
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            switch quizViewModel.quizState {
            case .start:
                StartView(viewModel: quizViewModel)
            case .inProgress:
                QuizView(viewModel: quizViewModel)
            case .completed:
                ResultView(viewModel: quizViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}

