// lib/features/inventario/viewmodels/inventario_viewmodel.dart
//
// ViewModel para la gestión de inventario de materias primas – HU-03.
//
// Responsabilidades:
//   – Exponer el estado reactivo del inventario a la UI.
//   – Manejar la carga, creación, actualización y baja lógica de materias primas.
//   – Notificar cambios con notifyListeners() para actualizar la interfaz.
//   – NUNCA importar paquetes de UI (flutter/material.dart).

import 'package:flutter/foundation.dart';

import '../models/materia_prima.dart';
import '../repositories/insumos_repository.dart';

/// Estados posibles de la pantalla o lista de inventario.
enum InventarioStatus {
  /// Estado inicial sin datos cargados.
  initial,

  /// Carga de datos o actualización en proceso.
  loading,

  /// Datos cargados o modificados exitosamente.
  success,

  /// Ocurrió un error en la última operación.
  error,
}

/// ViewModel para la administración de materias primas del taller.
class InventarioViewModel extends ChangeNotifier {
  InventarioViewModel({required InsumosRepository insumosRepository})
      : _repository = insumosRepository;

  final InsumosRepository _repository;

  // ── Estado interno ──────────────────────────────────────────────────────────
  InventarioStatus _status = InventarioStatus.initial;
  List<MateriaPrima> _insumos = [];
  String? _errorMessage;
  bool _isSaving = false;

  // ── Getters públicos ────────────────────────────────────────────────────────
  InventarioStatus get status => _status;
  List<MateriaPrima> get insumos => List.unmodifiable(_insumos);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == InventarioStatus.loading;
  bool get isSaving => _isSaving;
  bool get hasError => _errorMessage != null;
  int get totalInsumos => _insumos.length;

  /// Retorna los insumos cuyo stock está en o por debajo del stock mínimo.
  List<MateriaPrima> get insumosConStockBajo =>
      _insumos.where((i) => i.stockBajo).toList();

  // ── Operaciones de negocio ──────────────────────────────────────────────────

  /// Obtiene la lista actualizada de materias primas activas desde el repositorio.
  Future<void> cargarInsumos() async {
    _status = InventarioStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _insumos = await _repository.getMateriasPrimas();
      _status = InventarioStatus.success;
    } on InsumoException catch (e) {
      _status = InventarioStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = InventarioStatus.error;
      _errorMessage = 'Ocurrió un error inesperado al cargar el inventario: $e';
    } finally {
      notifyListeners();
    }
  }

  /// Registra una nueva materia prima en el inventario.
  ///
  /// Retorna `true` si la creación fue exitosa o `false` en caso de error.
  Future<bool> crearInsumo({
    required String nombre,
    required UnidadMedida unidad,
    required double stockActual,
    required double stockMinimo,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nuevaMateriaPrima = await _repository.crearMateriaPrima(
        nombre: nombre,
        unidad: unidad,
        stockActual: stockActual,
        stockMinimo: stockMinimo,
      );

      // Inserción optimista/inmediata en la lista local ordenada
      _insumos = [..._insumos, nuevaMateriaPrima]
        ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

      _status = InventarioStatus.success;
      _isSaving = false;
      notifyListeners();
      return true;
    } on InsumoException catch (e) {
      _errorMessage = e.message;
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al registrar la materia prima: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Actualiza los datos de una materia prima existente.
  ///
  /// Retorna `true` si la actualización fue exitosa o `false` en caso de error.
  Future<bool> actualizarInsumo(MateriaPrima materiaPrima) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final actualizada = await _repository.actualizarMateriaPrima(materiaPrima);

      final index = _insumos.indexWhere((i) => i.id == actualizada.id);
      if (index != -1) {
        final listaActualizada = List<MateriaPrima>.from(_insumos);
        listaActualizada[index] = actualizada;
        listaActualizada.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
        _insumos = listaActualizada;
      }

      _status = InventarioStatus.success;
      _isSaving = false;
      notifyListeners();
      return true;
    } on InsumoException catch (e) {
      _errorMessage = e.message;
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al actualizar la materia prima: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Da de baja lógica a una materia prima por su ID.
  ///
  /// Retorna `true` si la baja fue exitosa o `false` en caso de error.
  Future<bool> eliminarInsumo(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.darDeBajaMateriaPrima(id);

      // Remover inmediatamente de la lista activa en memoria
      _insumos = _insumos.where((i) => i.id != id).toList();
      _status = InventarioStatus.success;
      notifyListeners();
      return true;
    } on InsumoException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al dar de baja la materia prima: $e';
      notifyListeners();
      return false;
    }
  }

  /// Limpia cualquier mensaje de error activo.
  void limpiarError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
