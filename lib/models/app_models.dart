// lib/models/app_models.dart

// Model cho Subject (Môn học)
class Subject {
  final int id;
  final String name;

  Subject({required this.id, required this.name});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: int.parse(json['subject_id'].toString()),
      name: json['subject_name'],
    );
  }
}

// Model cho Unit (Bài học)
class Unit {
  final int id;
  final String name;

  Unit({required this.id, required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: int.parse(json['unit_id'].toString()),
      name: json['unit_name'],
    );
  }
}

// Model cho VocabularyWord (Từ vựng) - Dùng trong màn hình dò bài
class VocabularyWord {
  final int id;
  final String englishWord;
  final String correctMeaning;
  final List<String> options;

  VocabularyWord({
    required this.id,
    required this.englishWord,
    required this.correctMeaning,
    required this.options,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: int.parse(json['vocabulary_id'].toString()),
      englishWord: json['english_word'],
      correctMeaning: json['correct_meaning'],
      // Đảm bảo 'options' là một List<String>
      options: List<String>.from(json['options']),
    );
  }

  // Override hashCode và == để loại bỏ các từ trùng lặp khi hiển thị kết quả (nếu cần)
  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyWord &&
          runtimeType == other.runtimeType &&
          id == other.id;
}

// Model cho WrongWordDetail (Chi tiết từ đã làm sai) - Dùng trong lịch sử dò bài
class WrongWordDetail {
  final int vocabularyId;
  final String englishWord;
  final String correctMeaning;

  WrongWordDetail({
    required this.vocabularyId,
    required this.englishWord,
    required this.correctMeaning,
  });

  factory WrongWordDetail.fromJson(Map<String, dynamic> json) {
    return WrongWordDetail(
      vocabularyId: int.parse(json['vocabulary_id'].toString()),
      englishWord: json['english_word'],
      correctMeaning: json['correct_meaning'],
    );
  }
}

// Model cho QuizHistory (Một bản ghi lịch sử dò bài tổng thể)
class QuizHistory {
  final int attemptId;
  final String quizDate; // Thời gian dò bài (có thể chuyển thành DateTime nếu muốn xử lý chi tiết hơn)
  final int correctAnswers; // Số từ đúng
  final int wrongAnswers;   // Số từ sai
  final int totalQuestionsQuizzed; // Tổng số từ đã dò
  final String unitName;    // Tên Unit của bài dò
  final String subjectName; // Tên môn học của bài dò
  final List<WrongWordDetail> wrongWordsDetails; // Danh sách chi tiết các từ đã làm sai

  QuizHistory({
    required this.attemptId,
    required this.quizDate,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestionsQuizzed,
    required this.unitName,
    required this.subjectName,
    required this.wrongWordsDetails,
  });

  factory QuizHistory.fromJson(Map<String, dynamic> json) {
    // Xử lý trường 'wrong_words_details' có thể là null hoặc rỗng từ API
    var wrongWordsList = json['wrong_words_details'];
    List<WrongWordDetail> details = [];
    if (wrongWordsList is List) { // Đảm bảo nó là một List
      details = wrongWordsList
          .map((e) => WrongWordDetail.fromJson(e))
          .toList();
    }

    return QuizHistory(
      attemptId: int.parse(json['attempt_id'].toString()),
      quizDate: json['quiz_date'],
      correctAnswers: int.parse(json['correct_answers'].toString()),
      wrongAnswers: int.parse(json['wrong_answers'].toString()),
      totalQuestionsQuizzed: int.parse(json['total_questions_quizzed'].toString()),
      unitName: json['unit_name'],
      subjectName: json['subject_name'],
      wrongWordsDetails: details,
    );
  }
}