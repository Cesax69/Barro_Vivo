// lib/features/inventario/views/widgets/materia_prima_card.dart
//
// Tarjeta reactiva para representar una materia prima en el listado de inventario.

import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../models/materia_prima.dart';

class MateriaPrimaCard extends StatelessWidget {
  const MateriaPrimaCard({
    super.key,
    required this.materiaPrima,
    required this.onEditar,
    required this.onDarDeBaja,
  });

  final MateriaPrima materiaPrima;
  final VoidCallback onEditar;
  final VoidCallback onDarDeBaja;

  String _formatearNumero(double valor) {
    if (valor % 1 == 0) return valor.toInt().toString();
    return valor.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final esBajo = materiaPrima.stockBajo;
    const colorAlertaRojo = Color(0xFFD32F2F);
    const colorAlertaFondo = Color(0xFFFFF4F2);

    return Card(
      elevation: esBajo ? 1 : 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: esBajo
              ? colorAlertaRojo
              : Colors.grey.shade200,
          width: esBajo ? 1.8 : 1,
        ),
      ),
      color: esBajo ? colorAlertaFondo : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner superior destacado en rojo si está en o por debajo del stock mínimo (HU-04)
          if (esBajo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: colorAlertaRojo.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                border: Border(
                  bottom: BorderSide(
                    color: colorAlertaRojo.withValues(alpha: 0.25),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: colorAlertaRojo,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'ALERTA: STOCK MÍNIMO ALCANZADO',
                    style: TextStyle(
                      color: colorAlertaRojo,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorAlertaRojo,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Faltan ${_formatearNumero(materiaPrima.deficitStock)} ${materiaPrima.unidad.codigo}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: Nombre, Badge de unidad y menú de acciones
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícono de categoría con marcado en rojo si está en alerta
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: esBajo
                            ? colorAlertaRojo.withValues(alpha: 0.15)
                            : AppColors.cobaltBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        materiaPrima.unidad == UnidadMedida.kg
                            ? Icons.scale_rounded
                            : Icons.opacity_rounded,
                        color: esBajo ? colorAlertaRojo : AppColors.cobaltBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                // Título y etiqueta de unidad
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materiaPrima.nombre,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Unidad: ${materiaPrima.unidad.etiqueta} (${materiaPrima.unidad.codigo})',
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Menú de acciones (Editar / Dar de baja)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.black54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'editar') {
                      onEditar();
                    } else if (value == 'baja') {
                      onDarDeBaja();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20, color: AppColors.cobaltBlue),
                          SizedBox(width: 10),
                          Text('Editar datos'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'baja',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red.shade700),
                          const SizedBox(width: 10),
                          Text('Dar de baja', style: TextStyle(color: Colors.red.shade700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Fila central: Stock actual vs Stock mínimo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esBajo
                    ? AppColors.terracotta.withValues(alpha: 0.08)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stock actual
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock actual',
                        style: textTheme.labelSmall?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatearNumero(materiaPrima.stockActual),
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: esBajo ? colorAlertaRojo : AppColors.cobaltBlue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            materiaPrima.unidad.codigo,
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: esBajo ? colorAlertaRojo : AppColors.cobaltBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Divisor vertical
                  Container(
                    height: 32,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),

                  // Stock mínimo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock mínimo',
                        style: textTheme.labelSmall?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatearNumero(materiaPrima.stockMinimo),
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            materiaPrima.unidad.codigo,
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Banner o chip de advertencia si el stock es bajo
            if (esBajo) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorAlertaRojo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorAlertaRojo.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      size: 16,
                      color: colorAlertaRojo,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Stock bajo: requiere reabastecimiento urgente',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorAlertaRojo,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  ),
);
  }
}
