// lib/features/inventario/views/widgets/materia_prima_form_sheet.dart
//
// Formulario en Modal Bottom Sheet para dar de alta o editar materias primas.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_theme.dart';
import '../../models/materia_prima.dart';
import '../../viewmodels/inventario_viewmodel.dart';

class MateriaPrimaFormSheet extends StatefulWidget {
  const MateriaPrimaFormSheet({
    super.key,
    this.materiaPrima,
  });

  /// Si es provisto, el formulario está en modo "Edición".
  /// Si es nulo, está en modo "Creación".
  final MateriaPrima? materiaPrima;

  /// Método estático utilitario para abrir el bottom sheet de forma limpia.
  static Future<bool?> mostrar(
    BuildContext context, {
    MateriaPrima? materiaPrima,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MateriaPrimaFormSheet(materiaPrima: materiaPrima),
    );
  }

  @override
  State<MateriaPrimaFormSheet> createState() => _MateriaPrimaFormSheetState();
}

class _MateriaPrimaFormSheetState extends State<MateriaPrimaFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _stockActualCtrl;
  late final TextEditingController _stockMinimoCtrl;
  late UnidadMedida _unidadSeleccionada;

  bool get _esEdicion => widget.materiaPrima != null;

  @override
  void initState() {
    super.initState();
    final mp = widget.materiaPrima;
    _nombreCtrl = TextEditingController(text: mp?.nombre ?? '');
    _stockActualCtrl = TextEditingController(
      text: mp != null ? _formatearNumero(mp.stockActual) : '',
    );
    _stockMinimoCtrl = TextEditingController(
      text: mp != null ? _formatearNumero(mp.stockMinimo) : '',
    );
    _unidadSeleccionada = mp?.unidad ?? UnidadMedida.kg;
  }

  String _formatearNumero(double valor) {
    if (valor % 1 == 0) return valor.toInt().toString();
    return valor.toString();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _stockActualCtrl.dispose();
    _stockMinimoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<InventarioViewModel>();
    final nombre = _nombreCtrl.text.trim();
    final stockActual = double.tryParse(_stockActualCtrl.text.trim()) ?? 0.0;
    final stockMinimo = double.tryParse(_stockMinimoCtrl.text.trim()) ?? 0.0;

    bool exito;
    if (_esEdicion) {
      final mpModificada = widget.materiaPrima!.copyWith(
        nombre: nombre,
        unidad: _unidadSeleccionada,
        stockActual: stockActual,
        stockMinimo: stockMinimo,
      );
      exito = await vm.actualizarInsumo(mpModificada);
    } else {
      exito = await vm.crearInsumo(
        nombre: nombre,
        unidad: _unidadSeleccionada,
        stockActual: stockActual,
        stockMinimo: stockMinimo,
      );
    }

    if (!mounted) return;

    if (exito) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Materia prima "$nombre" actualizada.'
                : 'Materia prima "$nombre" registrada exitosamente.',
          ),
          backgroundColor: AppColors.cobaltBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Error al guardar la materia prima'),
          backgroundColor: AppColors.terracotta,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicador de arrastre superior
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Encabezado
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cobaltBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _esEdicion ? Icons.edit_note_rounded : Icons.inventory_2_rounded,
                        color: AppColors.cobaltBlue,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _esEdicion ? 'Editar Materia Prima' : 'Nueva Materia Prima',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.cobaltBlue,
                            ),
                          ),
                          Text(
                            _esEdicion
                                ? 'Modifica los datos del insumo'
                                : 'Ingresa los datos para registrar en inventario',
                            style: textTheme.bodySmall?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo: Nombre
                TextFormField(
                  controller: _nombreCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la materia prima *',
                    hintText: 'Ej. Barro rojo de Puebla, Esmalte blanco',
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor escribe el nombre de la materia prima';
                    }
                    if (value.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Campo: Unidad de medida
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unidad de medida *',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<UnidadMedida>(
                      segments: const [
                        ButtonSegment<UnidadMedida>(
                          value: UnidadMedida.kg,
                          label: Text('Kilogramos (kg)'),
                          icon: Icon(Icons.scale_rounded),
                        ),
                        ButtonSegment<UnidadMedida>(
                          value: UnidadMedida.lt,
                          label: Text('Litros (lt)'),
                          icon: Icon(Icons.opacity_rounded),
                        ),
                      ],
                      selected: {_unidadSeleccionada},
                      onSelectionChanged: (Set<UnidadMedida> seleccion) {
                        setState(() {
                          _unidadSeleccionada = seleccion.first;
                        });
                      },
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Fila: Stock Actual y Stock Mínimo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockActualCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Stock actual *',
                          hintText: '0.00',
                          suffixText: _unidadSeleccionada.codigo,
                          prefixIcon: const Icon(Icons.numbers_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el stock';
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed < 0) {
                            return 'Valor no válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _stockMinimoCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Stock mínimo *',
                          hintText: '0.00',
                          suffixText: _unidadSeleccionada.codigo,
                          prefixIcon: const Icon(Icons.warning_amber_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el mínimo';
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed < 0) {
                            return 'Valor no válido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botón Guardar / Actualizar
                Consumer<InventarioViewModel>(
                  builder: (context, vm, _) {
                    return SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cobaltBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: vm.isSaving ? null : _guardar,
                        icon: vm.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(_esEdicion ? Icons.save_rounded : Icons.add_rounded),
                        label: Text(
                          vm.isSaving
                              ? 'Guardando...'
                              : (_esEdicion ? 'Guardar Cambios' : 'Registrar Materia Prima'),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
