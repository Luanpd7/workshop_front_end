import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class VehicleService {
  static const String baseUrl = 'http://192.168.1.8:8080/api';

  Future<void> testarConexao() async {
    try {
      final url = Uri.parse('http://192.168.1.5:8080/api/hello');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('✅ Conectado ao backend com sucesso!');
      } else {
        print('⚠️ Erro do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao conectar: $e');
    }
  }

  Future<List<Vehicle>> getAllVehicles() async {
    try {


      final response = await http.get(
        Uri.parse('$baseUrl/vehicles'),
        headers: {'Content-Type': 'application/json'},
      );

      print('response status code ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vehiclesList = data['vehicles'] as List;
        return vehiclesList.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar veículos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Vehicle>> getVehiclesByClientId(int clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehicles/byClient/$clientId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vehiclesList = data['vehicles'] as List;
        return vehiclesList.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar veículos do cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehicles'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'clientId': vehicle.clientId,
          'brand': vehicle.brand,
          'model': vehicle.model,
          'year': vehicle.year,
          'color': vehicle.color,
          'plate': vehicle.plate,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Vehicle.fromJson(data['vehicle']);
      } else {
        throw Exception('Erro ao criar veículo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/vehicles/${vehicle.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'clientId': vehicle.clientId,
          'brand': vehicle.brand,
          'model': vehicle.model,
          'year': vehicle.year,
          'color': vehicle.color,
          'plate': vehicle.plate,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Vehicle.fromJson(data['vehicle']);
      } else {
        throw Exception('Erro ao atualizar veículo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<void> deleteVehicle(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/vehicles/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao excluir veículo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Vehicle> getVehicleById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehicles/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Vehicle.fromJson(data['vehicle']);
      } else {
        throw Exception('Erro ao buscar veículo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<Vehicle>> searchVehicles(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/vehicles/search')
          .replace(queryParameters: {'q': query});
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vehiclesList = data['vehicles'] as List;
        return vehiclesList.map((json) => Vehicle.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar veículos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
