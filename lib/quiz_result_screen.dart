import 'package:flutter/material.dart';
import 'package:my_quiz_game/models/app_models.dart'; // <-- ĐÃ THAY ĐỔI: IMPORT CÁC MODELS TỪ ĐÂY

class QuizResultScreen extends StatelessWidget {
  final int studentId;
  final List<VocabularyWord> wrongWords; // Danh sách các từ đã làm sai
  final int totalWordsQuizzed;

  const QuizResultScreen({
    super.key,
    required this.studentId,
    required this.wrongWords,
    required this.totalWordsQuizzed,
  });

  @override
  Widget build(BuildContext context) {
    int correctAnswers = totalWordsQuizzed - wrongWords.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết Quả Dò Từ Vựng'),
        automaticallyImplyLeading: false, // Ẩn nút back
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Bạn đã hoàn thành bài dò từ vựng!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Tổng số từ: $totalWordsQuizzed',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Số từ đúng: $correctAnswers',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            Text(
              'Số từ sai: ${wrongWords.length}',
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 30),

            if (wrongWords.isNotEmpty)
              const Text(
                'Các từ bạn đã làm sai:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            if (wrongWords.isNotEmpty)
              const SizedBox(height: 10),

            Expanded(
              child: wrongWords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                          SizedBox(height: 10),
                          Text(
                            'Chúc mừng! Bạn đã làm đúng tất cả các từ!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, color: Colors.green),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: wrongWords.length,
                      itemBuilder: (context, index) {
                        final word = wrongWords[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              word.englishWord,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text('Đáp án đúng: ${word.correctMeaning}'),
                            leading: const Icon(Icons.close, color: Colors.red),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Quay về màn hình HomeScreen
                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Quay về trang chủ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}