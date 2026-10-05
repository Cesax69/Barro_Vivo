// lib/services/supabase_service.dart
//
// Servicio centralizado de Supabase implementado como Singleton.
// Los ViewModels y Repositorios NO instancian Supabase directamente;
// obtienen el cliente a través de [SupabaseService.client].
//
// ⚠️  Las credenciales de abajo son FICTICIAS (placeholders).
//     En producción deben provenir de variables de entorno o de un
//     archivo .env ignorado por git (p. ej. usando el paquete `envied`).

import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración del cliente de Supabase.
///
/// Inicializar llamando a [SupabaseService.initialize()] antes de
/// ejecutar [runApp()].
class SupabaseService {
  SupabaseService._();

  // ── Credenciales (placeholders) ─────────────────────────────────────────
  // TODO: Reemplazar con las credenciales reales del proyecto Supabase.
  //       Nunca incluir credenciales reales en control de versiones.
  static const String _supabaseUrl = 'https://xxxxxxxxxxxxxxxxxxx.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.PLACEHOLDER';

  // ── Singleton ────────────────────────────────────────────────────────────

  /// Acceso directo al [SupabaseClient] después de [initialize()].
  static SupabaseClient get client => Supabase.instance.client;

  /// Inicializa el SDK de Supabase.
  ///
  /// Debe invocarse una sola vez en [main()] antes de [runApp()].
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
      // Habilitar la persistencia de sesión local.
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      // Nivel de log: solo errores en producción.
      debug: false,
    );
  }
}
