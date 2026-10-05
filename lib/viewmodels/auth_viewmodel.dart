// ignore_for_file: prefer_initializing_formals
// lib/viewmodels/auth_viewmodel.dart
//
// ViewModel de autenticación (capa de presentación).
//
// Responsabilidades:
//   – Exponer el estado de autenticación a la UI (View).
//   – Transformar eventos de la View en llamadas al [AuthRepository].
//   – Nunca construir widgets ni conocer Supabase directamente.
//
// Patrón: MVVM con ChangeNotifier (compatible con el paquete `provider`).

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Estado de carga del ViewModel.
enum AuthStatus {
  /// Estado inicial: sin inicializar.
  initial,

  /// Operación asíncrona en curso.
  loading,

  /// Usuario autenticado correctamente.
  authenticated,

  /// Sin sesión activa.
  unauthenticated,

  /// Ocurrió un error en la última operación.
  error,
}

/// ViewModel que gestiona el estado de autenticación.
///
/// La View escucha los cambios mediante [ChangeNotifier] a través de
/// `context.watch<AuthViewModel>()` o `Consumer<AuthViewModel>`.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // ── Dependencias ─────────────────────────────────────────────────────────
  final AuthRepository _authRepository;

  // ── Estado privado ───────────────────────────────────────────────────────
  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  // ── Getters públicos (solo lectura) ──────────────────────────────────────

  /// Estado actual de la autenticación.
  AuthStatus get status => _status;

  /// Usuario autenticado, o [null] si no hay sesión.
  UserModel? get currentUser => _currentUser;

  /// Mensaje de error de la última operación fallida.
  String? get errorMessage => _errorMessage;

  /// Indica si hay un usuario con sesión activa.
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Comandos públicos (acciones de la View) ───────────────────────────────

  /// Verifica si existe una sesión activa al iniciar la app.
  ///
  /// Invocado desde el Composition Root durante el splash / inicio.
  Future<void> checkSession() async {
    _setLoading();
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _setError('No se pudo verificar la sesión: $e');
    }
    notifyListeners();
  }

  /// Inicia sesión con [email] y [password].
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _setError('Error al iniciar sesión: $e');
    }
    notifyListeners();
  }

  /// Cierra la sesión activa.
  Future<void> signOut() async {
    _setLoading();
    try {
      await _authRepository.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    }
    notifyListeners();
  }

  // ── Helpers privados ─────────────────────────────────────────────────────

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    debugPrint('[AuthViewModel] Error: $message');
  }
}
