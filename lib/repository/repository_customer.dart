import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:workshop_front_end/customer/entities/address.dart';
import 'package:workshop_front_end/customer/entities/customer.dart';

import 'api_config.dart';

final Logger _logger = Logger('RepositoryCustomer');

abstract class IRepositoryCustomer {
  Future<void> addCustomer(Customer customer);

  Future<void> updateCustomer(Customer customer);

  Future<List<Customer>> listCustomers();

  Future<bool> deleteCustomer(int id);

  Future<Address?> searchCEP(String cep);

  Future<List<String>> getAllDocuments();
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
        Uri.parse('$baseURL/user/add_customer'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception();
      }
    } catch (e) {
      _logger.severe('Erro ao adicionar cliente: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    try {
      final body = jsonEncode({
        "Customer": customer.toJson(),
      });

      final response = await http.post(
        Uri.parse('$baseURL/user/update_customer'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception();
      }
    } catch (e) {
      _logger.severe('Erro ao adicionar cliente: $e');
      rethrow;
    }
  }

  @override
  Future<List<Customer>> listCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseURL/user/listCustomers'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception();
      }

      final data = jsonDecode(response.body);
      List<Customer> list = [];
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

  @override
  Future<bool> deleteCustomer(int id) async {
    try {
      var body = jsonEncode({"id": id});

      final response = await http.delete(
        Uri.parse('$baseURL/user/delete_customer'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        return false;
      }
      return true;
    } catch (e) {
      _logger.severe('Erro ao adicionar cliente: $e');
      return false;
    }
  }

  @override
  Future<Address?> searchCEP(String cep) async {
    try {
      final response =
          await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final address = Address(
          cep: data['cep'],
          road: data['logradouro'],
          neighborhood: data['bairro'],
          city: data['localidade'],
        );
        return address;
      }

      return null;
    } catch (e) {
      _logger.severe('Erro ao buscar CEP: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getAllDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseURL/user/listCustomers'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception();
      }

      final data = jsonDecode(response.body);
      List<String> list = [];
      for (var i in data) {
        final result = i['document'];
        list.add(result);
      }

      return list;
    } catch (e) {
      _logger.severe('Erro ao listar clientes: $e');
    }
    return [];
  }
}
