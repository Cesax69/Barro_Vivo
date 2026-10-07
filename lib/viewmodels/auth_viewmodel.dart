// ignore_for_file: prefer_initializing_formals
// lib/viewmodels/auth_viewmodel.dart
//
// ViewModel de autenticación – HU-02.
//
// Responsabilidades:
//   – Exponer el estado de autenticación a la UI (View).
//   – Transformar eventos de la View en llamadas al [AuthRepository].
//   – Exponer errores tipados y específicos por campo.
//   – NUNCA importar paquetes de UI (flutter/material.dart, etc.).
//
// Patrón: MVVM con ChangeNotifier (provider).
// Flujo: View → ViewModel → Repository → Model

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

// ── Estado ────────────────────────────────────────────────────────────────────

/// Estado de la operación asíncrona actual del ViewModel.
enum AuthStatus {
  /// Sin inicializar (estado de arranque).
  initial,

  /// Operación en curso (loading).
  loading,

  /// Usuario autenticado con sesión activa.
  authenticated,

  /// Sin sesión (usuario desconectado o nunca autenticado).
  unauthenticated,

  /// La última operación terminó con error.
  error,
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

/// ViewModel que gestiona el ciclo completo de autenticación.
///
/// La View se suscribe a los cambios con:
/// ```dart
/// context.watch<AuthViewModel>()
/// Consumer<AuthViewModel>(builder: (_, vm, __) => ...)
/// ```
///
/// Expone estado de carga, usuario autenticado, rol y mensajes de error
/// diferenciados por campo para mejorar la UX de los formularios.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // ── Dependencias ─────────────────────────────────────────────────────────
  final AuthRepository _authRepository;

  // ── Estado privado ───────────────────────────────────────────────────────
  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;

  /// Error general (p. ej. fallo de red).
  String? _errorMessage;

  /// Error específico del campo contraseña en el formulario.
  String? _passwordError;

  /// Error específico del campo correo en el formulario.
  /// Regla HU-02: al mostrar error de credenciales NO se borra el correo,
  /// pero sí se puede mostrar un hint en el campo.
  String? _emailError;

  // ── Getters públicos ──────────────────────────────────────────────────────

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;

  /// Mensaje de error general (red, servidor, etc.).
  String? get errorMessage => _errorMessage;

  /// Error específico a mostrar debajo del campo de contraseña.
  String? get passwordError => _passwordError;

  /// Error específico a mostrar debajo del campo de correo.
  String? get emailError => _emailError;

  /// true cuando hay una sesión activa.
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Rol del usuario autenticado, o [null] si no hay sesión.
  UserRole? get currentRole => _currentUser?.role;

  /// true mientras se ejecuta una operación asíncrona.
  bool get isLoading => _status == AuthStatus.loading;

  // ── Comandos públicos ─────────────────────────────────────────────────────

  /// Verifica si existe una sesión válida almacenada (app startup).
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
      _status = AuthStatus.unauthenticated;
      debugPrint('[AuthViewModel] checkSession error: $e');
    }
    notifyListeners();
  }

  /// Inicia sesión con [email] y [password].
  ///
  /// Si falla con credenciales inválidas, conserva el correo del formulario
  /// (no lo borra) y expone el error en [errorMessage] para mostrarlo
  /// sin limpiar el campo de email.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _clearErrors();
    _setLoading();
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
    } on InvalidCredentialsException catch (e) {
      // Error de credenciales: mostramos en campo general,
      // NUNCA borramos el email (regla de UX HU-02).
      _status = AuthStatus.error;
      _errorMessage = e.message;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Ocurrió un error inesperado. Intenta de nuevo.';
      debugPrint('[AuthViewModel] signIn error: $e');
    }
    notifyListeners();
  }

  /// Registra un nuevo usuario con correo, contraseña y rol.
  Future<void> signUp({
    required String email,
    required String password,
    required UserRole role,
    String? displayName,
  }) async {
    _clearErrors();
    _setLoading();
    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        role: role,
        displayName: displayName,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
    } on EmailAlreadyInUseException catch (e) {
      _status = AuthStatus.error;
      _emailError = e.message;
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'No se pudo completar el registro. Intenta de nuevo.';
      debugPrint('[AuthViewModel] signUp error: $e');
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
    } on AuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'No se pudo cerrar la sesión. Intenta de nuevo.';
    }
    notifyListeners();
  }

  /// Limpia los errores manualmente (útil al navegar entre pantallas).
  void clearErrors() {
    _clearErrors();
    notifyListeners();
  }

  // ── Helpers privados ──────────────────────────────────────────────────────

  void _setLoading() {
    _status = AuthStatus.loading;
    notifyListeners();
  }

  void _clearErrors() {
    _errorMessage = null;
    _emailError = null;
    _passwordError = null;
  }
}
