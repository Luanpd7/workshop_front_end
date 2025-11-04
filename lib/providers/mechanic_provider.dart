import 'package:flutter/foundation.dart';
import '../models/mechanic.dart';
import '../services/mechanic_service.dart';

class MechanicProvider with ChangeNotifier {
  final MechanicService _mechanicService = MechanicService();
  List<Mechanic> _mechanics = [];
  bool _isLoading = false;
  String? _error;

  List<Mechanic> get mechanics => _mechanics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMechanics() async {
    _setLoading(true);
    _clearError();
    
    try {
      _mechanics = await _mechanicService.getAllMechanics();
    } catch (e) {
      _setError('Erro ao carregar mecânicos: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createMechanic(Mechanic mechanic) async {
    _setLoading(true);
    _clearError();
    
    try {
      final createdMechanic = await _mechanicService.createMechanic(mechanic);
      _mechanics.insert(0, createdMechanic);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao criar mecânico: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMechanic(Mechanic mechanic) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedMechanic = await _mechanicService.updateMechanic(mechanic);
      final index = _mechanics.indexWhere((m) => m.id == mechanic.id);
      if (index != -1) {
        _mechanics[index] = updatedMechanic;
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao atualizar mecânico: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteMechanic(int id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _mechanicService.deleteMechanic(id);
      _mechanics.removeWhere((mechanic) => mechanic.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao excluir mecânico: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchMechanics(String query) async {
    if (query.isEmpty) {
      await loadMechanics();
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _mechanics = await _mechanicService.searchMechanics(query);
    } catch (e) {
      _setError('Erro ao buscar mecânicos: $e');
    } finally {
      _setLoading(false);
    }
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

