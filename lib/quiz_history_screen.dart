import 'package:flutter/material.dart';
import 'package:my_quiz_game/api_service.dart';
import 'package:my_quiz_game/models/app_models.dart';
import 'package:intl/intl.dart'; // Thêm để định dạng ngày giờ


class QuizHistoryScreen extends StatefulWidget {
  final int studentId; // studentId của người dùng hiện tại

  const QuizHistoryScreen({super.key, required this.studentId});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  List<QuizHistory> _history = []; // Danh sách lịch sử dò bài
  bool _isLoading = true;          // Trạng thái loading
  String _errorMessage = '';       // Thông báo lỗi nếu có

  @override
  void initState() {
    super.initState();
    _loadQuizHistory(); // Tải lịch sử khi màn hình được khởi tạo
  }

  // Hàm để tải lịch sử dò bài từ API
  Future<void> _loadQuizHistory() async {
    setState(() {
      _isLoading = true; // Bắt đầu tải, hiển thị loading
      _errorMessage = ''; // Xóa thông báo lỗi cũ
    });

    // Gọi API để lấy lịch sử dò bài của studentId
    final response = await ApiService.getQuizHistory(widget.studentId);

    if (mounted) { // Đảm bảo widget vẫn còn tồn tại trong cây widget
      if (response['status'] == 'success' && response['data'] != null) {
        setState(() {
          // Chuyển đổi dữ liệu JSON thành danh sách các đối tượng QuizHistory
          _history = (response['data'] as List)
              .map((json) => QuizHistory.fromJson(json))
              .toList();
          _isLoading = false; // Tải xong, ẩn loading
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Không thể tải lịch sử dò bài.';
          _isLoading = false; // Tải xong (có lỗi), ẩn loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Dò Bài'),
      ),
      body: _isLoading // Nếu đang tải, hiển thị CircularProgressIndicator
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty // Nếu có lỗi, hiển thị thông báo lỗi
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : _history.isEmpty // Nếu không có lịch sử, hiển thị thông báo
                  ? const Center(
                      child: Text(
                        'Bạn chưa có lịch sử dò bài nào.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder( // Nếu có lịch sử, hiển thị danh sách
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final record = _history[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Môn: ${record.subjectName} - Unit: ${record.unitName}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  // Định dạng ngày giờ cho dễ đọc
                                  'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(record.quizDate))}',
                                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tổng số từ: ${record.totalQuestionsQuizzed}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Đúng: ${record.correctAnswers}',
                                      style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      'Sai: ${record.wrongAnswers}',
                                      style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                // Chỉ hiển thị phần từ sai nếu có từ sai
                                if (record.wrongWordsDetails.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Từ đã làm sai:',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                                  ),
                                  const SizedBox(height: 5),
                                  // Hiển thị danh sách từ sai chi tiết
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: record.wrongWordsDetails.map((word) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                        child: Text(
                                          '- ${word.englishWord}: ${word.correctMeaning}', // Hiển thị từ tiếng Anh và nghĩa đúng
                                          style: const TextStyle(fontSize: 15, color: Colors.red),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}