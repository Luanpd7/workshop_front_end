import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:workshop_front_end/customer/entities/address.dart';
import 'package:workshop_front_end/customer/entities/customer.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

final Logger _logger = Logger('RepositoryCustomer');

abstract class IRepositoryCustomer {
  Future<void> addCustomer(Customer customer);

  Future<List<Customer>> listCustomers();
}

class RepositoryCustomer implements IRepositoryCustomer {
  final baseURL = ApiConfig().baseUrl;

  @override
  Future<void> addCustomer(Customer customer) async {
    try {
      final body = jsonEncode({
        "Customer": customer.toJson(),
      });

      final response = await http.post(
        Uri.parse('$baseURL/add_customer'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception();
      }
    } catch (e) {
      _logger.severe('Erro ao adicionar cliente: $e');
    }
  }


  @override
  Future<List<Customer>> listCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseURL/listCustomers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception();
      }

      final data = jsonDecode(response.body);
      List<Customer> list = [];

      print('-------------------------------- 1');
      for (var i in data) {
        var customer = Customer.fromJson(i);
        list.add(customer);
      }

      return list;
    } catch (e) {
      _logger.severe('Erro ao listar clientes: $e');
    }
    return [];
  }
}
