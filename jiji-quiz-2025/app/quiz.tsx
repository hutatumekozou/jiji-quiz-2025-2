import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';

// クイズデータの型定義
interface Question {
  id: number;
  text: string;
  options: string[];
  correctIndex: number;
  explanation: string;
}

// 月別クイズデータの読み込み関数
const loadQuizData = (month: string): Question[] => {
  try {
    switch (month) {
      case 'january':
        return require('../data/questions-january.json');
      case 'february':
        return require('../data/questions-february.json');
      case 'march':
        return require('../data/questions-march.json');
      case 'april':
        return require('../data/questions-april.json');
      case 'may':
        return require('../data/questions-may.json');
      case 'june':
        return require('../data/questions-june.json');
      default:
        return require('../data/questions-january.json');
    }
  } catch (error) {
    console.error('Failed to load quiz data:', error);
    return require('../data/questions-january.json');
  }
};

// 月の表示名
const getMonthDisplayName = (month: string): string => {
  const monthNames: { [key: string]: string } = {
    'january': '2025年1月',
    'february': '2025年2月',
    'march': '2025年3月',
    'april': '2025年4月',
    'may': '2025年5月',
    'june': '2025年6月',
  };
  return monthNames[month] || '2025年1月';
};

export default function QuizScreen() {
  const router = useRouter();
  const { month } = useLocalSearchParams();
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState<number | null>(null);
  const [showResult, setShowResult] = useState(false);
  const [score, setScore] = useState(0);
  const [answers, setAnswers] = useState<number[]>([]);
  const [quizData, setQuizData] = useState<Question[]>([]);

  useEffect(() => {
    const monthString = Array.isArray(month) ? month[0] : month || 'january';
    const data = loadQuizData(monthString);
    setQuizData(data);
  }, [month]);

  const handleAnswerSelect = (index: number) => {
    if (selectedAnswer !== null) return;
    
    setSelectedAnswer(index);
    setShowResult(true);
    
    const newAnswers = [...answers, index];
    setAnswers(newAnswers);
    
    if (index === quizData[currentQuestion].correctIndex) {
      setScore(score + 1);
    }
  };

  const handleNext = () => {
    if (currentQuestion < quizData.length - 1) {
      setCurrentQuestion(currentQuestion + 1);
      setSelectedAnswer(null);
      setShowResult(false);
    } else {
      const monthString = Array.isArray(month) ? month[0] : month || 'january';
      router.push({
        pathname: '/result',
        params: { 
          score: score.toString(), 
          total: quizData.length.toString(),
          month: monthString
        }
      });
    }
  };

  if (quizData.length === 0) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.questionNumber}>読み込み中...</Text>
        </View>
      </SafeAreaView>
    );
  }

  const question = quizData[currentQuestion];
  const monthString = Array.isArray(month) ? month[0] : month || 'january';

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.monthTitle}>{getMonthDisplayName(monthString)}</Text>
        <Text style={styles.questionNumber}>
          問題 {currentQuestion + 1} / {quizData.length}
        </Text>
      </View>

      <View style={styles.questionContainer}>
        <Text style={styles.questionText}>{question.text}</Text>
      </View>

      <View style={styles.optionsContainer}>
        {question.options.map((option, index) => (
          <TouchableOpacity
            key={index}
            style={[
              styles.optionButton,
              selectedAnswer === index && styles.selectedOption,
              showResult && index === question.correctIndex && styles.correctOption,
              showResult && selectedAnswer === index && index !== question.correctIndex && styles.incorrectOption
            ]}
            onPress={() => handleAnswerSelect(index)}
            disabled={selectedAnswer !== null}
          >
            <Text style={[
              styles.optionText,
              selectedAnswer === index && styles.selectedOptionText,
              showResult && index === question.correctIndex && styles.correctOptionText
            ]}>
              {option}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {showResult && (
        <View style={styles.resultContainer}>
          <Text style={styles.resultText}>
            {selectedAnswer === question.correctIndex ? '正解！' : '不正解'}
          </Text>
          <Text style={styles.explanationText}>{question.explanation}</Text>
          
          <TouchableOpacity style={styles.nextButton} onPress={handleNext}>
            <Text style={styles.nextButtonText}>
              {currentQuestion < quizData.length - 1 ? '次の問題' : '結果を見る'}
            </Text>
          </TouchableOpacity>
        </View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    padding: 20,
  },
  header: {
    alignItems: 'center',
    marginBottom: 30,
  },
  monthTitle: {
    fontSize: 18,
    color: '#3498db',
    fontWeight: 'bold',
    marginBottom: 5,
  },
  questionNumber: {
    fontSize: 16,
    color: '#7f8c8d',
    fontWeight: 'bold',
  },
  questionContainer: {
    backgroundColor: 'white',
    padding: 20,
    borderRadius: 10,
    marginBottom: 30,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  questionText: {
    fontSize: 18,
    color: '#2c3e50',
    lineHeight: 26,
  },
  optionsContainer: {
    flex: 1,
  },
  optionButton: {
    backgroundColor: 'white',
    padding: 15,
    borderRadius: 8,
    marginBottom: 10,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 1.84,
  },
  selectedOption: {
    backgroundColor: '#3498db',
  },
  correctOption: {
    backgroundColor: '#2ecc71',
  },
  incorrectOption: {
    backgroundColor: '#e74c3c',
  },
  optionText: {
    fontSize: 16,
    color: '#2c3e50',
  },
  selectedOptionText: {
    color: 'white',
  },
  correctOptionText: {
    color: 'white',
  },
  resultContainer: {
    backgroundColor: 'white',
    padding: 20,
    borderRadius: 10,
    marginTop: 20,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
  },
  resultText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2c3e50',
    textAlign: 'center',
    marginBottom: 10,
  },
  explanationText: {
    fontSize: 16,
    color: '#7f8c8d',
    textAlign: 'center',
    marginBottom: 20,
    lineHeight: 22,
  },
  nextButton: {
    backgroundColor: '#3498db',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  nextButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});