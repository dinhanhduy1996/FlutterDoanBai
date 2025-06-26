import 'dart:convert'; // Để xử lý JSON
import 'package:http/http.dart' as http; // Thư viện HTTP

class ApiService {
  // *****************************************************************
  // !!! QUAN TRỌNG: THAY ĐỔI ĐỊA CHỈ IP NÀY BẰNG IP MÁY TÍNH CỦA BẠN !!!
  // Ví dụ: const String API_BASE_URL = 'http://192.168.1.100/my_quiz_api';
  static const String API_BASE_URL = 'http://192.168.1.5/my_quiz_api'; // <<< THAY XX TẠI ĐÂY
  // *****************************************************************

  // Hàm đăng ký người dùng
  static Future<Map<String, dynamic>> registerUser(
      String studentName, String username, String password) async {
    final url = Uri.parse('$API_BASE_URL/register.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_name': studentName,
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server khi đăng ký: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi kết nối khi đăng ký: $e'};
    }
  }

  // Hàm đăng nhập người dùng
  // Cập nhật để mong đợi student_id và student_name trong phần 'student_info'
  static Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final url = Uri.parse('$API_BASE_URL/login.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData; // API hy vọng sẽ trả về {status: 'success', message: '...', student_info: {student_id: ..., student_name: ..., username: ...}}
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server khi đăng nhập: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi kết nối khi đăng nhập: $e'};
    }
  }

  // Hàm lấy danh sách các môn học
  static Future<Map<String, dynamic>> getSubjects() async {
    final url = Uri.parse('$API_BASE_URL/subjects.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server khi lấy môn học: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi kết nối khi lấy môn học: $e'};
    }
  }

  // Hàm lấy danh sách units theo subject_id
  static Future<Map<String, dynamic>> getUnitsBySubject(int subjectId) async {
    final url = Uri.parse('$API_BASE_URL/units_by_subject.php?subject_id=$subjectId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server khi lấy units: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi kết nối khi lấy units: $e'};
    }
  }

  // Hàm lấy từ vựng cho bài quiz theo unit_id và số lượng từ tối đa
  static Future<Map<String, dynamic>> getQuizVocabulary(
      int unitId, int maxWords) async {
    final url = Uri.parse('$API_BASE_URL/quiz_vocabulary.php?unit_id=$unitId&max_words=$maxWords');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Lỗi server khi lấy từ vựng: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi kết nối khi lấy từ vựng: $e'};
    }
  }

  // Hàm mới: Lấy từ vựng cá nhân của người dùng (từ file get_user_vocab.php)
  static Future<List<Map<String, dynamic>>> getUserQuizVocabulary(int studentId) async {
    final url = Uri.parse('$API_BASE_URL/get_user_vocab.php?student_id=$studentId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else {
          print('Lỗi từ API getUserQuizVocabulary: ${responseData['message']}');
          return [];
        }
      } else {
        print('Lỗi trạng thái HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Lỗi kết nối hoặc phân tích dữ liệu getUserQuizVocabulary: $e');
      return [];
    }
  }

  // Hàm mới: Lưu kết quả quiz cuối cùng
  static Future<Map<String, dynamic>> saveQuizResults({
    required int studentId,
    required int unitId,
    required int totalQuestionsQuizzed,
    required int correctAnswers,
    required int wrongAnswers,
    required List<Map<String, dynamic>> wrongWords, // List of {'vocabulary_id': id, 'student_answer': 'meaning'}
  }) async {
    final url = Uri.parse('$API_BASE_URL/save_quiz_results.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': studentId,
          'unit_id': unitId,
          'total_questions_quizzed': totalQuestionsQuizzed,
          'correct_answers': correctAnswers,
          'wrong_answers': wrongAnswers,
          'wrong_words': wrongWords,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Lỗi server khi lưu kết quả: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi kết nối khi lưu kết quả: $e'};
    }
  }

  // Hàm mới: Lấy lịch sử dò bài của sinh viên
  static Future<Map<String, dynamic>> getQuizHistory(int studentId) async {
    final url = Uri.parse('$API_BASE_URL/get_quiz_history.php?student_id=$studentId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Lỗi server khi lấy lịch sử: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi kết nối khi lấy lịch sử: $e'};
    }
  }
}