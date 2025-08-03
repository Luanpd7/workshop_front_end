import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/service/entities/service.dart';
import 'package:workshop_front_end/service/service_details.dart';
import '../domain/use_case_service.dart';
import '../id_context.dart';
import '../repository/repository_service.dart';

class ListServicesState with ChangeNotifier {
  ListServicesState() {
    _init();
  }

  final listService = <dynamic>[];
  bool _loading = true;

  get loading => _loading;

  Future<void> _init() async {
    try {
      await loadData();
    } catch (e) {
      Logger.detached('Error in service');
    }
  }

  Future<void> loadData() async {
    final repository = RepositoryService();
    final useCaseService = UseCaseService(repository);

    var result = await useCaseService.getAllServices(idUser: UserContext().id);

    listService
      ..clear()
      ..addAll(result);

    _loading = false;
    notifyListeners();
  }

  /// Função de quando aplico o filtro
  Future<void> applyFilter(ServiceFilter filter) async {
    final repository = RepositoryService();
    final useCaseService = UseCaseService(repository);


    listService..clear()..addAll(
        await useCaseService.getAllServices(
          idUser: UserContext().id,
          name: filter.name,
          status: filter.situation,
          document: filter.document,
          plate: filter.plate,
        ),





    )  ;

    notifyListeners();
  }
}


/// Tela da listagem de serviços
class ListService extends StatelessWidget {
  const ListService({super.key, this.selectedService = false, this.idUser});

  final bool selectedService;

  final int? idUser;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ListServicesState>(
      create: (_) => ListServicesState(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text("Lista de serviços"),
          backgroundColor: Colors.blue.shade700,
          actions: [
            _FilterButton(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListViewItems(selectedService: selectedService),
        ),
      ),
    );
  }
}


class ListViewItems extends StatelessWidget {
  const ListViewItems({super.key, required this.selectedService});

  final bool selectedService;

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
            child: Text('Lista vazia'),
          );
        }

        return ListView.builder(
          itemCount: state.listService.length,
          itemBuilder: (context, index) {
            return ItemList(
              service: state.listService[index],
              selectedService: selectedService,
            );
          },
        );
      },
    );
  }
}


class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.service,
    required this.selectedService,
  });

  final ServiceDetails service;
  final bool selectedService;

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<ListServicesState>(context);
    var theme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () async {
        if (selectedService) {
          Navigator.pop(context, service);
          return;
        }
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetail(
              serviceDetails: service,
            ),
          ),
        );

        await state.loadData();
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      service.customerName,
                      style: theme.titleLarge,
                    ),
                    Text(
                      service.document,
                      style: theme.titleMedium,
                    ),
                    Text(
                      service.vehicleModel,
                      style: theme.titleMedium,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    service.status == 0 ? 'Em Andamento' : 'Finalizado',
                    style: TextStyle(
                      color: service.status == 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão do filtro que fica na appBar
class _FilterButton extends StatelessWidget {
  const _FilterButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<ListServicesState>(

      builder: ( context, state, _) {
        return
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.blueAccent),
            ),
            child: const Text('Filtro'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) =>
                    ChangeNotifierProvider.value(
                      value: state,
                      child: _FilterDialog(state),),
              );
            },
          ),
        );
      }
    );
  }
}


/// Dialog do filtro
class _FilterDialog extends StatelessWidget {

  const _FilterDialog(this.state);

  final ListServicesState state;
  @override
  Widget build(BuildContext context) {
    String? situationSelected;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController documentController = TextEditingController();
    final TextEditingController plateController = TextEditingController();


    return ChangeNotifierProvider.value(
      value: state,
      child: AlertDialog(
        title: const Text('Filtros'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Situação'),
                items: const [
                  DropdownMenuItem(
                      value: 'andamento', child: Text('Em andamento')),
                  DropdownMenuItem(
                      value: 'finalizado', child: Text('Finalizado')),
                ],
                value: situationSelected,
                onChanged: (value) {
                  if(value == 'andamento'){
                    situationSelected = '0';
                  }else if(value == 'finalizado'){
                    situationSelected = '1';
                  }

                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome do Cliente'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: documentController,
                decoration: const InputDecoration(labelText: 'Documento'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: plateController,
                decoration: const InputDecoration(labelText: 'Placa do Veículo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Aplicar Filtros'),
            onPressed: () async {
              final filter = ServiceFilter(
                situation: situationSelected,
                name: nameController.text,
                document: documentController.text,
                plate: plateController.text,
              );




             await state.applyFilter(filter);
              if(context.mounted){
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Classe responsável por ser um modelo para o filtro
class ServiceFilter {
  final String? situation;
  final String? name;
  final String? document;
  final String? plate;

  ServiceFilter({
    this.situation,
    this.name,
    this.document,
    this.plate,
  });

  @override
  String toString() {
    return 'ServiceFilter{situation: $situation, name: $name, document: $document, plate: $plate}';
  }
}
