// lib/models/user_model.dart
//
// Entidad del dominio que representa a un usuario autenticado.
// Esta clase es un Value Object puro: sin lógica de negocio
// ni dependencias de framework o de paquetes externos.

/// Roles disponibles dentro de la aplicación Barro Vivo.
enum UserRole {
  /// Dueño o artesano del taller.
  taller,

  /// Cliente / comprador.
  cliente,
}

/// Modelo de dominio para un usuario autenticado.
///
/// Inmutable por diseño: cualquier modificación devuelve una nueva instancia
/// mediante [copyWith].
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.displayName,
  });

  /// Identificador único proveniente de Supabase Auth (UUID).
  final String id;

  /// Correo electrónico del usuario.
  final String email;

  /// Rol asignado dentro de la aplicación.
  final UserRole role;

  /// Nombre para mostrar (opcional).
  final String? displayName;

  // ── Fábrica ─────────────────────────────────────────────────────────────

  /// Crea un [UserModel] a partir de un mapa JSON (p. ej. respuesta de
  /// la tabla `profiles` en Supabase).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.cliente,
      ),
      displayName: json['display_name'] as String?,
    );
  }

  /// Serializa el modelo a un mapa JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role.name,
        'display_name': displayName,
      };

  /// Devuelve una copia con los campos indicados modificados.
  UserModel copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? displayName,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, role: ${role.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode => Object.hash(id, email, role);
}
