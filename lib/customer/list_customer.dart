import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/customer/entities/customer.dart';
import 'dart:async';
import '../domain/use_case_customer.dart';
import '../repository/repository_customer.dart';

class ListCustomersState with ChangeNotifier {
  ListCustomersState() {
    Future.microtask(() => _init());
  }

  final listCustomer = <Customer>[];

  ///indicator loading
  bool _loading = true;

  Future<void> _init() async {
    print('acessando init');
    try {
      final repository = RepositoryCustomer();
      final useCaseCustomer = UseCaseCustomer(repository);


      var result = await useCaseCustomer.listCustomers();
      listCustomer.addAll(result);
      _loading = false;
      notifyListeners();
    }catch (e){

    }
  }
}

class ListCustomer extends StatelessWidget {
  const ListCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ListCustomersState>(
      create: (_) => ListCustomersState(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text("Lista de clientes"),
          backgroundColor: Colors.blue.shade700,
        ),
        body: Padding(
            padding: const EdgeInsets.only(top: 10),
            child:  ListViewItems(),
          ),
      ),
    );
  }
}

class ListViewItems extends StatelessWidget {
  const ListViewItems({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return ItemList();
      },
    );
  }
}

class ItemList extends StatelessWidget {
  const ItemList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.grey.withAlpha(50),
            ],
          ),
        ),
      ),
    );
  }
}
