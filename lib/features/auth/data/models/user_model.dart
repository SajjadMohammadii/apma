// Data model extending User entity with serialization capabilities.
// Relates to: user.dart, auth_remote_datasource.dart, auth_repository_impl.dart

import 'package:apma_app/features/auth/domain/entities/user.dart';

// User data model with JSON/XML serialization for API integration.
class UserModel extends User {
  final String? token;

  const UserModel({
    required super.id,
    required super.username,
    super.email,
    super.name,
    super.avatar,
    super.role,
    this.token,
  });

  // Deserializes user from JSON response.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
    );
  }

  // Serializes user to JSON format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'avatar': avatar,
      'role': role,
      'token': token,
    };
  }

  // Deserializes user from XML SOAP response.
  factory UserModel.fromXml(Map<String, String> xmlData) {
    return UserModel(
      id: xmlData['UserId'] ?? xmlData['id'] ?? '',
      username: xmlData['Username'] ?? xmlData['username'] ?? '',
      email: xmlData['Email'] ?? xmlData['email'],
      name: xmlData['Name'] ?? xmlData['name'],
      avatar: xmlData['Avatar'] ?? xmlData['avatar'],
      role: xmlData['Role'] ?? xmlData['role'],
      token: xmlData['Token'] ?? xmlData['token'],
    );
  }

  // Creates a copy with modified fields.
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? avatar,
    String? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
