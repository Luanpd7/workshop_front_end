import 'package:workshop_front_end/customer/entities/address.dart';
import 'package:workshop_front_end/customer/entities/customer.dart';

import '../repository/repository_customer.dart';

class UseCaseCustomer {
  final IRepositoryCustomer repository;

  UseCaseCustomer(this.repository);

  Future<void> addCustomer(Customer customer) =>
      repository.addCustomer(customer);

  Future<List<Customer>> listCustomers() =>
      repository.listCustomers();

}
