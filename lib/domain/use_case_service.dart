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

  Future<bool> initializeService({
    required int idUser,
    required Customer customer,
    required Vehicle vehicle,
    required List<Observation> observations,
    required List<PurchaseItem> items,
    required int status,
    required DateTime entryDate,
    String? imageBytes,
  }) async {
    try {
      var observationIds = <int>[];
      var itemsId = <int>[];


      if(observations.isNotEmpty){

        observationIds = await repository.saveObservations(observations);
      }

      if(items.isNotEmpty){

         itemsId = await repository.savePurchaseItems(items);
      }

        final vehicleId = await repository.saveVehicle(vehicle);

      final service = Service(
        idUser: idUser,
        customerId: customer.id!,
        vehicleId: vehicleId,
        observationIds: observationIds,
        purchaseItemIds: itemsId,
        status: status,
        entryDate: entryDate,
        imageBytes: imageBytes,
      );

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

  Future<Map<String, dynamic>?> getImageServiceById(int id) =>
      repository.getImageServiceById(id);

  Future<bool> updateService(int serviceId, Map<String, dynamic> updates) =>
      repository.updateService(serviceId, updates);

  Future<List<UserRanking>> getRankingUsers() => repository.getRankingUsers();
}
