import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../services/service_service.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceService _serviceService = ServiceService();
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;
  String? _filterStatus;
  int? _filterClientId;
  String? _filterMechanic;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filterStatus => _filterStatus;
  int? get filterClientId => _filterClientId;
  String? get filterMechanic => _filterMechanic;

  Future<void> loadServices({
    String? status,
    int? clientId,
    String? mechanic,
  }) async {
    _setLoading(true);
    _clearError();
    _filterStatus = status;
    _filterClientId = clientId;
    _filterMechanic = mechanic;
    
    try {
      _services = await _serviceService.getAllServices();

    } catch (e) {
      _setError('Erro ao carregar serviços: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createService(Service service) async {
    _setLoading(true);
    _clearError();
    
    try {
      final createdService = await _serviceService.createService(service);
      _services.insert(0, createdService);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao criar serviço: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateService(Service service) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedService = await _serviceService.updateService(service);
      final index = _services.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _services[index] = updatedService;
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao atualizar serviço: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteService(int id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _serviceService.deleteService(id);
      _services.removeWhere((service) => service.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao excluir serviço: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchServices(String query) async {
    if (query.isEmpty) {
      await loadServices(
        status: _filterStatus,
        clientId: _filterClientId,
        mechanic: _filterMechanic,
      );
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _services = await _serviceService.searchServices(query);
    } catch (e) {
      _setError('Erro ao buscar serviços: $e');
    } finally {
      _setLoading(false);
    }
  }

  void clearFilters() {
    _filterStatus = null;
    _filterClientId = null;
    _filterMechanic = null;
    loadServices();
  }

  List<Service> get servicesByStatus {
    final statusGroups = <String, List<Service>>{};
    for (final service in _services) {
      final status = service.status.name;
      statusGroups[status] ??= [];
      statusGroups[status]!.add(service);
    }
    return statusGroups.values.expand((x) => x).toList();
  }

  Map<String, int> get statusCounts {
    final counts = <String, int>{};
    for (final service in _services) {
      final status = service.status.name;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  double get totalRevenue {
    return _services
        .where((s) => s.status == ServiceStatus.finished)
        .fold(0.0, (sum, service) => sum + service.totalCost);
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
