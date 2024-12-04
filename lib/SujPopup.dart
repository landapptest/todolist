import 'package:flutter/material.dart';

class PopupScreen extends StatefulWidget {
  final List<String> subjects; // 과목 리스트
  final Function(int) onDeleteSubject; // 과목 삭제 콜백
  final Function(String) onAddSubject; // 과목 추가 콜백
  final Function(int, String) onEditSubject; // 과목 수정 콜백

  const PopupScreen({
    Key? key,
    required this.subjects,
    required this.onDeleteSubject,
    required this.onEditSubject,
    required this.onAddSubject,
  }) : super(key: key);

  @override
  _PopupScreenState createState() => _PopupScreenState();
}

class _PopupScreenState extends State<PopupScreen> {
  late List<String> localSubjects;
  int? editingIndex; // 현재 수정 중인 과목 인덱스
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    localSubjects = List.from(widget.subjects); // 초기 리스트 복사
  }

  void _addSubject() {
    setState(() {
      String newSubject = '새 과목 ${widget.subjects.length + 1}';
      widget.onAddSubject(newSubject); // 부모 화면에 새 과목 전달
      localSubjects.add(newSubject); // 로컬 리스트에 추가
    });
  }

  void _deleteSubject(int index) {
    setState(() {
      localSubjects.removeAt(index);
    });
    widget.onDeleteSubject(index); // 부모에 삭제 이벤트 전달
  }

  void _startEditing(int index) {
    setState(() {
      editingIndex = index;
      _textEditingController.text = localSubjects[index];
    });
  }

  void _saveEditing(int index) {
    setState(() {
      localSubjects[index] = _textEditingController.text;
      editingIndex = null;
    });
    widget.onEditSubject(index, _textEditingController.text); // 부모에 수정 이벤트 전달
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        color: Colors.grey[850],
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '과목',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: localSubjects.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _deleteSubject(index),
                    ),
                    title: editingIndex == index
                        ? TextField(
                      controller: _textEditingController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.greenAccent),
                        ),
                      ),
                      onSubmitted: (_) => _saveEditing(index),
                    )
                        : GestureDetector(
                      onTap: () => _startEditing(index),
                      child: Text(
                        localSubjects[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    trailing: editingIndex == index
                        ? IconButton(
                      icon: const Icon(Icons.check, color: Colors.greenAccent),
                      onPressed: () => _saveEditing(index),
                    )
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addSubject,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(80, 255, 53, 1),
              ),
              child: const Text('추가하기', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              backgroundColor: const Color.fromRGBO(80, 255, 53, 1),
              child: const Icon(Icons.close, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
