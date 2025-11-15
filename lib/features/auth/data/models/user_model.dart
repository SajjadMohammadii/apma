import 'package:apma_app/features/auth/domain/entities/user.dart';

class UserModel extends User {
  final String? token;

  const UserModel({
    required super.id,
    required super.username,
    super.email,
    super.name,
    super.avatar,
    this.token,
  });

  /// از JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      token: json['token'] as String?,
    );
  }

  /// به JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'avatar': avatar,
      'token': token,
    };
  }

  /// از XML (برای SOAP)
  factory UserModel.fromXml(Map<String, String> xmlData) {
    return UserModel(
      id: xmlData['UserId'] ?? xmlData['id'] ?? '',
      username: xmlData['Username'] ?? xmlData['username'] ?? '',
      email: xmlData['Email'] ?? xmlData['email'],
      name: xmlData['Name'] ?? xmlData['name'],
      avatar: xmlData['Avatar'] ?? xmlData['avatar'],
      token: xmlData['Token'] ?? xmlData['token'],
    );
  }

  /// کپی با تغییرات
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? avatar,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
    );
  }
}
