// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_quiz_game/api_service.dart'; // Chỉ cần import nếu bạn dùng API Service trong main.dart
import 'package:my_quiz_game/HomeScreen.dart';   // Đảm bảo đường dẫn và tên file này đúng
import 'package:my_quiz_game/auth_screen.dart'; // <--- ĐÃ THÊM: IMPORT AUTHSCREEN TỪ FILE RIÊNG

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoadingApp = true; // Biến để kiểm tra trạng thái tải ứng dụng ban đầu

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_id');

    if (mounted) {
      setState(() {
        _isLoggedIn = studentId != null;
        _isLoadingApp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Quiz Học sinh',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        // Sử dụng AuthScreen từ file auth_screen.dart
        '/login': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
      },
      home: _isLoadingApp
          ? const SplashScreen() // Hiển thị Splash Screen trong khi kiểm tra đăng nhập
          : (_isLoggedIn ? const HomeScreen() : const AuthScreen()), // Chuyển hướng sau khi kiểm tra
    );
  }
}

// Màn hình Splash Screen đơn giản (giữ nguyên, nằm trong main.dart)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Hoặc logo, animation của bạn
      ),
    );
  }
}