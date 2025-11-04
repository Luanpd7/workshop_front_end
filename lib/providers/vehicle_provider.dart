import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class VehicleProvider with ChangeNotifier {
  final VehicleService _vehicleService = VehicleService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;
  int? _filterClientId;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get filterClientId => _filterClientId;

  Future<void> loadVehicles({int? clientId}) async {
    _setLoading(true);
    _clearError();
    _filterClientId = clientId;
    
    try {
      if (clientId != null) {
        _vehicles = await _vehicleService.getVehiclesByClientId(clientId);
      } else {
        _vehicles = await _vehicleService.getAllVehicles();
      }
    } catch (e) {
      _setError('Erro ao carregar veículos: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createVehicle(Vehicle vehicle) async {
    _setLoading(true);
    _clearError();
    
    try {
      final createdVehicle = await _vehicleService.createVehicle(vehicle);
      _vehicles.insert(0, createdVehicle);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao criar veículo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    _setLoading(true);
    _clearError();
    
    try {

      print('------------------------- 3');
      final updatedVehicle = await _vehicleService.updateVehicle(vehicle);
      final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao atualizar veículo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteVehicle(int id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _vehicleService.deleteVehicle(id);
      _vehicles.removeWhere((vehicle) => vehicle.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao excluir veículo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchVehicles(String query) async {
    if (query.isEmpty) {
      await loadVehicles(clientId: _filterClientId);
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _vehicles = await _vehicleService.searchVehicles(query);
    } catch (e) {
      _setError('Erro ao buscar veículos: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearFilter() {
    _filterClientId = null;
    loadVehicles();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
