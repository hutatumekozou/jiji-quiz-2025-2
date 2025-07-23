import { Stack } from 'expo-router';
import { useEffect } from 'react';
// import mobileAds from 'react-native-google-mobile-ads';

export default function RootLayout() {
  useEffect(() => {
    // AdMobの初期化（一時的に無効化）
    // mobileAds()
    //   .initialize()
    //   .then(adapterStatuses => {
    //     console.log('AdMob initialized successfully');
    //   })
    //   .catch(error => {
    //     console.error('AdMob initialization failed:', error);
    //   });
  }, []);

  return (
    <Stack>
      <Stack.Screen name="index" options={{ headerShown: false }} />
      <Stack.Screen name="menu" options={{ headerShown: false }} />
      <Stack.Screen name="quiz" options={{ headerShown: false }} />
      <Stack.Screen name="result" options={{ headerShown: false }} />
    </Stack>
  );
}