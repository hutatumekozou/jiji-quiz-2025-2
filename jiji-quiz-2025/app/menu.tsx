import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';

const MONTHS = [
  { key: 'january', label: '25年1月', subtitle: '新年の政策・制度' },
  { key: 'february', label: '25年2月', subtitle: '社会保障・防災' },
  { key: 'march', label: '25年3月', subtitle: '新年度・教育' },
  { key: 'april', label: '25年4月', subtitle: '万博・働き方' },
  { key: 'may', label: '25年5月', subtitle: '労働・子育て' },
  { key: 'june', label: '25年6月', subtitle: '気候・健康' },
];

export default function MenuScreen() {
  const router = useRouter();

  const handleMonthSelect = (month: string) => {
    router.push({
      pathname: '/quiz',
      params: { month }
    });
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>2025時事クイズ</Text>
        <Text style={styles.subtitle}>月別クイズを選択してください</Text>
      </View>

      <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
        <View style={styles.monthGrid}>
          {MONTHS.map((month) => (
            <TouchableOpacity
              key={month.key}
              style={styles.monthButton}
              onPress={() => handleMonthSelect(month.key)}
            >
              <View style={styles.monthButtonContent}>
                <Text style={styles.monthLabel}>{month.label}</Text>
                <Text style={styles.monthSubtitle}>{month.subtitle}</Text>
                <View style={styles.questionCount}>
                  <Text style={styles.questionCountText}>10問</Text>
                </View>
              </View>
            </TouchableOpacity>
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    alignItems: 'center',
    padding: 30,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#7f8c8d',
    textAlign: 'center',
  },
  scrollView: {
    flex: 1,
  },
  monthGrid: {
    padding: 20,
    gap: 15,
  },
  monthButton: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  monthButtonContent: {
    alignItems: 'center',
  },
  monthLabel: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#3498db',
    marginBottom: 8,
  },
  monthSubtitle: {
    fontSize: 14,
    color: '#7f8c8d',
    textAlign: 'center',
    marginBottom: 12,
  },
  questionCount: {
    backgroundColor: '#3498db',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
  },
  questionCountText: {
    color: 'white',
    fontSize: 12,
    fontWeight: '600',
  },
});