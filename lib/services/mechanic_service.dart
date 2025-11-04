import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mechanic.dart';

class MechanicService {
  static const String baseUrl = 'http://192.168.1.5:8080/api';

  Future<List<Mechanic>> getAllMechanics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mechanics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mechanicsList = data['mechanics'] as List;
        return mechanicsList.map((json) => Mechanic.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar mecânicos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Mechanic> createMechanic(Mechanic mechanic) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mechanics'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': mechanic.name,
          'phone': mechanic.phone,
          'email': mechanic.email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Mechanic.fromJson(data['mechanic']);
      } else {
        throw Exception('Erro ao criar mecânico: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Mechanic> updateMechanic(Mechanic mechanic) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/mechanics/${mechanic.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': mechanic.name,
          'phone': mechanic.phone,
          'email': mechanic.email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Mechanic.fromJson(data['mechanic']);
      } else {
        throw Exception('Erro ao atualizar mecânico: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<void> deleteMechanic(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/mechanics/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao excluir mecânico: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Mechanic> getMechanicById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mechanics/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Mechanic.fromJson(data['mechanic']);
      } else {
        throw Exception('Erro ao buscar mecânico: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Mechanic>> searchMechanics(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mechanics/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mechanicsList = data['mechanics'] as List;
        return mechanicsList.map((json) => Mechanic.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar mecânicos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}

