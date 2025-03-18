import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:workshop_front_end/customer/entities/address.dart';
import 'package:workshop_front_end/customer/entities/customer.dart';
import 'package:http/http.dart' as http;

final Logger _logger = Logger('RepositoryCustomer');

abstract class IRepositoryCustomer {

  Future<void> addCustomer(Customer customer, Address address);
}

class RepositoryCustomer implements IRepositoryCustomer{
  static const String baseUrl = 'http://192.168.1.11:8080';

  @override
  Future<void> addCustomer(Customer customer, Address address) async {
    try{
      final body = jsonEncode({
        "Customer" : customer.toJson(),
        "Address" : address.toJson(),
      });

      final response = await http.post(
        Uri.parse('$baseUrl/add_customer'),
        headers: {'Content-Type': 'application/json'},
        body:  body,
      );

if(response.statusCode != 200){
  throw Exception();
}

    }catch (e){
      _logger.severe('Erro ao adicionar cliente: $e');
    }
  }

}