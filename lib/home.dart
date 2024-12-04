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
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스
  bool _showTodoList = false; // To-Do List 화면 여부
  String _totalElapsedTime = '00:00:00'; // 총 시간
  List<String> _subjects = []; // 과목 리스트

  @override
  void initState() {
    super.initState();
    final subjectTimerProvider =
    Provider.of<SubjectTimerProvider>(context, listen: false);

    // 기존 데이터 가져오기
    _subjects = subjectTimerProvider.subjects;
    _updateTotalTime();
  }

  @override
  void dispose() {
    final subjectTimerProvider =
    Provider.of<SubjectTimerProvider>(context, listen: false);

    // 화면 전환 시 타이머 정리
    for (var subject in _subjects) {
      subjectTimerProvider.stopTimer(subject);
    }
    super.dispose();
  }

  // 탭 선택 이벤트
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
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

  // 특정 과목 타이머 시작
  void _startSubjectTimer(int index) {
    final subjectName = _subjects[index];
    final subjectTimerProvider =
    Provider.of<SubjectTimerProvider>(context, listen: false);

    subjectTimerProvider.startTimer(subjectName);
    _updateTotalTime();
  }

  // 특정 과목 타이머 중지
  void _stopSubjectTimer(int index) {
    final subjectName = _subjects[index];
    final subjectTimerProvider =
    Provider.of<SubjectTimerProvider>(context, listen: false);

    subjectTimerProvider.stopTimer(subjectName);
    _updateTotalTime();
  }

  // 과목 팝업 띄우기 메서드
  void _showPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return PopupScreen(
          subjects: _subjects,
          onDeleteSubject: (int index) {
            final subjectTimerProvider =
            Provider.of<SubjectTimerProvider>(context, listen: false);

            setState(() {
              subjectTimerProvider.resetTimer(_subjects[index]);
              _subjects.removeAt(index);
            });
            _updateTotalTime();
          },
          onAddSubject: (String newSubject) {
            final subjectTimerProvider =
            Provider.of<SubjectTimerProvider>(context, listen: false);

            setState(() {
              _subjects.add(newSubject);
              subjectTimerProvider.addSubject(newSubject);
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
                            width: MediaQuery.of(context).size.width * progress,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromRGBO(80, 255, 53, 1),
                            ),
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
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
                    },
                  ),
                  const Divider(color: Colors.greenAccent, thickness: 1),
                ],
              ),
              _buildSubjectList(),
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

  Widget _buildSubjectList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subjectName = _subjects[index];
        final elapsedTime =
            Provider.of<SubjectTimerProvider>(context).elapsedTimes[subjectName] ??
                "00:00:00";

        return ListTile(
          title: Text(subjectName),
          subtitle: Text("Elapsed: $elapsedTime"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => _startSubjectTimer(index),
              ),
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () => _stopSubjectTimer(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
