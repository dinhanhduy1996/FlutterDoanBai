// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Cần để lưu trạng thái đăng nhập
import 'package:my_quiz_game/api_service.dart'; // Cần để gọi API đăng nhập/đăng ký
import 'package:my_quiz_game/homescreen.dart'; // Cần để điều hướng đến HomeScreen sau khi đăng nhập

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key); // Sử dụng Key? key

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showLoginPage = true; // true = Đăng nhập, false = Đăng ký

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (mounted) { // Đảm bảo widget còn tồn tại trước khi dùng context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _register() async {
    setState(() { _isLoading = true; });

    final String studentName = _studentNameController.text.trim();
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (studentName.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin.', isSuccess: false);
      if (mounted) { setState(() { _isLoading = false; }); }
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Mật khẩu và xác nhận mật khẩu không khớp.', isSuccess: false);
      if (mounted) { setState(() { _isLoading = false; }); }
      return;
    }

    final response = await ApiService.registerUser(studentName, username, password);

    if (mounted) {
      setState(() { _isLoading = false; });
      _showSnackBar(response['message'] ?? 'Có lỗi xảy ra.', isSuccess: (response['status'] == 'success'));

      if (response['status'] == 'success') {
        _usernameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _studentNameController.clear();
        setState(() { _showLoginPage = true; }); // Chuyển sang màn hình đăng nhập sau khi đăng ký
      }
    }
  }

  Future<void> _login() async {
    setState(() { _isLoading = true; });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Vui lòng nhập tên đăng nhập và mật khẩu.', isSuccess: false);
      if (mounted) { setState(() { _isLoading = false; }); }
      return;
    }

    final response = await ApiService.loginUser(username, password);

    if (mounted) {
      setState(() { _isLoading = false; });

      if (response['status'] == 'success') {
        // Kiểm tra xem 'student_info' có tồn tại và không phải null không
        if (response['student_info'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('studentId', response['student_info']['student_id']); // Cập nhật tên key
          await prefs.setString('username', response['student_info']['username']);
          await prefs.setString('studentName', response['student_info']['student_name']); // Cập nhật tên key

          // Chuyển hướng đến màn hình chính
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()), // Điều hướng trực tiếp
            );
          }
        } else {
          _showSnackBar('Thông tin người dùng không hợp lệ từ server.', isSuccess: false);
        }
      } else {
        _showSnackBar(response['message'] ?? 'Đăng nhập thất bại. Vui lòng kiểm tra lại.', isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showLoginPage ? 'Đăng nhập Học sinh' : 'Đăng ký Học sinh'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!_showLoginPage)
                Column(
                  children: [
                    TextField(
                      controller: _studentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              if (!_showLoginPage)
                Column(
                  children: [
                    const SizedBox(height: 15),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Xác nhận mật khẩu',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _showLoginPage ? _login : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        foregroundColor: Colors.white, // Màu chữ
                      ),
                      child: Text(_showLoginPage ? 'Đăng nhập' : 'Đăng ký'),
                    ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  setState(() {
                    _showLoginPage = !_showLoginPage;
                    _usernameController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                    _studentNameController.clear();
                  });
                },
                child: Text(
                  _showLoginPage
                      ? 'Chưa có tài khoản? Đăng ký ngay'
                      : 'Đã có tài khoản? Đăng nhập',
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}