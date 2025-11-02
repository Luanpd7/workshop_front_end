import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/domain/use_case_service.dart';
import 'package:workshop_front_end/domain/use_case_vehicle.dart';
import 'package:workshop_front_end/repository/repository_vehicle.dart';
import 'package:workshop_front_end/util/mask.dart';
import '../customer/entities/customer.dart';
import '../domain/use_case_customer.dart';
import '../login/entities/login.dart';
import '../login/view.dart';
import '../repository/repository_customer.dart';
import '../repository/repository_service.dart';
import '../service/entities/service.dart';
import '../service/entities/vehicle.dart';
import '../util/modal.dart';
import 'dart:io';

class VehicleState with ChangeNotifier {
  VehicleState(BuildContext context, Vehicle? vehicle,)  {_init(context, vehicle);}

  bool _loading = false;

  List<VehicleType> _vehicles = [];

  final listCustomer = <Customer>[];

  VehicleType? _selectedVehicle;

  Customer? _selectedCustomer;

  final formKey = GlobalKey<FormState>();

  User? user;

  bool _isDetails = false;

  bool _isEdit = false;


  TextEditingController yearFabricationController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController plateController = TextEditingController();


  get loading => _loading;

  get isDetails => _isDetails;

  get isEdit => _isEdit;

  List<VehicleType> get vehicles => _vehicles;

  VehicleType? get selectedVehicle => _selectedVehicle;

  Customer? get selectedCustomer => _selectedCustomer;


  set loading(value) {
    _loading = value;
    notifyListeners();
  }

  set selectVehicle(VehicleType? vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  set selectCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  Future<void> _init(
 BuildContext context,
   Vehicle? vehicle,
    ) async {

    user = Provider.of<LoginState>(context, listen: false).user;
    await loadData();

    if(vehicle != null){
      _isEdit = false;
      yearFabricationController.text = vehicle.manufactureYear.toString() ;
      colorController.text = vehicle.color ;
      modelController.text = vehicle.model ;
      brandController.text = vehicle.brand ;
      plateController.text = vehicle.plate ;


      if(listCustomer.any((cs) => cs.id == vehicle.idCustomer ,)){
        var item = listCustomer.where((cs) => cs.id == vehicle.idCustomer ,).first;
        _selectedCustomer = item;
      }

      if(vehicles.any((v) => v.id == vehicle.type ,)){
        var item = vehicles.where((cs) => cs.id == vehicle.type ,).first;
        _selectedVehicle = item;
      }
    }
    notifyListeners();
  }

  Future<void> loadData() async {
    loading = false;
    final repositoryCustomer = RepositoryCustomer();
    final useCaseCustomer = UseCaseCustomer(repositoryCustomer);

    final repositoryVehicle = RepositoryService();


    var result = await useCaseCustomer.listCustomers(idUser: user?.id);
    _vehicles = await repositoryVehicle.listVehiclesTypes();

    listCustomer
      ..clear()
      ..addAll(result);
    loading = false;
  }

  Future<bool?> saveForm() async {

    final repositoryVehicle = RepositoryVehicle();
    final useCaseService = UseCaseVehicle(repositoryVehicle);

    final vehicle = Vehicle(
      brand: brandController.text,
      model: modelController.text, color: colorController.text,
        plate: plateController.text,
        manufactureYear: int.tryParse(yearFabricationController.text) ?? 0, type: selectedVehicle?.id ?? 0,
    idCustomer: selectedCustomer?.id ?? 0,
    );

    useCaseService.addVehicle(vehicle: vehicle);

    return true;
  }
}

class RegisterVehicle extends StatelessWidget {
   RegisterVehicle({required this.isEdit, this.vehicle});

final bool isEdit;

final Vehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adicionar veículo"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: ChangeNotifierProvider(
            create: (context) => VehicleState(context, vehicle),
            child: Consumer<VehicleState>(
              builder: (context, state, Widget? _) {
                return Form(
                  key: state.formKey,
                  child: state._loading ? Center(child: CircularProgressIndicator()) :

                  Column(
                    children: [
                      if(!state._isDetails)...[
                        _SaveButton(),
                      ],
                      _InfoCardCustomer(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// card para o cliente no formulário
class _InfoCardCustomer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<VehicleState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Text(
            'Informações do veículo',
            style: theme.textTheme.titleLarge,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: DropdownButtonFormField(
                    value: state.selectedCustomer,
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    decoration: InputDecoration(
                      label: Text(
                        'Selecionar cliente',
                        style: theme.textTheme.labelSmall!
                            .copyWith(color: theme.disabledColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.blue.shade700, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items:
                        state.listCustomer.map(
                          (customer) {
                        return DropdownMenuItem<Customer>(
                          value: customer,
                          child: Text('${customer.id} - ${customer.name ?? ''}'),
                        );
                      },
                    ).toList(),
                    onChanged: (selected) {
                      state.selectCustomer= selected as Customer;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: DropdownButtonFormField(
                    value: state.selectedVehicle,
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    decoration: InputDecoration(
                      label: Text(
                        'Tipo de veículo',
                        style: theme.textTheme.labelSmall!.copyWith(color: theme.disabledColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: state.vehicles.map(
                          (vehicle) {
                        return DropdownMenuItem<VehicleType>(
                          value: vehicle,
                          child: Text('${vehicle.id} - ${vehicle.name ?? ''}'),
                        );
                      },
                    ).toList(),
                    onChanged: (selected) {
                      state.selectVehicle = selected;
                    },
                  ),
                ),
                _TextField(
                  header: 'Marca',
                  controller: state.brandController,
                  maxLength: 25,
                  enabled: state.isDetails,
                  validator: validator,
                  isRequired: true,
                ),
                _TextField(
                  header: 'Modelo',
                  controller: state.modelController,
                  maxLength: 25,
                  enabled: state.isDetails,
                  validator: validator,
                  isRequired: true,
                ),
                _TextField(
                  textInputType: TextInputType.number,
                  header: 'Ano de fabricação',
                  controller: state.yearFabricationController,
                  isRequired: true,
                  validator: validator,
                  enabled: state.isDetails,
                ),
                _TextField(
                  header: 'Cor',
                  controller: state.colorController,
                  isRequired: true,
                  validator: validator,
                  enabled: state.isDetails,
                ),
                _TextField(
                  header: 'Placa',
                  controller: state.plateController,
                  maxLength: 25,
                  enabled: state.isDetails,
                  isRequired: true,
                  validator: validator,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}



/// Util para os campos de textos
class _TextField extends StatelessWidget {
  const _TextField({
    required this.header,
    required this.controller,
    this.isRequired = false,
    this.validator,
    this.maxLength = 50,
    this.mask,
    this.isFieldDocument = false,
    this.enabled = true,
    this.textInputType,
  });

  final String header;
  final bool? isRequired;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final int maxLength;
  final TextInputFormatter? mask;
  final bool isFieldDocument;
  final bool enabled;
  final TextInputType? textInputType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<VehicleState>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            keyboardType: textInputType ?? TextInputType.text,
            enabled: !state.isDetails,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade700, width: 1),
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        header,
                        style: theme.textTheme.labelSmall!
                            .copyWith(color: theme.disabledColor),
                      ),
                      if (isRequired == true)
                        Text(
                          '*',
                          style: theme.textTheme.labelLarge!
                              .copyWith(color: Colors.red),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            inputFormatters: [
              if (mask != null) mask!,
            ],
            maxLength: maxLength,
            validator: validator,
            controller: controller,
          ),
        ],
      ),
    );
  }
}



/// Botão para salvar edição
class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<VehicleState>(context);

    return GestureDetector(
      onTap: () async {
        var result = await state.saveForm();

        if (result == true) {
          if(context.mounted){
            Navigator.pop(context);
          }

          Fluttertoast.showToast(
            msg: "Atualizado com sucesso",
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

/// Validação do formulário
String? validator(String? value) {
  if (value!.isEmpty) {
    return 'Precisa preencher o campo';
  }

  return null;
}
