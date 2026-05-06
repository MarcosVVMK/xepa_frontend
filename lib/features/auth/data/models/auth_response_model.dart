import 'package:xepa_frontend/features/auth/data/models/user_model.dart';

class AuthResponseModel {
  final String? token;
  final UserModel user;

  AuthResponseModel({
    this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['access_token'] as String?,
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}
