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

          // 4. Lista activa de materias primas
          final insumos = vm.insumos;
          final insumosBajos = vm.insumosConStockBajo;

          return RefreshIndicator(
            color: AppColors.cobaltBlue,
            onRefresh: () => vm.cargarInsumos(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 90),
              itemCount: insumos.length + 1, // +1 para la cabecera con resumen
              itemBuilder: (context, index) {
                // Elemento 0: Tarjeta / Chips de métricas de resumen
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      children: [
                        // Chip: Total insumos
                        Chip(
                          avatar: const Icon(Icons.inventory_2_rounded, size: 16),
                          label: Text(
                            '${insumos.length} ${insumos.length == 1 ? 'materia prima' : 'materias primas'}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        const SizedBox(width: 8),

                        // Chip: Alerta de stock bajo (si hay alguno)
                        if (insumosBajos.isNotEmpty)
                          Chip(
                            avatar: const Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: AppColors.terracotta,
                            ),
                            label: Text(
                              '${insumosBajos.length} con stock bajo',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.terracotta,
                              ),
                            ),
                            backgroundColor: AppColors.terracotta.withValues(alpha: 0.1),
                            side: BorderSide(
                              color: AppColors.terracotta.withValues(alpha: 0.3),
                            ),
                          ),
                      ],
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
