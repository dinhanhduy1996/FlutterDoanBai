import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_quiz_game/api_service.dart'; // Đảm bảo đường dẫn đúng
import 'package:my_quiz_game/vocabulary_quiz_screen.dart'; // Màn hình quiz theo Unit
import 'package:my_quiz_game/models/app_models.dart'; // Đảm bảo đường dẫn đúng đến các models của bạn
import 'package:my_quiz_game/quiz_history_screen.dart'; // Import màn hình lịch sử
import 'package:my_quiz_game/auth_screen.dart'; // Import AuthScreen để navigate khi logout

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _welcomeMessage = 'Chào mừng!';
  int? _studentId; // Để lưu student_id của người dùng đang đăng nhập
  String? _studentName; // Để lưu student_name của người dùng đang đăng nhập

  List<Subject> _subjects = [];
  Subject? _selectedSubject; // Vẫn giữ là Subject?

  List<Unit> _units = []; // Danh sách Units
  Unit? _selectedUnit; // Unit đang được chọn

  final TextEditingController _maxWordsController = TextEditingController();
  int _maxWords = 10; // Mặc định số từ tối đa là 10

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadSubjects();
    _maxWordsController.text = _maxWords.toString(); // Thiết lập giá trị mặc định cho textbox
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final studentName = prefs.getString('studentName'); // Lấy từ 'studentName'
    final id = prefs.getInt('studentId'); // Lấy từ 'studentId'

    if (mounted) {
      setState(() {
        _welcomeMessage = 'Chào mừng ${studentName ?? username}!';
        _studentId = id; // Lưu studentId
        _studentName = studentName; // Lưu studentName
      });
    }
  }

  Future<void> _loadSubjects() async {
    final response = await ApiService.getSubjects();
    if (mounted) {
      if (response['status'] == 'success' && response['data'] != null) {
        setState(() {
          _subjects = (response['data'] as List)
              .map((json) => Subject.fromJson(json))
              .toList();

          // Sửa lỗi ở đây:
          // Tìm môn "Tiếng Anh" nếu có, nếu không thì lấy môn đầu tiên (nếu có),
          // còn không thì để null.
          if (_subjects.isNotEmpty) {
            _selectedSubject = _subjects.firstWhere(
              (subject) => subject.name.toLowerCase() == 'tiếng anh',
              orElse: () => _subjects.first, // Nếu không tìm thấy "Tiếng Anh", chọn môn đầu tiên
            );
          } else {
            _selectedSubject = null; // Nếu không có môn nào, để null
          }

          if (_selectedSubject != null) {
            _loadUnits(_selectedSubject!.id); // Tải units của môn đã chọn
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Không thể tải môn học.')),
        );
      }
    }
  }

  // Hàm mới: Tải danh sách Units theo Subject ID
  Future<void> _loadUnits(int subjectId) async {
    final response = await ApiService.getUnitsBySubject(subjectId);
    if (mounted) {
      setState(() {
        _units = []; // Xóa danh sách units cũ
        _selectedUnit = null; // Bỏ chọn unit cũ
      });

      if (response['status'] == 'success' && response['data'] != null) {
        setState(() {
          _units = (response['data'] as List)
              .map((json) => Unit.fromJson(json))
              .toList();
          if (_units.isNotEmpty) {
            _selectedUnit = _units.first; // Chọn unit đầu tiên làm mặc định
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Không thể tải units cho môn này.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ học sinh'),
        backgroundColor: Colors.blueAccent, // Thêm màu cho AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.history), // Nút lịch sử dò bài
            onPressed: () {
              if (_studentId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizHistoryScreen(studentId: _studentId!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không thể tải lịch sử. Vui lòng đăng nhập lại.')),
                );
              }
            },
            tooltip: 'Lịch sử dò bài',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Xóa tất cả dữ liệu đăng nhập
              if (mounted) {
                // Quay về màn hình đăng nhập và xóa tất cả các màn hình trước đó
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()), // Chuyển về màn hình AuthScreen
                  (Route<dynamic> route) => false, // Xóa tất cả các route trước đó
                );
              }
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _welcomeMessage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Phần chọn môn học và unit cho Quiz chung
            const Text(
              'Dò bài theo Unit:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 15),

            const Text(
              'Chọn môn học:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Subject>(
                  isExpanded: true,
                  value: _selectedSubject,
                  hint: const Text('Chọn một môn học'),
                  onChanged: (Subject? newValue) {
                    setState(() {
                      _selectedSubject = newValue;
                      if (newValue != null) {
                        _loadUnits(newValue.id); // Tải units khi chọn môn mới
                      }
                    });
                  },
                  items: _subjects.map<DropdownMenuItem<Subject>>((Subject subject) {
                    return DropdownMenuItem<Subject>(
                      value: subject,
                      child: Text(subject.name),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown cho Units
            const Text(
              'Chọn Unit (Bài học):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Unit>(
                  isExpanded: true,
                  value: _selectedUnit,
                  hint: _selectedSubject == null
                      ? const Text('Vui lòng chọn môn học trước')
                      : _units.isEmpty
                          ? const Text('Không có Unit nào cho môn này')
                          : const Text('Chọn một Unit'),
                  onChanged: (Unit? newValue) {
                    setState(() {
                      _selectedUnit = newValue;
                    });
                  },
                  items: _units.isNotEmpty
                      ? _units.map<DropdownMenuItem<Unit>>((Unit unit) {
                          return DropdownMenuItem<Unit>(
                            value: unit,
                            child: Text(unit.name),
                          );
                        }).toList()
                      : [],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // TextField cho số từ tối đa
            const Text(
              'Số từ tối đa để dò:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _maxWordsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nhập số từ (ví dụ: 10)',
              ),
              onChanged: (value) {
                setState(() {
                  _maxWords = int.tryParse(value) ?? 10; // Cập nhật _maxWords
                });
              },
            ),
            const SizedBox(height: 40),

            // Nút "Dò Bài" (quiz theo unit)
            Center(
              child: ElevatedButton(
                onPressed: _selectedUnit != null && _maxWords > 0 && _studentId != null
                    ? () async {
                        // Lấy từ vựng cho bài dò
                        final quizData = await ApiService.getQuizVocabulary(_selectedUnit!.id, _maxWords);

                        if (mounted) {
                          if (quizData['status'] == 'success' && quizData['data'] != null) {
                            List<VocabularyWord> quizWords = (quizData['data'] as List)
                                .map((json) => VocabularyWord.fromJson(json))
                                .toList();

                            if (quizWords.isNotEmpty) {
                              // Chuyển sang màn hình dò từ vựng
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VocabularyQuizScreen(
                                      studentId: _studentId!,
                                      words: quizWords,
                                      unitName: _selectedUnit!.name,
                                      unitId: _selectedUnit!.id, // Truyền unitId
                                    ),
                                  ),
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không có từ vựng nào để dò trong Unit này.')),
                                );
                              }
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(quizData['message'] ?? 'Không thể tải từ vựng dò bài.')),
                              );
                            }
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Bắt Đầu Dò Bài'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _maxWordsController.dispose();
    super.dispose();
  }
}