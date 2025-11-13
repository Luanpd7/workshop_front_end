import 'dart:convert';
import 'package:http/http.dart' as http;



class ReportService {
  static const String baseUrl = 'http://192.168.1.10:8080/api';

  Future<Map<String, dynamic>> getPartsReportByMonth(int year, int month) async {
    try {
      final uri = Uri.parse('$baseUrl/reports/parts').replace(queryParameters: {
        'year': year.toString(),
        'month': month.toString().padLeft(2, '0'),
      });
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Erro ao buscar relatório de peças: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Map<String, dynamic>> getServicesReportByMonth(int year, int month) async {
    try {
      final uri = Uri.parse('$baseUrl/reports/services').replace(queryParameters: {
        'year': year.toString(),
        'month': month.toString().padLeft(2, '0'),
      });
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Erro ao buscar relatório de serviços: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}