import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';

class ServiceService {
  static const String baseUrl = 'http://192.168.1.8:8080/api';

  Future<List<Service>> getAllServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final servicesList = data['services'] as List;

        return servicesList.map((json) => Service.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar serviços: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Service>> getServicesByClientId(int clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/byClient/$clientId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final servicesList = data['services'] as List;
        return servicesList.map((json) => Service.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar serviços do cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Service>> getServicesByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/byStatus/$status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final servicesList = data['services'] as List;
        return servicesList.map((json) => Service.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar serviços por status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Service>> getServicesByMechanic(String mechanicName) async {
    try {
      final uri = Uri.parse('$baseUrl/services/byMechanic')
          .replace(queryParameters: {'name': mechanicName});
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final servicesList = data['services'] as List;
        return servicesList.map((json) => Service.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar serviços por mecânico: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Service> createService(Service service) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(service.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Service.fromJson(data['service']);
      } else {
        throw Exception('Erro ao criar serviço: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Service> updateService(Service service) async {
    try {


      final response = await http.put(
        Uri.parse('$baseUrl/services/${service.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(service.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Service.fromJson(data['service']);
      } else {
        throw Exception('Erro ao atualizar serviço: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<void> deleteService(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/services/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao excluir serviço: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Service> getServiceById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Service.fromJson(data['service']);
      } else {
        throw Exception('Erro ao buscar serviço: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Service>> searchServices(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/services/search')
          .replace(queryParameters: {'q': query});
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final servicesList = data['services'] as List;
        return servicesList.map((json) => Service.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar serviços: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
