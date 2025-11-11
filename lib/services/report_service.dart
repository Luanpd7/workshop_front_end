import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/repart.dart';

class ReportService {
  static const String baseUrl = 'http://192.168.1.5:8080/api';

  // Relatório de compra e venda de peças por mês
  Future<Map<String, dynamic>> getPartsReportByMonth(int year, int month) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/parts?year=$year&month=$month'),
        headers: {'Content-Type': 'application/json'},
      );

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

  // Relatório de serviços realizados por mês
  Future<Map<String, dynamic>> getServicesReportByMonth(int year, int month) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/services?year=$year&month=$month'),
        headers: {'Content-Type': 'application/json'},
      );

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




