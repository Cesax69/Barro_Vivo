// lib/router/app_router.dart
//
// Configuración central de navegación con go_router (Navigator 2.0).
//
// Rutas definidas para HU-01:
//   /          → SplashScreen (evaluación de sesión)
//   /taller    → TallerHomeScreen (placeholder)
//   /cliente   → ClienteHomeScreen (placeholder)
//
// La protección de rutas por rol se implementará en HU-02 una vez que
// [AuthViewModel] exponga el usuario y su rol.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../views/splash_screen.dart';
import '../views/taller/taller_home_screen.dart';
import '../views/cliente/cliente_home_screen.dart';

/// Nombres de ruta centralizados para evitar strings dispersos.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String taller = '/taller';
  static const String cliente = '/cliente';
}

/// Fábrica del [GoRouter] de la aplicación.
///
/// Recibe el [BuildContext] raíz para acceder al [AuthViewModel] inyectado
/// por el [MultiProvider] del Composition Root.
///
/// Uso:
/// ```dart
/// final router = AppRouter.create(context);
/// MaterialApp.router(routerConfig: router);
/// ```
class AppRouter {
  AppRouter._();

  /// Crea y configura el [GoRouter].
  ///
  /// [authViewModel] se utiliza para la lógica de redirección por rol
  /// (se activará completamente en HU-02).
  static GoRouter create(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,

      // ── Redirección global por estado de sesión ───────────────────────────
      // Cuando el usuario no está autenticado, cualquier ruta protegida
      // redirige al splash/login. En HU-02 se expandirá con lógica de rol.
      redirect: (BuildContext context, GoRouterState state) {
        final isAuthenticated = authViewModel.isAuthenticated;

        // Rutas que requieren sesión activa.
        final protectedRoutes = [AppRoutes.taller, AppRoutes.cliente];
        final isProtected = protectedRoutes.contains(state.matchedLocation);

        if (isProtected && !isAuthenticated) {
          // Redirigir al splash/login si no hay sesión.
          return AppRoutes.splash;
        }

        // Sin redirección necesaria.
        return null;
      },

      routes: [
        // ── Raíz / Splash ─────────────────────────────────────────────────
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // ── Área de Taller (artesano / dueño) ─────────────────────────────
        GoRoute(
          path: AppRoutes.taller,
          name: 'taller',
          builder: (context, state) => const TallerHomeScreen(),
        ),

        // ── Área de Cliente (comprador) ───────────────────────────────────
        GoRoute(
          path: AppRoutes.cliente,
          name: 'cliente',
          builder: (context, state) => const ClienteHomeScreen(),
        ),
      ],

      // ── Pantalla de error global ──────────────────────────────────────────
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Ruta no encontrada: ${state.error}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
