import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SujPopup.dart';
import 'todoPopup.dart';
import 'footer.dart';
import 'dart:async';
import 'SubjectTimerProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final subjectTimerProvider =
    Provider.of<SubjectTimerProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: ListView.builder(
        itemCount: subjectTimerProvider.elapsedTimes.keys.length,
        itemBuilder: (context, index) {
          final subjectName = subjectTimerProvider.elapsedTimes.keys.toList()[index];
          final elapsedTime = subjectTimerProvider.elapsedTimes[subjectName] ?? "00:00:00";

          return ListTile(
            title: Text(subjectName),
            subtitle: Text("Elapsed: $elapsedTime"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => subjectTimerProvider.startTimer(subjectName),
                ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () => subjectTimerProvider.stopTimer(subjectName),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => subjectTimerProvider.resetTimer(subjectName),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          subjectTimerProvider.addSubject("New Subject ${subjectTimerProvider.elapsedTimes.length + 1}");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스
  bool _showTodoList = false; // To-Do List 화면 여부
  String _totalElapsedTime = '00:00:00'; // 총 시간
  List<String> _subjects = List.from(["과목 1", "과목 2", "과목 3"]); // 과목 리스트
  List<String> _todoList = List.from(["To-do1", "To-do2", "To-do3"]); // To-Do 리스트
  List<Stopwatch> _subjectStopwatches = []; // 과목별 타이머
  List<Timer?> _subjectTimers = []; // 타이머 관리
  List<String> _subjectTimes = []; // 과목별 시간

  // 탭 선택 이벤트
  void _onTabSelected (int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();
    // 초기 과목 데이터를 기반으로 타이머 초기화
    for (int i = 0; i < _subjects.length; i++) {
      _subjectStopwatches.add(Stopwatch());
      _subjectTimers.add(null);
      _subjectTimes.add('00:00:00');
    }
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

  // 특정 과목 타이머 시작
  void _startSubjectTimer(int index) {
    if (!_subjectStopwatches[index].isRunning) {
      _subjectStopwatches[index].start();
      _subjectTimers[index] = Timer.periodic(const Duration(milliseconds: 100), (_) {
        setState(() {
          _subjectTimes[index] =
              _formatTime(_subjectStopwatches[index].elapsedMilliseconds);
          _updateTotalTime(); // 과목 시간 업데이트 시 총 시간도 갱신
        });
      });
    }
  }

  // 특정 과목 타이머 중지
  void _stopSubjectTimer(int index) {
    if (_subjectStopwatches[index].isRunning) {
      _subjectStopwatches[index].stop();
      _subjectTimers[index]?.cancel();
      _updateTotalTime(); // 과목 시간 중지 시 총 시간도 갱신
    }
  }

  // 총 시간 업데이트
  void _updateTotalTime() {
    int totalMilliseconds = _subjectStopwatches.fold(
      0,
          (sum, stopwatch) => sum + stopwatch.elapsedMilliseconds,
    );

    setState(() {
      _totalElapsedTime = _formatTime(totalMilliseconds);
    });
  }

  // 과목 팝업 띄우기 메서드
  void _showPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return PopupScreen(
          subjects: _subjects,
          onDeleteSubject: (int index) {
            setState(() {
              _subjects.removeAt(index);
              _subjectStopwatches.removeAt(index);
              _subjectTimers.removeAt(index);
              _subjectTimes.removeAt(index);
              _updateTotalTime();
            });
          },
          onAddSubject: (String newSubject) {
            setState(() {
              _subjects.add(newSubject);
              _subjectStopwatches.add(Stopwatch());
              _subjectTimers.add(null);
              _subjectTimes.add('00:00:00');
            });
          },
          onEditSubject: (int index, String newName) {
            if (index >= 0 && index < _subjects.length) {
              setState(() {
                _subjects[index] = newName;
              });
            }
          },
        );
      },
    );
  }

  // To-Do List 관리용 팝업 띄우기
  void _showtodoPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return tdPopupScreen(
          todoList: List.from(_todoList),

          onAddTodo: (newTodo) {
            setState(() {
              _todoList.add(newTodo); // To-Do 항목 추가
            });
          },
          onEditTodo: (index, updatedTodo) {
            setState(() {
              if (index >= 0 && index < _todoList.length) {
                _todoList[index] = updatedTodo; // To-Do 항목 수정
              }
            });
          },
          onDeleteTodo: (index) {
            if (index >= 0 && index < _todoList.length){
              setState(() {
                _todoList.removeAt(index); // To-Do 항목 삭제
              });
            }
          },
        );
      },
    );
  }

/*
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }*/

  @override
  void dispose() {
    for (var timer in _subjectTimers) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 상단 타이머 영역
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromRGBO(80, 255, 53, 1), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 타이머 표시
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
                  Text(
                    '오늘의 진행상황 그래프',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<SubjectTimerProvider>(
                      builder: (context, provider, child) {
                        final progress = provider.progress;
                        return Stack(
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
                              width: MediaQuery.of(context).size.width * progress, // 87% 진행
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color:  Color.fromRGBO(80, 255, 53, 1),
                              ),
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Text(
                                  "${(progress * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                  ),
                  //Divider
                  const SizedBox(height:16),
                  const Divider(color: Colors.greenAccent, thickness: 1),
                ],
              ),
              //const SizedBox(height: 16),



              //관리 버튼
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: _showTodoList ? _showtodoPopup : _showPopup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                      _showTodoList ? "+to-do" : "+과목",
                      style: const TextStyle(color: Colors.white)),
                ),
              ),

              // 동적 콘텐츠 전환
              _showTodoList ? _buildTodoList() : _buildSubjectList(),

              const SizedBox(height: 16),

              // To-Do List 전환 버튼
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showTodoList = !_showTodoList; // To-Do List와 과목 리스트를 전환
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(80, 255, 53, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  _showTodoList ? "과목 보기" : "To-Do List",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  // 과목 리스트 빌드
  Widget _buildSubjectList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[800],
            ),
            child: ListTile(
              leading: IconButton(
                icon: Icon(
                  _subjectStopwatches[index].isRunning
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_subjectStopwatches[index].isRunning) {
                    _stopSubjectTimer(index);
                  } else {
                    _startSubjectTimer(index);
                  }
                },
              ),
              title: Text(
                _subjects[index],
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Text(
                _subjectTimes[index],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  // To-Do 리스트 빌드
  Widget _buildTodoList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _todoList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                // 완료 상태 토글
                _todoList[index] = _todoList[index].contains("(완료)")
                    ? _todoList[index].replaceAll(" (완료)", "")
                    : "${_todoList[index]} (완료)";
              });
            },
            child: Container(
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
                  color: _todoList[index].contains("(완료)")
                      ? Colors.white
                      : Colors.white,
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
          ),
        );
      },
    );
  }
}