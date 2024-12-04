import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';

class SubjectTimerProvider with ChangeNotifier {
  final List<String> _subjects = ["과목 1", "과목 2", "과목 3"]; // 기본 과목 리스트 추가
  final Map<String, Stopwatch> _timers = {}; // 과목별 타이머
  final Map<String, String> _elapsedTimes = {}; // 과목별 경과 시간
  final Map<String, Timer?> _updateTimers = {}; // 주기적으로 업데이트되는 타이머
  late SharedPreferences _prefs; // SharedPreferences 저장소

  // Getter
  Map<String, String> get elapsedTimes => _elapsedTimes; // 경과 시간 반환
  List<String> get subjects => List.unmodifiable(_subjects); // 과목 리스트 반환

  // 진행상황 계산 (progress)
  double get progress {
    if (_elapsedTimes.isEmpty) return 0.0;
    // Custom logic for progress calculation can go here
    return 1.0;
  }

  // SharedPreferences 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedTimers(); // 저장된 타이머 로드

    // 기존에 저장된 데이터가 없으면 기본 과목 초기화
    if (_subjects.isEmpty) {
      for (var subject in ["과목 1", "과목 2", "과목 3"]) {
        addSubject(subject);
      }
    }
  }

  // 저장된 타이머 로드
  void _loadSavedTimers() {
    final savedTimesJson = _prefs.getString('elapsedTimes');
    if (savedTimesJson != null) {
      final savedTimes = json.decode(savedTimesJson) as Map<String, dynamic>;
      savedTimes.forEach((subjectName, elapsedTime) {
        _timers[subjectName] = Stopwatch(); // 타이머 초기화
        _elapsedTimes[subjectName] = elapsedTime; // 저장된 시간 불러오기
        if (!_subjects.contains(subjectName)) {
          _subjects.add(subjectName); // 과목 리스트 추가
        }
      });
    }
    notifyListeners();
  }

  // 과목 추가
  void addSubject(String subjectName) {
    if (!_timers.containsKey(subjectName)) {
      _timers[subjectName] = Stopwatch();
      _elapsedTimes[subjectName] = "00:00:00";
      _subjects.add(subjectName); // 과목 리스트에 추가
      _saveTimers();
      notifyListeners();
    }
  }

  // 과목 삭제
  void deleteSubject(int index) {
    if (index >= 0 && index < _subjects.length) {
      final subjectName = _subjects[index];
      _timers.remove(subjectName);
      _elapsedTimes.remove(subjectName);
      _subjects.removeAt(index);
      _saveTimers();
      notifyListeners();
    }
  }

  // 과목 이름 수정
  void editSubject(int index, String newName) {
    if (index >= 0 && index < _subjects.length) {
      final oldName = _subjects[index];
      if (oldName != newName) {
        // 데이터 업데이트
        _timers[newName] = _timers.remove(oldName)!;
        _elapsedTimes[newName] = _elapsedTimes.remove(oldName)!;
        _subjects[index] = newName;
        _saveTimers();
        notifyListeners();
      }
    }
  }

  // 타이머 시작
  void startTimer(String subjectName) {
    if (_timers.containsKey(subjectName)) {
      final stopwatch = _timers[subjectName]!;
      if (!stopwatch.isRunning) {
        stopwatch.start();
        _updateTimers[subjectName] = Timer.periodic(
          const Duration(seconds: 1),
              (_) => _updateElapsedTime(subjectName),
        );
      }
      notifyListeners();
    }
  }

  // 타이머 중지
  void stopTimer(String subjectName) {
    if (_timers.containsKey(subjectName)) {
      final stopwatch = _timers[subjectName]!;
      if (stopwatch.isRunning) {
        stopwatch.stop();
        _updateTimers[subjectName]?.cancel();
        _saveTimers();
        notifyListeners();
      }
    }
  }

  // 타이머 초기화
  void resetTimer(String subjectName) {
    if (_timers.containsKey(subjectName)) {
      _timers[subjectName]!.reset();
      _elapsedTimes[subjectName] = "00:00:00";
      _updateTimers[subjectName]?.cancel();
      _saveTimers();
      notifyListeners();
    }
  }

  // 경과 시간 업데이트
  void _updateElapsedTime(String subjectName) {
    if (_timers.containsKey(subjectName)) {
      final elapsed = _timers[subjectName]!.elapsed;
      _elapsedTimes[subjectName] = _formatDuration(elapsed);
      notifyListeners();
    }
  }

  // 경과 시간 저장
  void _saveTimers() {
    final savedTimes = _elapsedTimes.map((key, value) => MapEntry(key, value));
    final savedTimesJson = json.encode(savedTimes);
    _prefs.setString('elapsedTimes', savedTimesJson);
  }

  // 시간 형식 변환
  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _updateTimers.values.forEach((timer) => timer?.cancel());
    super.dispose();
  }
}
