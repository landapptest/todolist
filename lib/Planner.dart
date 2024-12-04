import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'footer.dart';
import 'SubjectTimerProvider.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  int _selectedIndex = 1; // 현재 선택된 탭 인덱스
  final String dailyQuote = "오늘 걸어야 내일 뛰지 않는다."; // 오늘의 한마디
  final List<Map<String, dynamic>> _subjects = [
    {"name": "과목 1", "time": "00:00:00", "subTasks": []},
    {"name": "과목 2", "time": "00:00:00", "subTasks": []},
  ];

  // 탭 전환 이벤트
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Custom Header
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: const Color.fromRGBO(80, 255, 53, 1),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getFormattedDate(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "TODAY TOTAL 00:00:00",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(
                  color: Color.fromRGBO(80, 255, 53, 1),
                  thickness: 1.0,
                ),
                const SizedBox(height: 10),
                Text(
                  dailyQuote,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  return _buildSubjectCard(index);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(80, 255, 53, 1),
        onPressed: _addSubject,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex, // 현재 선택된 탭
        onTabSelected: _onTabSelected, // 탭 전환 이벤트 처리
      ),
    );
  }

  Widget _buildSubjectCard(int index) {
    return Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Subject Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _subjects[index]['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  _subjects[index]['time'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            const Divider(color: Colors.white, thickness: 1),
            // Subtask List
            Column(
              children: List.generate(_subjects[index]['subTasks'].length, (subIndex) {
                return _buildSubTask(index, subIndex);
              }),
            ),
            // Add Subtask Button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  _addSubTask(index);
                },
                icon: const Icon(Icons.add, color: Colors.greenAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTask(int subjectIndex, int subIndex) {
    bool isCompleted = _subjects[subjectIndex]['subTasks'][subIndex]['completed'];
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.circle,
            color: isCompleted ? Colors.green : Colors.white,
          ),
          onPressed: () {
            setState(() {
              _subjects[subjectIndex]['subTasks'][subIndex]['completed'] =
              !isCompleted;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _editSubTask(subjectIndex, subIndex);
            },
            child: Text(
              _subjects[subjectIndex]['subTasks'][subIndex]['name'],
              style: TextStyle(
                color: Colors.white,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _deleteSubTask(subjectIndex, subIndex);
          },
        ),
      ],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekday = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];
    return "${now.year}. ${now.month.toString().padLeft(2, '0')}. ${now.day.toString().padLeft(2, '0')} ${weekday[now.weekday - 1]}";
  }

  void _addSubject() {
    setState(() {
      _subjects.add({"name": "새 과목", "time": "00:00:00", "subTasks": []});
    });
  }

  void _addSubTask(int subjectIndex) {
    setState(() {
      _subjects[subjectIndex]['subTasks'].add({"name": "새로운 할 일", "completed": false});
    });
  }

  void _editSubTask(int subjectIndex, int subIndex) {
    TextEditingController controller = TextEditingController(
        text: _subjects[subjectIndex]['subTasks'][subIndex]['name']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("할 일 수정"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _subjects[subjectIndex]['subTasks'][subIndex]['name'] =
                      controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSubTask(int subjectIndex, int subIndex) {
    setState(() {
      _subjects[subjectIndex]['subTasks'].removeAt(subIndex);
    });
  }
}
