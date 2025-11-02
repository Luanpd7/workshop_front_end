import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/repository/repository_vehicle.dart';
import 'package:workshop_front_end/vehicle/vehicle_form.dart';
import '../domain/use_case_vehicle.dart';
import '../login/entities/login.dart';
import '../login/view.dart';
import '../service/entities/vehicle.dart';

class _ListVehicleState with ChangeNotifier {
  _ListVehicleState({required User? user}) {
    _init(user: user);
  }

  final listVehicles = <Vehicle>[];
  bool _loading = true;

  get loading => _loading;

  Future<void> _init({User? user}) async {
    try {
      await loadData();
    } catch (e) {
      Logger.detached('Error in vehicle');
    }
  }

  Future<void> loadData() async {
    final repository = RepositoryVehicle();
    final useCase = UseCaseVehicle(repository);

    var result = await useCase.getAllVehicles();


    listVehicles
      ..clear()
      ..addAll(result);
    _loading = false;
    notifyListeners();
  }
}

class ListVehicle extends StatelessWidget {
  /// Default constructor
  const ListVehicle({super.key, this.selectedVehicle = false});

  final bool selectedVehicle;

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<LoginState>(context, listen: false).user;
    return ChangeNotifierProvider<_ListVehicleState>(
      create: (_) => _ListVehicleState(user: user),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text("Lista de veículos"),
          backgroundColor: Colors.blue.shade700,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: _AddVehicleButton(),
            ),
            _ListViewItems(selectedVehicle: selectedVehicle),
          ],
        ),
      ),
    );
  }
}

class _ListViewItems extends StatelessWidget {
  const _ListViewItems({ required this.selectedVehicle});

  final bool selectedVehicle;

  @override
  Widget build(BuildContext context) {
    return Consumer<_ListVehicleState>(
      builder: (context, state, _) {
        if (state.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.listVehicles.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 300),
            child: Align(
              alignment: Alignment.center,
              child: Text('Lista vazia'),
            ),
          );
        }

        return Expanded(
          child: ListView.builder(
            itemCount: state.listVehicles.length,
            itemBuilder: (context, index) {
              return _ItemList(
                vehicle: state.listVehicles[index],
                selectedVehicle: selectedVehicle,
              );
            },
          ),
        );
      },
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    required this.vehicle,
    required this.selectedVehicle,
  });

  final Vehicle vehicle;
  final bool selectedVehicle;

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<_ListVehicleState>(context);
    var theme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () async {
        if (selectedVehicle) {
          Navigator.pop(context, vehicle);
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterVehicle(isEdit: true, vehicle: vehicle,),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vehicle.brand,
                  style: theme.titleLarge,
                ),
                Text(
                  vehicle.model,
                  style: theme.titleMedium,
                ),
                Text(
                  vehicle.plate,
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


/// Botão para salvar edição
class _AddVehicleButton extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    var state = Provider.of<_ListVehicleState>(context);
    return GestureDetector(
      onTap: () async {
       await  context.push('/registerVehicle');
       state.loadData();
      },
      child: SizedBox(
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(
              12,
            ),
            border: Border.all(color: Colors.blue.shade700, width: 1),
          ),
          child: Center(
            child: Text('Adicionar veículo'),
          ),
        ),
      ),
    );
  }
}
