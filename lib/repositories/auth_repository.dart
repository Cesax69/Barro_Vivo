// lib/repositories/auth_repository.dart
//
// Capa de acceso a datos para autenticación.
//
// Patrón aplicado: Repository con interfaz abstracta + implementación concreta.
// Los ViewModels dependen SOLO de [AuthRepository] (la abstracción).
// Supabase vive exclusivamente en [SupabaseAuthRepository].

import '../models/user_model.dart';

// ── Interfaz ─────────────────────────────────────────────────────────────────

/// Contrato del repositorio de autenticación.
///
/// Permite sustituir la implementación real por un doble de prueba
/// sin modificar ningún ViewModel.
abstract class AuthRepository {
  /// Devuelve el usuario actualmente autenticado, o [null] si no hay sesión.
  Future<UserModel?> getCurrentUser();

  /// Inicia sesión con correo y contraseña.
  ///
  /// Lanza una [Exception] si las credenciales son inválidas.
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Cierra la sesión activa.
  Future<void> signOut();
}

// ── Implementación concreta (Supabase) ────────────────────────────────────────

/// Implementación de [AuthRepository] que usa Supabase Auth.
///
/// Esta clase es la única que conoce `supabase_flutter`.
/// Los ViewModels reciben una instancia de [AuthRepository] inyectada
/// desde el Composition Root ([main.dart]).
class SupabaseAuthRepository implements AuthRepository {
  // El cliente se inyecta para facilitar las pruebas unitarias.
  // En el Composition Root se pasa [SupabaseService.client].

  @override
  Future<UserModel?> getCurrentUser() async {
    // TODO (HU-02): Implementar consulta real a Supabase Auth + tabla profiles.
    // Por ahora retorna null para indicar "sin sesión".
    return null;
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // TODO (HU-02): Integrar con supabase.auth.signInWithPassword().
    throw UnimplementedError(
      'signIn no implementado aún. Se implementará en HU-02.',
    );
  }

  @override
  Future<void> signOut() async {
    // TODO (HU-02): Integrar con supabase.auth.signOut().
    throw UnimplementedError(
      'signOut no implementado aún. Se implementará en HU-02.',
    );
  }
}
