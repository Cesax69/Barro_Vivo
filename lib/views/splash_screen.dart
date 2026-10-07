// lib/views/splash_screen.dart
//
// Pantalla de arranque (Splash) – actualizada HU-02.
//
// Con el guard reactivo del router, esta pantalla solo necesita:
//   1. Mostrar la animación de entrada.
//   2. Llamar a checkSession() del AuthViewModel.
// El router detecta el cambio de estado y redirige automáticamente.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Pantalla de inicio / splash de Barro Vivo.
///
/// Llama a [AuthViewModel.checkSession] y el [GoRouter] se encarga
/// de redirigir al destino correcto vía el guard global.
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Verifica sesión al montar; el router reacciona automáticamente.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().checkSession();
    });
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
