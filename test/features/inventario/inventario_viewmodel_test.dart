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

  group('InventarioViewModel HU-04 Alertas de Stock Mínimo Tests', () {
    late _FakeInsumosRepo repo;
    late InventarioViewModel vm;

    setUp(() {
      repo = _FakeInsumosRepo();
      vm = InventarioViewModel(insumosRepository: repo);
    });

    test('Estado inicial no tiene alertas y contador es 0', () {
      expect(vm.totalAlertasStock, 0);
      expect(vm.tieneAlertasStock, isFalse);
      expect(vm.materiasPrimasEnAlerta, isEmpty);
      expect(vm.insumosConStockBajo, isEmpty);
      expect(vm.filtrarSoloAlertas, isFalse);
    });

    test('Evalúa reactivamente insumos comparando stockActual con stockMinimo', () async {
      await vm.crearInsumo(
        nombre: 'Barro rojo',
        unidad: UnidadMedida.kg,
        stockActual: 20.0,
        stockMinimo: 10.0,
      );
      await vm.crearInsumo(
        nombre: 'Esmalte blanco',
        unidad: UnidadMedida.lt,
        stockActual: 5.0,
        stockMinimo: 5.0, // En stock mínimo exacto -> debe alertar
      );
      await vm.crearInsumo(
        nombre: 'Pigmento óxido',
        unidad: UnidadMedida.kg,
        stockActual: 1.0,
        stockMinimo: 3.0, // Por debajo del mínimo -> debe alertar
      );

      expect(vm.totalInsumos, 3);
      expect(vm.totalAlertasStock, 2);
      expect(vm.tieneAlertasStock, isTrue);

      final alertas = vm.materiasPrimasEnAlerta;
      expect(alertas.length, 2);
      expect(alertas.map((i) => i.nombre), containsAll(['Esmalte blanco', 'Pigmento óxido']));

      // Comprobación de método helper
      expect(vm.esInsumoEnAlerta(alertas.first), isTrue);
    });

    test('Actualizar stock hacia arriba resuelve la alerta de forma reactiva', () async {
      await vm.crearInsumo(
        nombre: 'Caolín',
        unidad: UnidadMedida.kg,
        stockActual: 4.0,
        stockMinimo: 10.0,
      );

      expect(vm.totalAlertasStock, 1);
      expect(vm.tieneAlertasStock, isTrue);

      // Reabastecer Caolín por encima del mínimo
      final caolin = vm.insumos.first;
      await vm.actualizarInsumo(caolin.copyWith(stockActual: 15.0));

      expect(vm.totalAlertasStock, 0);
      expect(vm.tieneAlertasStock, isFalse);
      expect(vm.materiasPrimasEnAlerta, isEmpty);
    });

    test('Actualizar stock hacia abajo activa la alerta de forma reactiva', () async {
      await vm.crearInsumo(
        nombre: 'Frita cerámica',
        unidad: UnidadMedida.kg,
        stockActual: 20.0,
        stockMinimo: 10.0,
      );

      expect(vm.totalAlertasStock, 0);
      expect(vm.tieneAlertasStock, isFalse);

      // Consumir insumo hasta llegar a 8 kg (< 10 kg)
      final frita = vm.insumos.first;
      await vm.actualizarInsumo(frita.copyWith(stockActual: 8.0));

      expect(vm.totalAlertasStock, 1);
      expect(vm.tieneAlertasStock, isTrue);
      expect(vm.materiasPrimasEnAlerta.first.nombre, 'Frita cerámica');
    });

    test('Dar de baja un insumo en alerta descuenta la alerta del contador', () async {
      await vm.crearInsumo(
        nombre: 'Esmalte transparente',
        unidad: UnidadMedida.lt,
        stockActual: 1.0,
        stockMinimo: 5.0,
      );

      expect(vm.totalAlertasStock, 1);

      final id = vm.insumos.first.id;
      await vm.eliminarInsumo(id);

      expect(vm.totalAlertasStock, 0);
      expect(vm.tieneAlertasStock, isFalse);
    });

    test('Filtro de solo alertas actualiza insumosVisibles correctamente', () async {
      await vm.crearInsumo(
        nombre: 'Barro rojo',
        unidad: UnidadMedida.kg,
        stockActual: 50.0,
        stockMinimo: 10.0,
      );
      await vm.crearInsumo(
        nombre: 'Esmalte cobalto',
        unidad: UnidadMedida.lt,
        stockActual: 2.0,
        stockMinimo: 5.0,
      );

      expect(vm.insumosVisibles.length, 2);

      // Activar filtro
      vm.toggleFiltroSoloAlertas();
      expect(vm.filtrarSoloAlertas, isTrue);
      expect(vm.insumosVisibles.length, 1);
      expect(vm.insumosVisibles.first.nombre, 'Esmalte cobalto');

      // Desactivar filtro
      vm.setFiltroSoloAlertas(false);
      expect(vm.filtrarSoloAlertas, isFalse);
      expect(vm.insumosVisibles.length, 2);
    });

    test('MateriaPrima calcula correctamente deficitStock y estaEnStockMinimo', () {
      const mpAlerta = MateriaPrima(
        id: '1',
        nombre: 'Insumo Crítico',
        unidad: UnidadMedida.kg,
        stockActual: 3.5,
        stockMinimo: 10.0,
      );

      expect(mpAlerta.estaEnStockMinimo, isTrue);
      expect(mpAlerta.stockBajo, isTrue);
      expect(mpAlerta.deficitStock, 6.5);

      const mpOptima = MateriaPrima(
        id: '2',
        nombre: 'Insumo Óptimo',
        unidad: UnidadMedida.kg,
        stockActual: 15.0,
        stockMinimo: 10.0,
      );

      expect(mpOptima.estaEnStockMinimo, isFalse);
      expect(mpOptima.stockBajo, isFalse);
      expect(mpOptima.deficitStock, 0.0);
    });
  });
}
