import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 회원가입
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException에 따른 에러 처리
      switch (e.code) {
        case 'email-already-in-use':
          print("이미 사용 중인 이메일입니다.");
          break;
        case 'invalid-email':
          print("잘못된 이메일 형식입니다.");
          break;
        case 'weak-password':
          print("비밀번호가 너무 약합니다.");
          break;
        default:
          print("회원가입 실패: ${e.message}");
      }
      return null;
    } catch (e) {
      // 기타 예상치 못한 에러 처리
      print("예상치 못한 오류: $e");
      return null;
    }
  }

  // 로그인
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException에 따른 에러 처리
      switch (e.code) {
        case 'user-not-found':
          print("사용자를 찾을 수 없습니다.");
          break;
        case 'wrong-password':
          print("잘못된 비밀번호입니다.");
          break;
        case 'invalid-email':
          print("잘못된 이메일 형식입니다.");
          break;
        default:
          print("로그인 실패: ${e.message}");
      }
      return null;
    } catch (e) {
      // 기타 예상치 못한 에러 처리
      print("예상치 못한 오류: $e");
      return null;
    }
  }
}
