import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SujPopup.dart';
import 'todoPopup.dart';
import 'footer.dart';
import 'SubjectTimerProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스
  bool _showTodoList = false; // To-Do List 화면 여부
  String _totalElapsedTime = '00:00:00'; // 총 시간
  List<String> _todoList = ["To-do1", "To-do2", "To-do3"]; // To-Do 리스트

  @override
  void initState() {
    super.initState();
    _updateTotalTime();
  }

  @override
  void dispose() {
    final subjectTimerProvider =
    Provider.of<SubjectTimerProvider>(context, listen: false);
    for (var subject in subjectTimerProvider.subjects) {
      subjectTimerProvider.stopTimer(subject); // 타이머 정리
    }
    super.dispose();
  }

  // 총 시간 업데이트
  void _updateTotalTime() {
    final subjectTimerProvider =
    Provider.of<SubjectTimerProvider>(context, listen: false);

    int totalMilliseconds = subjectTimerProvider.elapsedTimes.values.fold(
      0,
          (sum, elapsedTime) {
        final parts = elapsedTime.split(":");
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return sum +
            Duration(hours: hours, minutes: minutes, seconds: seconds)
                .inMilliseconds;
      },
    );

    setState(() {
      _totalElapsedTime = _formatTime(totalMilliseconds);
    });
  }

  // 시간을 형식화하는 메서드
  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  // 과목 팝업 띄우기 메서드
  void _showPopup() {
    final subjectTimerProvider =
    Provider.of<SubjectTimerProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return PopupScreen(
          subjects: subjectTimerProvider.subjects,
          onDeleteSubject: (int index) {
            setState(() {
              subjectTimerProvider.resetTimer(
                  subjectTimerProvider.subjects[index]);
              subjectTimerProvider.deleteSubject(index);
            });
            _updateTotalTime();
          },
          onAddSubject: (String newSubject) {
            setState(() {
              subjectTimerProvider.addSubject(newSubject);
            });
          },
          onEditSubject: (int index, String newName) {
            setState(() {
              subjectTimerProvider.editSubject(index, newName);
            });
          },
        );
      },
    );
  }

  // To-Do 팝업 띄우기 메서드
  void _showTodoPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return tdPopupScreen(
          todoList: List.from(_todoList),
          onAddTodo: (newTodo) {
            setState(() {
              _todoList.add(newTodo); // To-Do 추가
            });
          },
          onEditTodo: (index, updatedTodo) {
            setState(() {
              if (index >= 0 && index < _todoList.length) {
                _todoList[index] = updatedTodo; // To-Do 수정
              }
            });
          },
          onDeleteTodo: (index) {
            setState(() {
              if (index >= 0 && index < _todoList.length) {
                _todoList.removeAt(index); // To-Do 삭제
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectTimerProvider = Provider.of<SubjectTimerProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 상단 타이머 영역
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromRGBO(80, 255, 53, 1), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "전체 시간",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      _totalElapsedTime,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(80, 255, 53, 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 진행 상황 그래프
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 진행상황 그래프',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey[700],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width *
                            subjectTimerProvider.progress,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromRGBO(80, 255, 53, 1),
                        ),
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "${(subjectTimerProvider.progress * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.greenAccent, thickness: 1),
                ],
              ),

              // 과목 리스트 or To-Do List
              _showTodoList ? _buildTodoList() : _buildSubjectList(),

              // 전환 버튼
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showTodoList = !_showTodoList;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                ),
                child: Text(
                  _showTodoList ? "과목 보기" : "To-Do 보기",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  // 과목 리스트
  Widget _buildSubjectList() {
    final subjectTimerProvider =
    Provider.of<SubjectTimerProvider>(context, listen: true);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: subjectTimerProvider.subjects.length,
      itemBuilder: (context, index) {
        final subjectName = subjectTimerProvider.subjects[index];
        final elapsedTime =
            subjectTimerProvider.elapsedTimes[subjectName] ?? "00:00:00";

        return ListTile(
          title: Text(subjectName, style: const TextStyle(color: Colors.white)),
          subtitle: Text("Elapsed: $elapsedTime"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.greenAccent),
                onPressed: () {
                  subjectTimerProvider.startTimer(subjectName);
                },
              ),
              IconButton(
                icon: const Icon(Icons.pause, color: Colors.red),
                onPressed: () {
                  subjectTimerProvider.stopTimer(subjectName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // To-Do 리스트
  Widget _buildTodoList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _todoList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _todoList[index] = _todoList[index].contains("(완료)")
                  ? _todoList[index].replaceAll(" (완료)", "")
                  : "${_todoList[index]} (완료)";
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _todoList[index].contains("(완료)")
                  ? Colors.grey[800]
                  : const Color.fromRGBO(80, 255, 53, 1),
            ),
            child: ListTile(
              leading: Icon(
                _todoList[index].contains("(완료)")
                    ? Icons.check_circle
                    : Icons.circle,
                color: Colors.white,
              ),
              title: Text(
                _todoList[index],
                style: TextStyle(
                  color: _todoList[index].contains("(완료)")
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
