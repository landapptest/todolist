import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'footer.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage; // 프로필 이미지
  int _selectedIndex = 2; // 현재 선택된 탭 (Profile)

  // Firebase에서 현재 로그인된 사용자 이메일 가져오기
  String get _email => FirebaseAuth.instance.currentUser?.email ?? 'No Email';

  // 이미지 선택
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path); // 선택된 이미지를 File로 저장
      });
    }
  }

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
      body: Center( // 화면 중앙 정렬
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 세로 방향 중앙 정렬
          crossAxisAlignment: CrossAxisAlignment.center, // 가로 방향 중앙 정렬
          children: [
            // 프로필 이미지
            GestureDetector(
              onTap: _pickImage, // 이미지 선택
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey,
                backgroundImage:
                _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.add_a_photo, color: Colors.white, size: 30)
                    : null, // 이미지가 없으면 아이콘 표시
              ),
            ),
            const SizedBox(height: 20),

            // 이메일 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[800],
              ),
              child: const Text(
                "example@email.com", // 이메일은 Firebase Auth 등에서 가져와야 함
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex, // 현재 선택된 탭
        onTabSelected: _onTabSelected, // 탭 선택 이벤트 처리
      ),
    );
  }
}

