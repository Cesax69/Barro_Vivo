// lib/features/inventario/views/widgets/confirmar_baja_dialog.dart
//
// Diálogo de confirmación para dar de baja lógica una materia prima.

import 'package:flutter/material.dart';
import '../../models/materia_prima.dart';

class ConfirmarBajaDialog extends StatelessWidget {
  const ConfirmarBajaDialog({
    super.key,
    required this.materiaPrima,
  });

  final MateriaPrima materiaPrima;

  /// Método estático utilitario para mostrar el diálogo.
  static Future<bool?> mostrar(BuildContext context, MateriaPrima materiaPrima) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmarBajaDialog(materiaPrima: materiaPrima),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Dar de baja',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                height: 1.4,
              ),
          children: [
            const TextSpan(text: '¿Deseas dar de baja la materia prima '),
            TextSpan(
              text: '"${materiaPrima.nombre}"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text: '?\n\nEl insumo dejará de mostrarse en el inventario activo del taller.',
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar', style: TextStyle(color: Colors.black54)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Dar de baja'),
        ),
      ],
    );
  }
}
