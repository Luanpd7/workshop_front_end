import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../service/entities/vehicle.dart';
import '../service/entities/service'
    '.dart';
import 'api_config.dart';

final Logger _logger = Logger('RepositoryVehicle');

abstract class IRepositoryService {
  Future<List<VehicleType>> listVehiclesTypes();

  Future<bool> addService(Service service);
}

class RepositoryService implements IRepositoryService {
  final baseURL = ApiConfig().baseUrl;

  @override
  Future<List<VehicleType>> listVehiclesTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseURL/service/listVehiclesTypes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar veículos');
      }

      final data = jsonDecode(response.body);
      List<VehicleType> vehicles = [];

      for (var item in data) {
        vehicles.add(VehicleType.fromJson(item));
      }
      print('vehicles $vehicles');

      return vehicles;
    } catch (e) {
      _logger.severe('Erro ao buscar veículos: $e');
      return [];
    }
  }

  @override
  Future<bool> addService(Service service) async {
    try {
      final body = jsonEncode(service.toJson());

      print('------------------------------------------- $body');

      final response = await http.post(
        Uri.parse('$baseURL/service/addService'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        _logger.warning('Erro ao adicionar serviço: ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.severe('Erro ao adicionar serviço: $e');
      return false;
    }
  }

}
