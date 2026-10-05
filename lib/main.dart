// lib/main.dart
//
// ══════════════════════════════════════════════════════════════════════════════
// COMPOSITION ROOT – Barro Vivo (HU-01)
// ══════════════════════════════════════════════════════════════════════════════
//
// Responsabilidades de este archivo:
//   1. Inicializar Supabase antes de levantar la UI.
//   2. Construir el árbol de dependencias (MultiProvider) inyectando:
//      – Repositorios concretos (implementaciones de las interfaces).
//      – ViewModels que reciben los repositorios por constructor.
//   3. Arrancar la app con MaterialApp.router usando GoRouter y el tema global.
//
// Flujo: View → ViewModel → Repository → Model
// Ningún widget conoce Supabase directamente.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'repositories/auth_repository.dart';
import 'router/app_router.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';

Future<void> main() async {
  // Garantiza que los bindings de Flutter estén listos antes de
  // ejecutar código asíncrono (p. ej. inicialización de Supabase).
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Inicializar Supabase (Singleton) ────────────────────────────────
  // En producción las credenciales vendrán de variables de entorno.
  await SupabaseService.initialize();

  // ── 2. Construir las dependencias de la capa de datos ──────────────────
  // Los repositorios concretos se crean aquí y se inyectan hacia arriba.
  final AuthRepository authRepository = SupabaseAuthRepository();

  // ── 3. Levantar la aplicación ──────────────────────────────────────────
  runApp(BarroVivoApp(authRepository: authRepository));
}

/// Raíz de la aplicación Barro Vivo.
///
/// Configura el [MultiProvider] global con todos los ViewModels
/// y arranca la UI mediante [MaterialApp.router].
class BarroVivoApp extends StatefulWidget {
  const BarroVivoApp({
    super.key,
    required this.authRepository,
  });

  /// Repositorio de autenticación inyectado desde [main].
  final AuthRepository authRepository;

  @override
  State<BarroVivoApp> createState() => _BarroVivoAppState();
}

class _BarroVivoAppState extends State<BarroVivoApp> {
  // El ViewModel se crea aquí para que el GoRouter pueda escucharlo
  // y recalcular las redirecciones cuando el estado cambie.
  late final AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel(authRepository: widget.authRepository);
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ── Árbol de dependencias (Composition Root) ─────────────────────────
      // Orden: primero los repositorios, luego los ViewModels que los usan.
      providers: [
        // ── Capa de Repositorios ──────────────────────────────────────────
        Provider<AuthRepository>.value(value: widget.authRepository),

        // ── Capa de ViewModels ────────────────────────────────────────────
        // Se usa ChangeNotifierProvider para que los widgets puedan
        // suscribirse y reconstruirse cuando el estado cambia.
        ChangeNotifierProvider<AuthViewModel>.value(value: _authViewModel),
      ],
      child: _AppRouter(authViewModel: _authViewModel),
    );
  }
}

/// Widget interno que construye el [GoRouter] y el [MaterialApp.router].
///
/// Se separa en su propio widget para que [AppRouter.create] reciba
/// el [AuthViewModel] ya inicializado (evita el problema de
/// "context used before initialization").
class _AppRouter extends StatefulWidget {
  const _AppRouter({required this.authViewModel});

  final AuthViewModel authViewModel;

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.create(widget.authViewModel);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ── Metadatos de la app ─────────────────────────────────────────────
      title: 'Barro Vivo',
      debugShowCheckedModeBanner: false,

      // ── Tema global (Material Design 3) ─────────────────────────────────
      theme: AppTheme.light(),

      // ── Navegación (Navigator 2.0 via GoRouter) ──────────────────────────
      routerConfig: _router,
    );
  }
}
