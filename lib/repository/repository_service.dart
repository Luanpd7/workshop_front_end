import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../service/entities/vehicle.dart';
import '../service/entities/service'
    '.dart';
import 'api_config.dart';
import 'dart:typed_data';

final Logger _logger = Logger('RepositoryVehicle');

abstract class IRepositoryService {
  Future<List<VehicleType>> listVehiclesTypes();

  Future<bool> addService(Service service);

  Future<List<ServiceDetails>> getAllServices({int? idUser,
    String? status,
    String? name,
    String? document,
    String? plate,});

  Future<bool> updateService(int serviceId, Map<String, dynamic> updates);

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


  Future<int> saveVehicle(Vehicle vehicle) async {
    final response = await http.post(
      Uri.parse('$baseURL/service/add_vehicle'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vehicle.toJson()),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['id'];
    }
    throw Exception('Erro ao salvar veículo');
  }

  Future<List<int>> saveObservations(List<Observation> observations) async {
    final List<int> ids = [];
    for (final obs in observations) {
      final response = await http.post(
        Uri.parse('$baseURL/service/observation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(obs.toJson()),
      );
      if (response.statusCode == 200) {
        ids.add(jsonDecode(response.body)['id']);
      } else {
        throw Exception('Erro ao salvar observação');
      }
    }
    return ids;
  }

  Future<List<int>> savePurchaseItems(List<PurchaseItem> items) async {
    final List<int> ids = [];
    for (final item in items) {
      final response = await http.post(
        Uri.parse('$baseURL/service/purchase_item'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );
      if (response.statusCode == 200) {
        ids.add(jsonDecode(response.body)['id']);
      } else {
        throw Exception('Erro ao salvar item de compra');
      }
    }
    return ids;
  }


  @override
  Future<List<ServiceDetails>> getAllServices({int? idUser,
    String? status,
    String? name,
    String? document,
    String? plate,}) async {
    try {
      final Map<String, String> queryParams = {};

      if (idUser != null) queryParams['userId'] = idUser.toString();
      if (status?.isNotEmpty == true) queryParams['status'] = status!;
      if (name?.isNotEmpty == true) queryParams['name'] = name!;
      if (document?.isNotEmpty == true) queryParams['document'] = document!;
      if (plate?.isNotEmpty == true) queryParams['plate'] = plate!;


      final uri = Uri.parse('$baseURL/service/services')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final services = data.map((e) => ServiceDetails.fromJson(e)).toList();
        return services;
      } else {
        throw Exception('Erro ao buscar serviços: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Erro ao buscar serviços: $e');
      return [];
    }
  }

  @override
  Future<bool> updateService(int serviceId, Map<String, dynamic> updates) async {
    try {

      if (updates.containsKey('exitImageBytes') && updates['exitImageBytes'] is Uint8List) {
        updates['exitImageBytes'] = base64Encode(updates['exitImageBytes']);
      }
      if (updates.containsKey('exitDate') && updates['exitDate'] is DateTime) {
        updates['exitDate'] = (updates['exitDate'] as DateTime).toIso8601String();
      }

      final response = await http.put(
        Uri.parse('$baseURL/service/update/$serviceId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        _logger.info('Serviço $serviceId atualizado com sucesso.');
        return true;
      } else {
        _logger.warning('Erro ao atualizar serviço $serviceId: ${response.body}');
        return false;
      }
    } catch (e) {
      _logger.severe('Erro de conexão ao atualizar serviço: $e');
      return false;
    }
  }
}
