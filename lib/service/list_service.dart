import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final TextEditingController plateController = TextEditingController();

   String? _situationSelected;


  String? get situationSelected => _situationSelected;

  set situationSelected(String? value) {
    _situationSelected = value;
    notifyListeners();
  }

  String? _situationValue ;


  String? get situationValue => _situationValue;

  set situationValue(String? value) {
    _situationValue = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
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

  bool _disposed = false;

  Future<void> loadData() async {
    final repository = RepositoryService();
    final useCaseService = UseCaseService(repository);
    final id = UserContext().id == 1 ?  null :  UserContext().id ;

    var result = await useCaseService.getAllServices(idUser: id);

    if (_disposed) return;

    listService
      ..clear()
      ..addAll(result);



    _loading = false;
    notifyListeners();
  }


  void changedSituation(String? situation){
    if(situation == 'andamento' ){
      situationValue = '0';
      situationValue = '0';
    }
    else if(situation == 'finalizado' ){
      situationValue = '1';
    }
   else if(situation == 'todos' ){
      situationValue = '';
    }
  }

  /// Função de quando aplico o filtro
  Future<void> applyFilter(ServiceFilter filter) async {
    final repository = RepositoryService();
    final useCaseService = UseCaseService(repository);

final id = UserContext().id == 1 ?  null :  UserContext().id ;
    listService..clear()..addAll(
        await useCaseService.getAllServices(
          idUser: id,
          name: filter.name,
          status: filter.situation,
          document: filter.document,
          plate: filter.plate,
        ),
    )  ;

    notifyListeners();
  }


 void clearFilter(){
     situationSelected = null;
     nameController.clear();
     documentController.clear();
     plateController.clear();
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



    return ChangeNotifierProvider.value(
      value: state,
      child: AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Filtros'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
               dropdownColor:   Theme.of(context).scaffoldBackgroundColor,
                decoration: const InputDecoration(labelText: 'Situação'),
                items: const [
                  DropdownMenuItem(
                      value: 'andamento', child: Text('Em andamento')),
                  DropdownMenuItem(
                      value: 'finalizado', child: Text('Finalizado')),
                ],
                value: state.situationSelected,

                onChanged: (value) {
                  state.changedSituation(value);
                  state.situationSelected = value;

                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: state.nameController,
                decoration: const InputDecoration(labelText: 'Nome do Cliente'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: state.documentController,
                decoration: const InputDecoration(labelText: 'Documento'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: state.plateController,
                decoration: const InputDecoration(labelText: 'Placa do Veículo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Limpar Filtro'),
            onPressed: () async {
              state.clearFilter();
              await state.applyFilter(ServiceFilter());
              context.pop();
            },
          ),
          ElevatedButton(
            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blueAccent)),
            child: const Text('Aplicar Filtros'),
            onPressed: () async {
              final filter = ServiceFilter(
                situation: state.situationValue,
                name: state.nameController.text,
                document: state.documentController.text,
                plate: state.plateController.text,
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
