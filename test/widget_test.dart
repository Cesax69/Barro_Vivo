import 'package:flutter_test/flutter_test.dart';

import 'package:barro_vivo/main.dart';
import 'package:barro_vivo/models/user_model.dart';
import 'package:barro_vivo/repositories/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required UserRole role,
    String? displayName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('Barro Vivo smoke test', (WidgetTester tester) async {
    final fakeRepo = _FakeAuthRepository();
    await tester.pumpWidget(BarroVivoApp(authRepository: fakeRepo));

    expect(find.text('Barro Vivo'), findsOneWidget);
    expect(find.text('Talavería Artesanal'), findsOneWidget);
  });
}

