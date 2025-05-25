import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto/services/config_service.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {

  final AuthService _authService;

  UserService(this._authService);

Future<Map<String, dynamic>> createUser({
  required String username,
  required String password,
  required String email,
}) async {
  try {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed with status ${response.statusCode}');
  } catch (e) {
    throw Exception('Registration failed. Please try again. ${e.toString()}');
  }
}

  Future<Map<String, dynamic>> getUser(int userId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get user');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to get users');
    }
  }

Future<Map<String, dynamic>> getCurrentUser() async {
  final token = await _authService.getToken();
  if (token == null) throw Exception('Not authenticated');

  final response = await http.get(
    Uri.parse('${AppConfig.baseUrl}/users/me'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to get user: ${response.statusCode}');
  }
}

Future<void> updateUser({
  String? username,
  String? email,
  String? newPassword,
}) async {
  final token = await _authService.getToken();
  if (token == null) throw Exception('Not authenticated');

  final response = await http.put(
    Uri.parse('${AppConfig.baseUrl}/users/me'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (newPassword != null) 'newPassword': newPassword,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update user: ${response.body}');
  }
}

Future<void> deleteUser() async {
  final token = await _authService.getToken();
  if (token == null) throw Exception('Not authenticated');

  final response = await http.delete(
    Uri.parse('${AppConfig.baseUrl}/users/me'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 204) {
    throw Exception('Failed to delete user: ${response.body}');
  }
}

  
}