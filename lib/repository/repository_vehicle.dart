import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:workshop_front_end/service/entities/vehicle.dart';
import '../login/entities/login.dart';
import 'api_config.dart';

final Logger _logger = Logger('RepositoryUser');

abstract class IRepositoryVehicle {

  Future<bool> addVehicle({required Vehicle vehicle});

  Future<List<Vehicle>> getAllVehicles();

}

class RepositoryVehicle implements IRepositoryVehicle{
  final baseURL = ApiConfig().baseUrl;


  @override
  Future<bool> addVehicle({
    required Vehicle vehicle
  }) async {
    var userBody = jsonEncode(vehicle.toJson());
    try{
      final response = await http.post(
        Uri.parse('$baseURL/vehicle/add_vehicle'),
        headers: {'Content-Type': 'application/json'},
        body: userBody,
      );

      if(response.statusCode == 200) {
        return true;
      }
      return false;
    }catch (e){
      _logger.severe('ERROR : $e');
      return false;
    }
  }

  @override
  Future<List<Vehicle>> getAllVehicles() async {
    try {
      var uri = Uri.parse('$baseURL/vehicle/listVehicles');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          return [];
        }
        throw Exception('Falha ao carregar clientes. Status code: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      List<Vehicle> list = [];
      for (var i in data) {
        var customer = Vehicle.fromJson(i);
        list.add(customer);
      }
      return list;
    } catch (e) {
      _logger.severe('Erro ao listar clientes: $e');
      return [];
    }
  }
}
