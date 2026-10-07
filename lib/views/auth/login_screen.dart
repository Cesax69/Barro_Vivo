// lib/views/auth/login_screen.dart
//
// Pantalla de inicio de sesión – HU-02.
//
// Reglas de UX documentadas:
//   – Si ocurre error de credenciales, el campo de correo NO se borra.
//   – Se muestra un banner de error específico bajo el formulario.
//   – Botones con altura mínima de 48 dp (accesibilidad WCAG 2.1 AA).
//   – Validación de formato de correo antes de llamar al ViewModel.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../router/app_router.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Los controladores se mantienen vivos para NO perder el texto del correo
  // cuando se produce un error de autenticación (regla HU-02).
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Acción de inicio de sesión ────────────────────────────────────────────

  Future<void> _submit() async {
    // Cierra el teclado.
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<AuthViewModel>();

    await vm.signIn(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    // Redirección manejada por el guard del router; aquí solo limpiamos
    // la contraseña si el login fue exitoso.
    if (vm.isAuthenticated) {
      _passwordCtrl.clear();
      // El router escucha al AuthViewModel y redirige automáticamente.
    }
    // Si hubo error, el correo permanece intacto (regla HU-02).
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Encabezado ──────────────────────────────────────────────
                _Header(textTheme: textTheme),
                const SizedBox(height: 40),

                // ── Formulario ──────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Campo correo
                      TextFormField(
                        key: const Key('login-email-field'),
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa tu correo electrónico.';
                          }
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(v.trim())) {
                            return 'Formato de correo no válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo contraseña
                      TextFormField(
                        key: const Key('login-password-field'),
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa tu contraseña.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // ── Banner de error (credenciales inválidas, red, etc.)
                      // Regla HU-02: se muestra el error pero el correo
                      // permanece en el campo sin modificaciones.
                      if (vm.status == AuthStatus.error &&
                          vm.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        _ErrorBanner(message: vm.errorMessage!),
                      ],

                      const SizedBox(height: 28),

                      // Botón principal – mínimo 48 dp de altura.
                      ElevatedButton(
                        key: const Key('login-submit-btn'),
                        onPressed: vm.isLoading ? null : _submit,
                        child: vm.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Iniciar sesión'),
                      ),

                      const SizedBox(height: 16),

                      // Botón secundario – ir a registro.
                      OutlinedButton(
                        key: const Key('login-register-btn'),
                        onPressed: vm.isLoading
                            ? null
                            : () {
                                context.read<AuthViewModel>().clearErrors();
                                context.go(AppRoutes.registro);
                              },
                        child: const Text('Crear una cuenta'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.textTheme});
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.cobaltBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            size: 44,
            color: AppColors.cobaltBlue,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Barro Vivo',
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.cobaltBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Inicia sesión para continuar',
          style: textTheme.bodyLarge?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.terracotta.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.terracotta, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.terracotta,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


