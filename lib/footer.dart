import 'package:flutter/material.dart';
import 'home.dart';
import 'Profile.dart';
import 'Planner.dart';


class Footer extends StatelessWidget {
  final int selectedIndex; // 현재 선택된 탭의 인덱스
  final Function(int) onTabSelected; // 탭 클릭 시 호출되는 콜백 함수

  const Footer({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Footer is running');
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (int index) {
        onTabSelected(index); // 상위에서 전달된 콜백 실행
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PlannerScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Planer',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.greenAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.black,
    );
  }
}
