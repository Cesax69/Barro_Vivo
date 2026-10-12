import 'package:flutter_test/flutter_test.dart';

import 'package:barro_vivo/main.dart';
import 'package:barro_vivo/models/user_model.dart';
import 'package:barro_vivo/repositories/auth_repository.dart';

import 'package:barro_vivo/features/inventario/models/materia_prima.dart';
import 'package:barro_vivo/features/inventario/repositories/insumos_repository.dart';

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

class _FakeInsumosRepository implements InsumosRepository {
  @override
  Future<List<MateriaPrima>> getMateriasPrimas() async => [];

  @override
  Future<MateriaPrima> crearMateriaPrima({
    required String nombre,
    required UnidadMedida unidad,
    required double stockActual,
    required double stockMinimo,
  }) async =>
      throw UnimplementedError();

  @override
  Future<MateriaPrima> actualizarMateriaPrima(MateriaPrima materiaPrima) async =>
      throw UnimplementedError();

  @override
  Future<void> darDeBajaMateriaPrima(String id) async {}
}

void main() {
  testWidgets('Barro Vivo smoke test', (WidgetTester tester) async {
    final fakeAuth = _FakeAuthRepository();
    final fakeInsumos = _FakeInsumosRepository();

    await tester.pumpWidget(
      BarroVivoApp(
        authRepository: fakeAuth,
        insumosRepository: fakeInsumos,
      ),
    );

    expect(find.text('Barro Vivo'), findsOneWidget);
    expect(find.text('Talavería Artesanal'), findsOneWidget);
  });
}

