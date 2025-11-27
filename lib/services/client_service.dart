import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client.dart';

class ClientService {
  static const String baseUrl = 'http://10.0.150.220:8080/api';

  Future<List<Client>> getAllClients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clients'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final clientsList = data['clients'] as List;
        return clientsList.map((json) => Client.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar clientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Client> createClient(Client client) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/clients'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': client.name,
          'phone': client.phone,
          'email': client.email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Client.fromJson(data['client']);
      } else {
        throw Exception('Erro ao criar cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Client> updateClient(Client client) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/clients/${client.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': client.name,
          'phone': client.phone,
          'email': client.email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Client.fromJson(data['client']);
      } else {
        throw Exception('Erro ao atualizar cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/clients/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao excluir cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Client> getClientById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clients/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Client.fromJson(data['client']);
      } else {
        throw Exception('Erro ao buscar cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Client>> searchClients(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/clients/search')
          .replace(queryParameters: {'q': query});
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final clientsList = data['clients'] as List;
        return clientsList.map((json) => Client.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar clientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
