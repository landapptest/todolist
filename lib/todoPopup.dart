import 'package:flutter/material.dart';
import 'home.dart';

import 'package:flutter/material.dart';

class tdPopupScreen extends StatefulWidget {
  final List<String> todoList; // To-Do 리스트
  final Function(String) onAddTodo; // 항목 추가 콜백
  final Function(int, String) onEditTodo; // 항목 수정 콜백
  final Function(int) onDeleteTodo; // 항목 삭제 콜백

  const tdPopupScreen({
    Key? key,
    required this.todoList,
    required this.onAddTodo,
    required this.onEditTodo,
    required this.onDeleteTodo,
  }) : super(key: key);

  @override
  _tdPopupScreenState createState() => _tdPopupScreenState();
}

class _tdPopupScreenState extends State<tdPopupScreen> {
  late List<String> localTodoList; // 로컬 To-Do 리스트
  final TextEditingController _textEditingController = TextEditingController();
  int? editingIndex; // 수정 중인 항목 인덱스

  @override
  void initState() {
    super.initState();
    localTodoList = List.from(widget.todoList); // 수정 가능한 리스트로 초기화
  }

  void _addTodo() {
    if (_textEditingController.text.isNotEmpty) {
      setState(() {
        String newTodo = _textEditingController.text;
        localTodoList.add(newTodo); // 로컬 리스트에 추가
        widget.onAddTodo(newTodo); // 부모 콜백 호출
        _textEditingController.clear(); // 입력 필드 초기화
      });
    }
  }

  void _deleteTodo(int index) {
    setState(() {
      localTodoList.removeAt(index); // 로컬 리스트에서 삭제
      widget.onDeleteTodo(index); // 부모 콜백 호출
    });
  }

  void _editTodo() {
    if (editingIndex != null && _textEditingController.text.isNotEmpty) {
      setState(() {
        localTodoList[editingIndex!] = _textEditingController.text; // 로컬 리스트 수정
        widget.onEditTodo(editingIndex!, _textEditingController.text); // 부모 콜백 호출
        _textEditingController.clear(); // 입력 필드 초기화
        editingIndex = null; // 수정 모드 종료
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        color: Colors.grey[850],
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            const Text(
              'To-Do-List',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // To-Do 리스트
            Expanded(
              child: ListView.builder(
                itemCount: localTodoList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          editingIndex = index; // 수정 모드 설정
                          _textEditingController.text = localTodoList[index]; // 수정할 항목 불러오기
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(80, 255, 53, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.circle, color: Colors.white),
                          title: Text(
                            localTodoList[index],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTodo(index),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 입력 필드 및 추가 버튼
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        hintText: '새로운 할 일을 추가하세요',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  backgroundColor: const Color.fromRGBO(80, 255, 53, 1),
                  onPressed: editingIndex == null ? _addTodo : _editTodo,
                  child: const Icon(Icons.add, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 닫기 버튼
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: const Color.fromRGBO(80, 255, 53, 1),
                child: const Icon(Icons.close, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

