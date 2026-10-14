// lib/features/inventario/views/inventario_screen.dart
//
// Pantalla principal de gestión de inventario de materias primas – HU-03.
// Consume [InventarioViewModel] usando Provider bajo arquitectura MVVM.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../models/materia_prima.dart';
import '../viewmodels/inventario_viewmodel.dart';
import 'widgets/confirmar_baja_dialog.dart';
import 'widgets/materia_prima_card.dart';
import 'widgets/materia_prima_form_sheet.dart';
import 'widgets/resumen_alertas_banner.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  @override
  void initState() {
    super.initState();
    // Carga inicial al montar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventarioViewModel>().cargarInsumos();
    });
  }

  void _abrirFormulario({MateriaPrima? materiaPrima}) {
    MateriaPrimaFormSheet.mostrar(context, materiaPrima: materiaPrima);
  }

  Future<void> _confirmarBaja(MateriaPrima materiaPrima) async {
    final confirmar = await ConfirmarBajaDialog.mostrar(context, materiaPrima);
    if (confirmar == true && mounted) {
      final vm = context.read<InventarioViewModel>();
      final exito = await vm.eliminarInsumo(materiaPrima.id);
      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Se dio de baja "${materiaPrima.nombre}" correctamente.'),
              backgroundColor: AppColors.cobaltBlue,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.errorMessage ?? 'No fue posible dar de baja el insumo.'),
              backgroundColor: AppColors.terracotta,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InventarioViewModel>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Materias Primas'),
        actions: [
          if (vm.tieneAlertasStock)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Badge.count(
                count: vm.totalAlertasStock,
                backgroundColor: const Color(0xFFD32F2F),
                child: IconButton(
                  tooltip: '${vm.totalAlertasStock} alertas activas de stock mínimo',
                  icon: const Icon(Icons.warning_amber_rounded),
                  onPressed: () => vm.toggleFiltroSoloAlertas(),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Recargar inventario',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.isLoading ? null : () => vm.cargarInsumos(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.cobaltBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Materia Prima'),
        onPressed: () => _abrirFormulario(),
      ),
      body: Builder(
        builder: (context) {
          // 1. Estado de carga inicial (pantalla vacía)
          if (vm.isLoading && vm.insumos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.cobaltBlue),
                  SizedBox(height: 16),
                  Text('Cargando inventario del taller...'),
                ],
              ),
            );
          }

          // 2. Estado de error con lista vacía
          if (vm.hasError && vm.insumos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudo conectar al inventario',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.errorMessage ?? 'Ocurrió un error al cargar los datos.',
                      style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.cobaltBlue),
                      onPressed: () => vm.cargarInsumos(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Estado sin materias primas registradas
          if (vm.insumos.isEmpty) {
            return RefreshIndicator(
              color: AppColors.cobaltBlue,
              onRefresh: () => vm.cargarInsumos(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.cobaltBlue.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                size: 54,
                                color: AppColors.cobaltBlue,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Aún no hay materias primas',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.cobaltBlue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Registra arcilla, pigmentos, esmaltes y otros insumos para llevar el control del stock.',
                              style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.cobaltBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _abrirFormulario(),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Registrar Primera Materia Prima'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 4. Lista activa de materias primas con soporte para alertas (HU-04)
          final insumos = vm.insumosVisibles;
          final totalOriginal = vm.totalInsumos;
          final filtrandoSoloAlertas = vm.filtrarSoloAlertas;

          return RefreshIndicator(
            color: AppColors.cobaltBlue,
            onRefresh: () => vm.cargarInsumos(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: (filtrandoSoloAlertas && insumos.isEmpty)
                  ? 2
                  : insumos.length + 1, // +1 para el banner de resumen superior
              itemBuilder: (context, index) {
                // Elemento 0: Componente visual de resumen de alertas (HU-04)
                if (index == 0) {
                  return const ResumenAlertasBanner();
                }

                // Estado vacío cuando el filtro de solo alertas está activo pero no hay alertas
                if (filtrandoSoloAlertas && insumos.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 52,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay insumos en alerta',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Todas las materias primas ($totalOriginal) cumplen con el stock mínimo requerido.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.cobaltBlue,
                              side: const BorderSide(color: AppColors.cobaltBlue),
                            ),
                            onPressed: () => vm.setFiltroSoloAlertas(false),
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('Ver todas las materias primas'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final mp = insumos[index - 1];
                return MateriaPrimaCard(
                  key: ValueKey(mp.id),
                  materiaPrima: mp,
                  onEditar: () => _abrirFormulario(materiaPrima: mp),
                  onDarDeBaja: () => _confirmarBaja(mp),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
