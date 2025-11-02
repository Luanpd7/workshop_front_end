import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/service/entities/service.dart';
import 'package:intl/intl.dart';
import '../../domain/use_case_service.dart';
import '../../id_context.dart';
import '../../repository/repository_service.dart';
import '../service_form.dart';

/// Estado do formulário
class ServiceFormMechanicSate with ChangeNotifier {
  ServiceFormMechanicSate(int id) {
    priceUnitaryController.addListener(_calcTotal);
    quantityPartController.addListener(_calcTotal);
    _init(id);
  }

  Service? service;

  int? _statusCode;

  String get situationText {
    switch (_statusCode) {
      case 0:
        return 'Em andamento';
      case 1:
        return 'Lavação';
      case 2:
        return 'Finalizado';
      case 3:
        return 'Em análise';
      default:
        return '';
    }
  }

  void setSituation(int code) {
    _statusCode = code;
    notifyListeners();
  }

  bool _loading = false;

  final RepositoryService _repository = RepositoryService();

  List<Observation> observations = [];

  List<PurchaseItem> purchasePart = [];

  final formKey = GlobalKey<FormState>();

  bool _isDetails = false;

  bool _isMechanic = false;

  double? _sumValue;

  /// controller of service form
  TextEditingController observationServiceController = TextEditingController();
  TextEditingController partController = TextEditingController();
  TextEditingController markController = TextEditingController();
  TextEditingController priceUnitaryController = TextEditingController();
  TextEditingController quantityPartController = TextEditingController();

  get loading => _loading;

  double? get sumValue => _sumValue;

  set loading(value) {
    _loading = value;
    notifyListeners();
  }

  set sumValue(double? value) {
    _sumValue = value;
    notifyListeners();
  }

  set isMechanic(value) {
    _isMechanic = value;
    notifyListeners();
  }

  Future<void> _init(int id) async {
    _loading= true;
    notifyListeners();
    service = await _repository.getServiceById(id);
    if(service?.observations.isNotEmpty ?? false){
      observations.addAll(service?.observations ?? []);
    }

    if(service?.purchaseItems.isNotEmpty ?? false){
      purchasePart.addAll(service?.purchaseItems ?? []);
    }

   _statusCode = service?.status;

     _isMechanic = UserContext().id != 1 ?  true :  false;

    _loading= false;
    notifyListeners();
  }


  /// adicionar uma observação na listagem
  void addObservation(Observation service) {
    observations.add(service);
    observationServiceController.clear();
    notifyListeners();
  }

  /// adicionar uma itens de compra na listagem
  void addPurchasePart(PurchaseItem service) {
    purchasePart.add(service);
    partController.clear();
    markController.clear();
    priceUnitaryController.clear();
    quantityPartController.clear();
    sumValue = 0.0;
    notifyListeners();
  }


  void _calcTotal() {
    final qtd = int.tryParse(quantityPartController.text) ?? 0;
    final preco = double.tryParse(priceUnitaryController.text) ?? 0;
    sumValue = qtd * preco;
    notifyListeners();
  }

  Future<bool> _saveForm() async {
    try {
      final repositoryService = RepositoryService();
      final useCaseService = UseCaseService(repositoryService);

      final success = await useCaseService.updateService(
      service!.id!, _statusCode!,
          observations: observations.map((o) => o.toJson()).toList(),
          purchaseItems: purchasePart.map((p) => p.toJson()).toList(),
      );

      return success;
    } catch (e) {
      return false;
    }
  }

}



/// Tela principal com abas
class ServiceFormMechanic extends StatelessWidget {
  const  ServiceFormMechanic(this.id);

  final int id;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceFormMechanicSate(id),
      child: Consumer<ServiceFormMechanicSate>(
        builder: (_, state, __) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
        floatingActionButton:  state._isMechanic ? Padding(
          padding: const EdgeInsets.only(left: 30),
          child: _SaveButton(),
        ) : null,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: const Text("Formulário do Serviço"),
              bottom: const TabBar(
                tabs: [
                  Tab(text: "Informações"),
                  Tab(text: "Itens de compra"),
                  Tab(text: "Observações"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                const InfoTabs(),
                const _PurchaseItems(),
                _Observations(),
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}

/// Aba: Informações
class InfoTabs extends StatelessWidget {
  const InfoTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceFormMechanicSate>(
      builder: (context, state, child) {


        if(state._loading){
          return Center(child: CircularProgressIndicator(),);
        }
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mecânico',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Divider(
                color:  Colors.blue.shade700,
              ),
              InfoRow(label: "Nome", value: state.service?.mechanicName ?? ''),
              InfoRow(label: "Emai-l", value: state.service?.mechanicEmail ?? ''),
              SizedBox(height: 30,),
              Text(
                'Cliente',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Divider(
                color:  Colors.blue.shade700,
              ),
              InfoRow(label: "Nome completo", value: '${state.service?.customerName ?? ' '} ${state.service?.customerSurname ?? ' '}'),
              InfoRow(label: "Documento", value: state.service?.customerDocument ?? ''),
              InfoRow(label: "Emai-l", value: state.service?.customerEmail ?? ''),
              InfoRow(label: "Whatsapp", value: state.service?.customerWhatsapp ?? ''),
              SizedBox(height: 30,),
              Text(
                'Veículo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Divider(
                color:  Colors.blue.shade700,
              ),
              InfoRow(label: "Marca", value: state.service?.vehicleBrand ?? ''),
              InfoRow(label: "Modelo", value: state.service?.vehicleModel ?? ''),
              InfoRow(label: "Placa", value: state.service?.vehiclePlate ?? ''),
              InfoRow(label: "Cor", value: state.service?.vehicleColor ?? ''),
              SizedBox(height: 30,),
              Text(
                'Serviço',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Divider(
                color:  Colors.blue.shade700,
              ),
          ServiceStatusDropdown(
            value: state._statusCode ?? 0,
            onChanged: (code) => state.setSituation(code),
          ),
            ],
          ),
        );
      },
    );
  }
}


class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}



/// Aba: Itens de compra
class _PurchaseItems extends StatelessWidget {
  const _PurchaseItems({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceFormMechanicSate>(context, listen: true);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(
           20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Compra de peças',
                style: theme.textTheme.titleLarge,
              ),
              if (state._isDetails != true && state._isMechanic)
                GestureDetector(
                  onTap: () => showVehicleModal(context),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (state.purchasePart.isEmpty) ...[
                  Text(
                    'Nenhuma peça comprada',
                    style: theme.textTheme.labelSmall!
                        .copyWith(color: theme.disabledColor, fontSize: 15),
                  ),
                ] else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.purchasePart.length,
                      itemBuilder: (context, index) {
                        var item = state.purchasePart[index];

                        return _ItemPurchase(
                          mark: item.brand ?? '',
                          part: item.part ?? '',
                          quantity: item.quantity.toString(),
                          priceTotal:
                          item.totalPrice?.toStringAsFixed(2) ?? '0.00',
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}



void showVehicleModal(BuildContext context) {
  final state = Provider.of<ServiceFormMechanicSate>(context, listen: false);
  showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return ChangeNotifierProvider.value(
        value: state,
        child: AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text('Adicionar peça '),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DefaultTextField(
                  header: 'Peça',
                  isRequired: true,
                  controller: state.partController,
                  maxLength: 15,
                ),
                DefaultTextField(
                  header: 'Marca',
                  isRequired: true,
                  controller: state.markController,
                  maxLength: 25,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DefaultTextField(
                        header: 'Preço uni.',
                        isRequired: true,
                        controller: state.priceUnitaryController,
                        maxLength: 10,
                        textInputType: TextInputType.number,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DefaultTextField(
                        header: 'Qtd.',
                        isRequired: true,
                        controller: state.quantityPartController,
                        maxLength: 10,
                        textInputType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Preço total: ',
                      style: TextStyle(color: theme.disabledColor),
                    ),
                    Consumer<ServiceFormMechanicSate>(
                      builder: (context, state, _) {
                        return Text(
                            'R\$ ${state.sumValue?.toStringAsFixed(2) ?? '0,00'}');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Colors.blueAccent,
                ),
              ),
              onPressed: () {
                var quantity = int.tryParse(state.quantityPartController.text);
                var priceUnitary =
                double.tryParse(state.priceUnitaryController.text);
                var priceTotal = priceUnitary! * quantity!;
                var purchasePart = PurchaseItem(
                  unitPrice: priceUnitary,
                  part: state.partController.text,
                  quantity: quantity,
                  totalPrice: priceTotal,
                  brand: state.markController.text, serviceId: 0,
                );

                state.addPurchasePart(purchasePart);
                Navigator.pop(context);
              },
              child: Text('Adicionar'),
            ),
          ],
        ),
      );
    },
  );
}

class _ItemPurchase extends StatelessWidget {
  const _ItemPurchase({
    required this.part,
    required this.mark,
    required this.priceTotal,
    required this.quantity,
  });

  final String part;
  final String mark;
  final String priceTotal;
  final String quantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Peça: ', style: TextStyle(fontSize: 15)),
                    Text(part,
                        style: TextStyle(color: theme.disabledColor),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
                SizedBox(
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Marca: ', style: TextStyle(fontSize: 15)),
                      Text(
                        mark,
                        style: TextStyle(color: theme.disabledColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Qtd.: ', style: TextStyle(fontSize: 15)),
                    Text(quantity,
                        style: TextStyle(color: theme.disabledColor),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
                SizedBox(
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Preço total: ', style: TextStyle(fontSize: 15)),
                      Expanded(
                        child: Text('R\$ $priceTotal',
                            style: TextStyle(color: theme.disabledColor),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }
}




/// card para a observação
class _Observations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceFormMechanicSate>(context, listen: true);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(
            20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Observação',
                style: theme.textTheme.titleLarge,
              ),
              if (state._isDetails != true && state._isMechanic )
                GestureDetector(
                  onTap: () => showObservationModal(context),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (state.observations.isEmpty) ...[
                  Text(
                    'Nenhuma observação',
                    style: theme.textTheme.labelSmall!
                        .copyWith(color: theme.disabledColor, fontSize: 15),
                  ),
                ] else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.observations.length,
                      itemBuilder: (context, index) {
                        var item = state.observations[index];
                        return _ItemObservation(
                            observation: item.description ?? '',
                            hour: '${item.date?.hour}:${item.date!.minute}',
                            date: DateFormat('dd/MM/yyyy').format(item.date!));
                      },
                    ),
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}









void showObservationModal(BuildContext context) {
  final state = Provider.of<ServiceFormMechanicSate>(context, listen: false);
  showDialog(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('Adicionar observação'),
        content: SizedBox(
          width: 300,
          height: 210,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 200,
                child: DefaultTextField(
                  bigField: true,
                  header: 'Observação',
                  isRequired: false,
                  controller: state.observationServiceController,
                  maxLength: 200,
                ),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Colors.blueAccent,
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Colors.blueAccent,
              ),
            ),
            onPressed: () {
              var observations = Observation(
                  description: state.observationServiceController.text,
                  date: DateTime.now(),
                  serviceId: 0
              );

              state.addObservation(observations);

              Navigator.pop(context);
            },
            child: Text('Adicionar'),
          ),
        ],
      );
    },
  );
}









class _ItemObservation extends StatelessWidget {
  const _ItemObservation(
      {required this.observation, required this.hour, required this.date});

  final String observation;
  final String hour;
  final String date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Data: ', style: TextStyle(fontSize: 15)),
                    Text(date,
                        style: TextStyle(color: theme.disabledColor),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
                SizedBox(
                  width: 130,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Hora: ', style: TextStyle(fontSize: 15)),
                      Text(
                        hour,
                        style: TextStyle(color: theme.disabledColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Anotação:', style: TextStyle(fontSize: 15)),
                const SizedBox(height: 5),
                Text(
                  observation,
                  style: TextStyle(color: theme.disabledColor),
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
            Divider(
              color: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }
}


/// Botão para salvar edição
class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceFormMechanicSate>(context);

    return GestureDetector(
      onTap: () async {
        var result  =  await state._saveForm();

        if (result == true) {
          if(context.mounted){
            Navigator.pop(context);
          }

          Fluttertoast.showToast(
            msg: "Salvo com sucesso",
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }
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
            child: Text('Salvar'),
          ),
        ),
      ),
    );
  }
}

class ServiceStatusDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const ServiceStatusDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceFormMechanicSate>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: 'Situação',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        dropdownColor: Colors.blue.shade700,
        items: const [
          DropdownMenuItem(value: 0, child: Text('Em andamento')),
          DropdownMenuItem(value: 1, child: Text('Lavação')),
          DropdownMenuItem(value: 2, child: Text('Finalizado')),
          DropdownMenuItem(value: 3, child: Text('Em análise')),
        ],
        onChanged:  state._isMechanic ?  (value) {
          if (value != null) onChanged(value);
        } : null
      ),
    );
  }
}