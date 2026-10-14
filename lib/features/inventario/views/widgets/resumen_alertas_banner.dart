// lib/features/inventario/views/widgets/resumen_alertas_banner.dart
//
// Componente visual de resumen superior para HU-04 (Alertas de stock mínimo).
// Muestra el número de insumos en estado crítico y permite filtrar reactivamente la lista.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/inventario_viewmodel.dart';

class ResumenAlertasBanner extends StatelessWidget {
  const ResumenAlertasBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InventarioViewModel>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final tieneAlertas = vm.tieneAlertasStock;
    final totalAlertas = vm.totalAlertasStock;
    final totalInsumos = vm.totalInsumos;
    final filtrandoSoloAlertas = vm.filtrarSoloAlertas;

    // Si no hay materias primas registradas en general, no se muestra el banner
    if (totalInsumos == 0) {
      return const SizedBox.shrink();
    }

    if (!tieneAlertas) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8F4), // Verde menta suave
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF81C784).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inventario en niveles óptimos',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  Text(
                    'Todas las materias primas ($totalInsumos) superan su stock mínimo.',
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Caso con alertas activas (HU-04)
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F2), // Fondo rojo/terracota sutil
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD32F2F).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge / Indicador numérico circular llamativo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Texto del resumen
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$totalAlertas ${totalAlertas == 1 ? 'alerta activa' : 'alertas activas'}',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFC62828),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Badge contador tipo píldora
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC62828),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$totalAlertas / $totalInsumos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          totalAlertas == 1
                              ? 'Hay 1 insumo en o por debajo de su stock mínimo.'
                              : 'Hay $totalAlertas insumos que requieren reabastecimiento urgente.',
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF5D100C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Botón interactivo para filtrar la lista
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilterChip(
                    avatar: Icon(
                      filtrandoSoloAlertas
                          ? Icons.clear_rounded
                          : Icons.filter_alt_rounded,
                      size: 16,
                      color: filtrandoSoloAlertas
                          ? Colors.white
                          : const Color(0xFFC62828),
                    ),
                    label: Text(
                      filtrandoSoloAlertas
                          ? 'Mostrando solo alertas (Ver todas)'
                          : 'Filtrar solo insumos en alerta',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: filtrandoSoloAlertas
                          ? Colors.white
                          : const Color(0xFFC62828),
                      ),
                    ),
                    selected: filtrandoSoloAlertas,
                    selectedColor: const Color(0xFFC62828),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: filtrandoSoloAlertas
                          ? const Color(0xFFC62828)
                          : const Color(0xFFC62828).withValues(alpha: 0.3),
                    ),
                    onSelected: (_) => vm.toggleFiltroSoloAlertas(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
