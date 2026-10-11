// test/features/inventario/inventario_viewmodel_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:barro_vivo/features/inventario/models/materia_prima.dart';
import 'package:barro_vivo/features/inventario/repositories/insumos_repository.dart';
import 'package:barro_vivo/features/inventario/viewmodels/inventario_viewmodel.dart';

class _FakeInsumosRepo implements InsumosRepository {
  final List<MateriaPrima> _db = [];

  @override
  Future<List<MateriaPrima>> getMateriasPrimas() async {
    return _db.where((m) => m.activo).toList();
  }

  @override
  Future<MateriaPrima> crearMateriaPrima({
    required String nombre,
    required UnidadMedida unidad,
    required double stockActual,
    required double stockMinimo,
  }) async {
    final nueva = MateriaPrima(
      id: 'id_${_db.length + 1}',
      nombre: nombre,
      unidad: unidad,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      activo: true,
    );
    _db.add(nueva);
    return nueva;
  }

  @override
  Future<MateriaPrima> actualizarMateriaPrima(MateriaPrima materiaPrima) async {
    final index = _db.indexWhere((m) => m.id == materiaPrima.id);
    if (index != -1) {
      _db[index] = materiaPrima;
      return materiaPrima;
    }
    throw const InsumoNotFoundException();
  }

  @override
  Future<void> darDeBajaMateriaPrima(String id) async {
    final index = _db.indexWhere((m) => m.id == id);
    if (index != -1) {
      _db[index] = _db[index].copyWith(activo: false);
    }
  }
}

void main() {
  group('InventarioViewModel HU-03 Tests', () {
    late _FakeInsumosRepo repo;
    late InventarioViewModel vm;

    setUp(() {
      repo = _FakeInsumosRepo();
      vm = InventarioViewModel(insumosRepository: repo);
    });

    test('Estado inicial debe estar vacío', () {
      expect(vm.status, InventarioStatus.initial);
      expect(vm.insumos, isEmpty);
      expect(vm.totalInsumos, 0);
    });

    test('Crear materia prima debe agregarla reactivamente a la lista', () async {
      final exito = await vm.crearInsumo(
        nombre: 'Barro rojo',
        unidad: UnidadMedida.kg,
        stockActual: 25.0,
        stockMinimo: 10.0,
      );

      expect(exito, isTrue);
      expect(vm.totalInsumos, 1);
      expect(vm.insumos.first.nombre, 'Barro rojo');
      expect(vm.insumos.first.unidad, UnidadMedida.kg);
      expect(vm.insumos.first.stockBajo, isFalse);
    });

    test('Detecta stock bajo si stockActual <= stockMinimo', () async {
      await vm.crearInsumo(
        nombre: 'Esmalte azul cobalto',
        unidad: UnidadMedida.lt,
        stockActual: 2.0,
        stockMinimo: 5.0,
      );

      expect(vm.insumosConStockBajo.length, 1);
      expect(vm.insumos.first.stockBajo, isTrue);
    });

    test('Actualizar materia prima modifica los valores de inmediato', () async {
      await vm.crearInsumo(
        nombre: 'Arcilla blanca',
        unidad: UnidadMedida.kg,
        stockActual: 50.0,
        stockMinimo: 15.0,
      );

      final original = vm.insumos.first;
      final modificada = original.copyWith(stockActual: 10.0);

      final exito = await vm.actualizarInsumo(modificada);
      expect(exito, isTrue);
      expect(vm.insumos.first.stockActual, 10.0);
      expect(vm.insumos.first.stockBajo, isTrue);
    });

    test('Eliminar insumo aplica baja lógica y lo retira de la lista activa', () async {
      await vm.crearInsumo(
        nombre: 'Pigmento amarillo',
        unidad: UnidadMedida.kg,
        stockActual: 8.0,
        stockMinimo: 2.0,
      );

      final id = vm.insumos.first.id;
      final exito = await vm.eliminarInsumo(id);

      expect(exito, isTrue);
      expect(vm.insumos, isEmpty);
      expect(vm.totalInsumos, 0);
    });
  });
}
