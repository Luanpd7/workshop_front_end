import 'package:workshop_front_end/repository/repository_user.dart';
import 'package:workshop_front_end/repository/repository_vehicle.dart';
import 'package:workshop_front_end/service/entities/vehicle.dart';
import '../login/entities/login.dart';

class UseCaseVehicle {
  final IRepositoryVehicle repository;

  UseCaseVehicle(this.repository);

  Future<bool> addVehicle({required Vehicle vehicle}) =>
      repository.addVehicle(vehicle: vehicle);

  Future<List<Vehicle>> getAllVehicles() =>
      repository.getAllVehicles();

}
