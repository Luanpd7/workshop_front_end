import 'package:workshop_front_end/customer/entities/address.dart';
import 'package:workshop_front_end/customer/entities/customer.dart';
import '../repository/repository_customer.dart';

class UseCaseCustomer {
  final IRepositoryCustomer repository;

  UseCaseCustomer(this.repository);

  Future<int> addCustomer(Customer customer) =>
      repository.addCustomer(customer);

  Future<void> updateCustomer(Customer customer) =>
      repository.updateCustomer(customer);


  Future<List<Customer>> listCustomers({int? idUser}) => repository.listCustomers(idUser: idUser);

  Future<bool> deleteCustomer(int id) => repository.deleteCustomer(id);

  Future<Address?> searchCEP(String cep) => repository.searchCEP(cep);

  Future<List<String>> getAllDocuments() => repository.getAllDocuments();
}
