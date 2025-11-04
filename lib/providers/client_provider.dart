import 'package:flutter/foundation.dart';
import '../models/client.dart';
import '../services/client_service.dart';

class ClientProvider with ChangeNotifier {
  final ClientService _clientService = ClientService();
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClients() async {
    _setLoading(true);
    _clearError();
    
    try {
      _clients = await _clientService.getAllClients();
    } catch (e) {
      _setError('Erro ao carregar clientes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createClient(Client client) async {
    _setLoading(true);
    _clearError();
    
    try {
      final createdClient = await _clientService.createClient(client);
      _clients.insert(0, createdClient);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao criar cliente: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateClient(Client client) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedClient = await _clientService.updateClient(client);
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = updatedClient;
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao atualizar cliente: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteClient(int id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _clientService.deleteClient(id);
      _clients.removeWhere((client) => client.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao excluir cliente: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchClients(String query) async {
    if (query.isEmpty) {
      await loadClients();
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _clients = await _clientService.searchClients(query);
    } catch (e) {
      _setError('Erro ao buscar clientes: $e');
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
