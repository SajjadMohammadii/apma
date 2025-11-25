// Domain entity representing a user in the authentication system.
// Relates to: user_model.dart, auth_repository.dart, login_usecase.dart

import 'package:equatable/equatable.dart';

// User entity with basic authentication and profile information.
class User extends Equatable {
  final String id;
  final String username;
  final String? email;
  final String? name;
  final String? avatar;
  final String? role;

  const User({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.avatar,
    this.role,
  });

  @override
  List<Object?> get props => [id, username, email, name, avatar, role];
}
