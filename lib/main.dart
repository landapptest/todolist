import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home.dart'; // HomeScreen 페이지
import 'Profile.dart'; // ProfileScreen 페이지
import 'Login.dart';
import 'Planner.dart';
import 'SubjectTimerProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 프레임워크 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 옵션 설정
  );

  final subjectTimerProvider = SubjectTimerProvider();
  await subjectTimerProvider.initialize(); // SharedPreferences 초기화 및 상태 복원

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => subjectTimerProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // 초기 화면 설정
      routes: {
        '/login': (context) => const LoginScreen(), // 로그인 화면
        '/home': (context) => const HomeScreen(), // 홈 화면
        '/planner': (context) => const PlannerScreen(), // 플래너 화면
        '/profile': (context) => const ProfileScreen(), // 프로필 화면
      },
    );
  }
}
