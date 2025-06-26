import 'package:flutter/material.dart';
import 'package:my_quiz_game/api_service.dart'; // Đảm bảo đường dẫn đúng
import 'package:my_quiz_game/quiz_result_screen.dart'; // Đảm bảo đường dẫn đúng
import 'package:my_quiz_game/models/app_models.dart'; // Đảm bảo đường dẫn đúng đến models của bạn

class VocabularyQuizScreen extends StatefulWidget {
  final int studentId;
  final List<VocabularyWord> words; // Danh sách từ vựng để dò
  final String unitName;
  final int unitId; // Thêm unitId để lưu vào lịch sử

  const VocabularyQuizScreen({
    Key? key, // Sửa super.key thành Key? key
    required this.studentId,
    required this.words,
    required this.unitName,
    required this.unitId, // Bắt buộc phải có unitId
  }) : super(key: key); // Sửa super(key: key)

  @override
  State<VocabularyQuizScreen> createState() => _VocabularyQuizScreenState();
}

class _VocabularyQuizScreenState extends State<VocabularyQuizScreen> {
  int _currentWordIndex = 0; // Index của từ hiện tại đang hiển thị
  String? _selectedOption; // Đáp án người dùng chọn
  int _correctCount = 0; // Số câu trả lời đúng
  final List<Map<String, dynamic>> _wrongWordsForApi = []; // Danh sách các từ sai để gửi lên API
  final List<VocabularyWord> _wrongWordsForDisplay = []; // Danh sách các từ sai để hiển thị trên màn hình kết quả

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Dò Từ Vựng - ${widget.unitName}')),
        body: const Center(child: Text('Không có từ vựng để dò.')),
      );
    }

    final currentWord = widget.words[_currentWordIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dò Từ Vựng - ${widget.unitName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${_currentWordIndex + 1}/${widget.words.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Từ tiếng Anh
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Text(
                  currentWord.englishWord,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Các đáp án
            Expanded(
              child: ListView.builder(
                itemCount: currentWord.options.length,
                itemBuilder: (context, index) {
                  final option = currentWord.options[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: _selectedOption == null // Chỉ cho phép chọn 1 lần
                          ? () {
                              setState(() {
                                _selectedOption = option;
                              });
                              _handleAnswer(currentWord, option); // Xử lý đáp án ngay lập tức
                            }
                          : null, // Vô hiệu hóa nút sau khi đã chọn
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: _getOptionColor(option),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm để xác định màu cho nút đáp án (cho phép người dùng thấy đúng/sai)
  Color _getOptionColor(String option) {
    final currentWord = widget.words[_currentWordIndex];
    if (_selectedOption == null) {
      return Colors.blueGrey; // Màu mặc định khi chưa chọn
    } else if (option == _selectedOption) {
      if (option == currentWord.correctMeaning) {
        return Colors.green; // Đáp án đúng được chọn
      } else {
        return Colors.red; // Đáp án sai được chọn
      }
    } else if (_selectedOption != null && option == currentWord.correctMeaning) {
      // Hiện đáp án đúng sau khi người dùng đã chọn (nếu chọn sai)
      return Colors.green.withOpacity(0.5); // Làm mờ để phân biệt với đáp án được chọn
    }
    return Colors.blueGrey.withOpacity(0.7); // Làm mờ các đáp án không liên quan
  }

  // Hàm xử lý khi người dùng chọn đáp án
  Future<void> _handleAnswer(VocabularyWord word, String chosenMeaning) async {
    bool isCorrect = (chosenMeaning == word.correctMeaning);

    if (isCorrect) {
      _correctCount++;
    } else {
      _wrongWordsForApi.add({
        'vocabulary_id': word.id,
        'student_answer': chosenMeaning,
      });
      _wrongWordsForDisplay.add(word); // Thêm vào danh sách hiển thị
    }

    // Chờ một chút để người dùng nhìn thấy kết quả
    await Future.delayed(const Duration(milliseconds: 800));

    // Chuyển sang từ tiếp theo hoặc kết thúc bài dò
    if (mounted) {
      _moveToNextWord();
    }
  }

  // Hàm chuyển sang từ tiếp theo
  void _moveToNextWord() async {
    if (_currentWordIndex < widget.words.length - 1) {
      setState(() {
        _currentWordIndex++;
        _selectedOption = null; // Reset lựa chọn cho từ mới
      });
    } else {
      // Hết bài dò, lưu kết quả và chuyển đến màn hình kết quả
      final int totalWords = widget.words.length;
      final int wrongCount = _wrongWordsForApi.length;

      // Gọi API để lưu kết quả
      final saveResponse = await ApiService.saveQuizResults(
        studentId: widget.studentId,
        unitId: widget.unitId, // Truyền unitId từ HomeScreen
        totalQuestionsQuizzed: totalWords,
        correctAnswers: _correctCount,
        wrongAnswers: wrongCount,
        wrongWords: _wrongWordsForApi,
      );

      if (mounted) {
        if (saveResponse['status'] == 'success') {
          // Chuyển đến màn hình kết quả
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizResultScreen(
                studentId: widget.studentId,
                wrongWords: _wrongWordsForDisplay.toSet().toList(), // Loại bỏ các từ trùng lặp
                totalWordsQuizzed: totalWords,
              ),
            ),
          );
        } else {
          // Hiển thị lỗi nếu không lưu được kết quả
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(saveResponse['message'] ?? 'Lỗi khi lưu kết quả bài dò.')),
          );
          // Vẫn chuyển đến màn hình kết quả nhưng cảnh báo lỗi lưu
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizResultScreen(
                studentId: widget.studentId,
                wrongWords: _wrongWordsForDisplay.toSet().toList(),
                totalWordsQuizzed: totalWords,
              ),
            ),
          );
        }
      }
    }
  }
}