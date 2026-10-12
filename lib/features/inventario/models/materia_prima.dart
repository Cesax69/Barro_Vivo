// lib/features/inventario/models/materia_prima.dart
//
// Modelo de dominio que representa una materia prima (insumo) del taller.

/// Unidades de medida permitidas para materias primas en el taller.
enum UnidadMedida {
  kg('kg', 'Kilogramos'),
  lt('lt', 'Litros');

  const UnidadMedida(this.codigo, this.etiqueta);

  final String codigo;
  final String etiqueta;

  /// Obtiene la unidad a partir de su código ('kg' o 'lt').
  static UnidadMedida fromCodigo(String codigo) {
    return UnidadMedida.values.firstWhere(
      (u) => u.codigo.toLowerCase() == codigo.toLowerCase(),
      orElse: () => UnidadMedida.kg,
    );
  }
}

/// Entidad inmutable que representa una materia prima en el inventario.
class MateriaPrima {
  const MateriaPrima({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.stockActual,
    required this.stockMinimo,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Identificador único (UUID de Supabase).
  final String id;

  /// Nombre del insumo (ej: Barro rojo, Esmalte blanco).
  final String nombre;

  /// Unidad de medida ('kg' o 'lt').
  final UnidadMedida unidad;

  /// Cantidad disponible actual en el taller.
  final double stockActual;

  /// Cantidad mínima deseada antes de requerir reabastecimiento.
  final double stockMinimo;

  /// Bandera para borrado lógico (true = visible/activo, false = dado de baja).
  final bool activo;

  /// Fecha de creación en el sistema.
  final DateTime? createdAt;

  /// Fecha de última modificación.
  final DateTime? updatedAt;

  /// Indica si el stock actual está por debajo o igual al stock mínimo.
  bool get stockBajo => stockActual <= stockMinimo;

  /// Crea una instancia a partir del mapa JSON devuelto por Supabase.
  factory MateriaPrima.fromJson(Map<String, dynamic> json) {
    return MateriaPrima(
      id: json['id'] as String,
      nombre: json['nombre'] as String? ?? '',
      unidad: UnidadMedida.fromCodigo(json['unidad'] as String? ?? 'kg'),
      stockActual: (json['stock_actual'] as num?)?.toDouble() ?? 0.0,
      stockMinimo: (json['stock_minimo'] as num?)?.toDouble() ?? 0.0,
      activo: json['activo'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Serializa la materia prima para inserción o actualización en Supabase.
  Map<String, dynamic> toJson({bool includeId = true}) {
    final map = <String, dynamic>{
      'nombre': nombre.trim(),
      'unidad': unidad.codigo,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'activo': activo,
    };
    if (includeId && id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  /// Retorna una copia con los valores modificados.
  MateriaPrima copyWith({
    String? id,
    String? nombre,
    UnidadMedida? unidad,
    double? stockActual,
    double? stockMinimo,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MateriaPrima(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      unidad: unidad ?? this.unidad,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MateriaPrima &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
