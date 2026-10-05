// lib/views/splash_screen.dart
//
// Pantalla de arranque (Splash).
// Verifica la sesión y redirige al área correspondiente según el rol.
// En HU-01 actúa como pantalla inicial que valida la sesión dummy.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Pantalla de inicio / splash de Barro Vivo.
///
/// Muestra el logotipo mientras se verifica si existe una sesión activa.
/// Al terminar la verificación redirige a:
///   – [AppRoutes.taller]  si el rol es [UserRole.taller].
///   – [AppRoutes.cliente] si el rol es [UserRole.cliente].
///   – Permanece aquí (futuro login) si no hay sesión.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Animación de entrada del logotipo.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Verificar sesión al montar la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  Future<void> _checkSession() async {
    final authVM = context.read<AuthViewModel>();
    await authVM.checkSession();

    if (!mounted) return;

    // Redirigir según estado de autenticación y rol.
    if (authVM.isAuthenticated && authVM.currentUser != null) {
      switch (authVM.currentUser!.role) {
        case UserRole.taller:
          context.go(AppRoutes.taller);
        case UserRole.cliente:
          context.go(AppRoutes.cliente);
      }
    }
    // Si no hay sesión, permanece en la pantalla (aquí irá el login en HU-02).
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cobaltBlue,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono representativo del taller (placeholder visual).
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Barro Vivo',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Talavería Artesanal',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 0.8,
                    ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
