import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'footer.dart';
import 'SubjectTimerProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭 인덱스
  String _totalElapsedTime = '00:00:00'; // 총 시간

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

  @override
  Widget build(BuildContext context) {
    final subjectTimerProvider = Provider.of<SubjectTimerProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              const SizedBox(height: 16),

              // 과목 리스트
              const Text(
                '과목 리스트',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subjectTimerProvider.subjects.length,
                itemBuilder: (context, index) {
                  final subjectName = subjectTimerProvider.subjects[index];
                  final elapsedTime =
                      subjectTimerProvider.elapsedTimes[subjectName] ??
                          "00:00:00";

                  return ListTile(
                    title: Text(
                      subjectName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Elapsed: $elapsedTime",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow,
                              color: Colors.greenAccent),
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
}
