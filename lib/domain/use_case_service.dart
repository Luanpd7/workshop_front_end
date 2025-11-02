import 'package:logging/logging.dart';

import '../login/entities/login.dart';
import '../repository/repository_service.dart';
import '../service/entities/service.dart';
import '../service/entities/vehicle.dart';
import '../customer/entities/customer.dart';

final Logger _logger = Logger('UseCaseService');
class UseCaseService {
  final RepositoryService repository;

  UseCaseService(this.repository);

  Future<List<VehicleType>> listVehicles() => repository.listVehiclesTypes();


  Future<bool> updateService(int serviceId, int newStatus,
      {List<Map<String, dynamic>>? observations,
        List<Map<String, dynamic>>? purchaseItems}) => repository.updateService(serviceId, newStatus, observations: observations,purchaseItems: purchaseItems );

  Future<bool> initializeService({
    required Service service,
  }) async {
    try {
      return repository.addService(service);
    } catch (e) {
      _logger.severe('Erro ao criar serviço completo: $e');
      return false;
    }
  }

  Future<List<ServiceDetails>> getAllServices({int? idUser,
    String? status,
    String? name,
    String? document,
    String? plate,
  }) =>
      repository.getAllServices(idUser: idUser, name: name, status: status,document: document,plate: plate);





  Future<List<UserRanking>> getRankingUsers() => repository.getRankingUsers();

  Future<List<User>> getAllMechanics() => repository.getAllMechanics();
}
