import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../home/home.dart';
import '../service/list_service.dart';

class MechanicArea extends StatelessWidget {
  const MechanicArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ListServicesState>(
      builder: (__, state, _) {
        return Column(
          children: [
            ItemHome(
              label: 'Meus serviços',
              icon: Icons.directions_car,
              subtitle: 'Visualizar e gerenciar serviços',
              onPressed: () {
                context.push('/listServiceOfMechanic');
              },
            ),
            ItemHome(
              showFlagNewService: true,
              label: 'Caixa de entrada',
              icon: Icons.directions_car,
              subtitle: 'Caixa de entrada para novos serviços',
              onPressed: () {
                context.push('/listServiceToAnalyse');
              },
            ),
          ],
        );
      },
    );
  }
}

class ListServiceOfMechanic extends StatelessWidget {
  /// Default constructor
  const ListServiceOfMechanic({super.key,  this.screenToAnalyse});

  final bool? screenToAnalyse;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ListServicesState>(
      create: (_) => ListServicesState(screenToAnalyse: screenToAnalyse),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text("Lista de serviços"),
          backgroundColor: Colors.blue.shade700,
        ),
        body: Column(
          children: [
            ListViewItems(),
          ],
        ),
      ),
    );
  }
}

class ListViewItems extends StatelessWidget {
  const ListViewItems({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ListServicesState>(
      builder: (context, state, _) {
        if (state.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.listService.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 300),
              child: Text('Lista vazia'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.listService.length,
          itemBuilder: (context, index) {
            return ItemList(
              service: state.listService[index],
            );
          },
        );
      },
    );
  }
}
