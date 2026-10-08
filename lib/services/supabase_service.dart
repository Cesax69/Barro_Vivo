// lib/services/supabase_service.dart
//
// Servicio centralizado de Supabase implementado como Singleton.
//
// ⚠️  Las credenciales de abajo son FICTICIAS (placeholders).
//     Reemplazar con las credenciales reales del proyecto Supabase.
//     En producción deben provenir de variables de entorno.

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración del cliente de Supabase.
class SupabaseService {
  SupabaseService._();

  // ── Credenciales ─────────────────────────────────────────────────────────
  // Permite inyección vía --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // con fallback a placeholders para desarrollo local inicial.
  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xxxxxxxxxxxxxxxxxxx.supabase.co',
  );
  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.PLACEHOLDER',
  );

  /// Acceso directo al [SupabaseClient] después de [initialize()].
  static SupabaseClient get client => Supabase.instance.client;

  /// Inicializa el SDK de Supabase.
  ///
  /// Debe invocarse una sola vez en [main()] antes de [runApp()].
  static Future<void> initialize() async {
    try {
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
    } catch (e) {
      debugPrint('[SupabaseService] Advertencia al inicializar Supabase: $e');
    }
  }
}
