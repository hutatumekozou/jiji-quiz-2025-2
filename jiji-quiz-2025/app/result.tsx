import React, { useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView, Alert } from 'react-native';
import { useRouter, useLocalSearchParams } from 'expo-router';
// import { AdMobManager } from '../utils/AdMobConfig';

export default function ResultScreen() {
  const router = useRouter();
  const { score, total, month } = useLocalSearchParams();

  useEffect(() => {
    // 結果画面表示時に広告を事前に読み込む（一時的に無効化）
    // AdMobManager.initialize().catch(console.error);
  }, []);
  
  const scoreNum = parseInt(score as string);
  const totalNum = parseInt(total as string);
  const percentage = Math.round((scoreNum / totalNum) * 100);

  const getResultMessage = () => {
    if (percentage >= 80) return '素晴らしい！';
    if (percentage >= 60) return 'よくできました！';
    if (percentage >= 40) return 'もう少し頑張りましょう！';
    return 'また挑戦してみてください！';
  };

  const handleRestart = async () => {
    try {
      // 「最初に戻る」ボタンを押した時にインタースティシャル広告を表示（一時的に無効化）
      // await AdMobManager.showAd();
      
      // 2秒後に画面遷移（広告表示のシミュレーション）
      setTimeout(() => {
        router.push('/menu');
      }, 1000);
      
      // 一時的なアラート表示
      Alert.alert('広告表示', 'ここでインタースティシャル広告が表示されます（テスト用）');
      
    } catch (error) {
      console.error('広告の表示に失敗しました:', error);
      // 広告の表示に失敗しても画面遷移は続行
      router.push('/menu');
    }
  };

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

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>結果発表</Text>
        <Text style={styles.monthTitle}>{getMonthDisplayName(month as string)}</Text>
        
        <View style={styles.scoreContainer}>
          <Text style={styles.scoreText}>
            {scoreNum} / {totalNum}
          </Text>
          <Text style={styles.percentageText}>
            正答率: {percentage}%
          </Text>
        </View>

        <View style={styles.messageContainer}>
          <Text style={styles.messageText}>
            {getResultMessage()}
          </Text>
        </View>

        <TouchableOpacity style={styles.restartButton} onPress={handleRestart}>
          <Text style={styles.restartButtonText}>目次に戻る</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 10,
  },
  monthTitle: {
    fontSize: 18,
    color: '#3498db',
    fontWeight: 'bold',
    marginBottom: 30,
  },
  scoreContainer: {
    backgroundColor: 'white',
    padding: 40,
    borderRadius: 20,
    alignItems: 'center',
    marginBottom: 40,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  scoreText: {
    fontSize: 48,
    fontWeight: 'bold',
    color: '#3498db',
    marginBottom: 10,
  },
  percentageText: {
    fontSize: 18,
    color: '#7f8c8d',
  },
  messageContainer: {
    marginBottom: 50,
  },
  messageText: {
    fontSize: 20,
    color: '#2c3e50',
    textAlign: 'center',
    fontWeight: '600',
  },
  restartButton: {
    backgroundColor: '#3498db',
    paddingHorizontal: 40,
    paddingVertical: 15,
    borderRadius: 25,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  restartButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
});