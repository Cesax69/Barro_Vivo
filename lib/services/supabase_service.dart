// lib/services/supabase_service.dart
//
// Servicio centralizado de Supabase implementado como Singleton.
//
// ⚠️  Las credenciales de abajo son FICTICIAS (placeholders).
//     Reemplazar con las credenciales reales del proyecto Supabase.
//     En producción deben provenir de variables de entorno.

import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración del cliente de Supabase.
class SupabaseService {
  SupabaseService._();

  // ── Credenciales ─────────────────────────────────────────────────────────
  // TODO: Reemplazar con las credenciales reales del proyecto Supabase.
  static const String _supabaseUrl = 'https://xxxxxxxxxxxxxxxxxxx.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.PLACEHOLDER';

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
