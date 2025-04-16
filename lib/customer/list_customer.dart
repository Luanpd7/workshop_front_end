import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/customer/entities/customer.dart';
import 'package:workshop_front_end/customer/view.dart';

import '../domain/use_case_customer.dart';
import '../repository/repository_customer.dart';
import '../util/modal.dart';

class ListCustomersState with ChangeNotifier {
  ListCustomersState() {
    _init();
  }

  final listCustomer = <Customer>[];

  Future<void> _init() async {
    try {
   await loadData();
      notifyListeners();
    } catch (e) {
      Logger.detached('Error in customer');
    }
    ;
  }
  
  Future<void> loadData() async{
    final repository = RepositoryCustomer();
    final useCaseCustomer = UseCaseCustomer(repository);

    var result = await useCaseCustomer.listCustomers();

    listCustomer.addAll(result);
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
          child: ListViewItems(),
        ),
      ),
    );
  }
}

class ListViewItems extends StatelessWidget {
  const ListViewItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ListCustomersState>(
      builder: (context, state, _) {
        return ListView.builder(
          itemCount: state.listCustomer.length,
          itemBuilder: (context, index) {
            return ItemList(
              customer: state.listCustomer[index],
            );
          },
        );
      },
    );
  }
}

class ItemList extends StatelessWidget {
  const ItemList({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsCustomer(customer: customer),
          ),
        );
      },
      child: Padding(
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  customer.name ?? '',
                  style: theme.titleLarge,
                ),
                Text(
                  customer.surname ?? '',
                  style: theme.titleMedium,
                ),
                Text(
                  customer.document ?? '',
                  style: theme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailsCustomer extends StatelessWidget {
  const DetailsCustomer({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Cliente ${customer.name}"),
        backgroundColor: Colors.blue.shade700,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 18.0,
              children: [
                Icon(size: 28, Icons.edit),
                _ButtonDelete(id:  customer.id!,),
              ],
            ),
          ),
        ],
      ),
      body: RegisterCustomer(customer: customer),
    );
  }
}

class _ButtonDelete extends StatelessWidget {
  const _ButtonDelete({required this.id});

  final int id;
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<CustomerState>(context);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialogUtil(
              title: "Atenção",
              content: "Você irá excluir o cliente permanentemente",
              labelButtonPrimary: 'Confirmar',
              onPressedPrimary: () async {
                final  result = await state.onPressedDeleteCustomer(id: id);

                if(result ){
                  Fluttertoast.showToast(
                    msg: "Deletado com sucesso!",
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);

                }else {
                  Fluttertoast.showToast(
                    msg: "Ocorreu um erro ao deletar!",
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              }
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          size: 28,
          Icons.delete,
        ),
      ),
    );
  }
}
