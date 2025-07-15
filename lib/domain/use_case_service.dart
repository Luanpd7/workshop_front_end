import '../service/entities/service'
    '.dart';
import '../repository/repository_vehicle.dart';
import '../service/entities/vehicle.dart';

class UseCaseService {
  final IRepositoryService repository;

  UseCaseService(this.repository);

  Future<List<VehicleType>> listVehicles() => repository.listVehiclesTypes();


  Future<bool> addService(Service service) => repository.addService(service);



}
