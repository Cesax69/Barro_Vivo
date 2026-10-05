// lib/views/taller/taller_home_screen.dart
//
// Pantalla de inicio del área de Taller (artesano / dueño).
// PLACEHOLDER – HU-01: solo muestra la estructura base.
// El contenido real se implementará en historias de usuario posteriores.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../router/app_router.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Pantalla principal del área de Taller.
///
/// Accesible solo para usuarios con rol [UserRole.taller].
/// La protección de ruta se gestiona en [AppRouter].
class TallerHomeScreen extends StatelessWidget {
  const TallerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barro Vivo – Taller'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await context.read<AuthViewModel>().signOut();
              if (context.mounted) context.go(AppRoutes.splash);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido al Taller!',
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.cobaltBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Módulo en construcción. Las funcionalidades del '
              'taller se implementarán en las próximas HU.',
              style: textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 32),

            // Tarjeta informativa del usuario actual (debug)
            if (authVM.currentUser != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_rounded,
                      color: AppColors.cobaltBlue),
                  title: Text(authVM.currentUser!.email),
                  subtitle: Text('Rol: ${authVM.currentUser!.role.name}'),
                ),
              ),

            const Spacer(),

            // Placeholder de acciones futuras
            ElevatedButton.icon(
              onPressed: null, // se habilitará en HUs posteriores
              icon: const Icon(Icons.inventory_2_rounded),
              label: const Text('Gestionar Inventario (próximamente)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('Ver Reportes (próximamente)'),
            ),
          ],
        ),
      ),
    );
  }
}
