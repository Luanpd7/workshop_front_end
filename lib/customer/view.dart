import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/customer/entities/address.dart';
import 'package:workshop_front_end/domain/use_case_customer.dart';
import 'package:workshop_front_end/repository/repository_customer.dart';
import 'package:workshop_front_end/util/mask.dart';
import '../domain/use_case_service.dart';
import '../repository/repository_vehicle.dart';
import '../service/entities/service.dart';
import '../service/entities/vehicle.dart';
import '../util/modal.dart';
import 'entities/customer.dart';
import 'list_customer.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ServiceState with ChangeNotifier {
  ServiceState({Customer? customer, bool? isDetails}) {
    quantityPartController.addListener(sumTotal);
    priceUnitaryController.addListener(sumTotal);
    _init(customer: customer, isDetails: isDetails);
  }

  Customer? _customer;

  final RepositoryService _repository = RepositoryService();

  List<VehicleType> _vehicles = [];

  VehicleType? _selectedVehicle;

  File? _imageFile;

  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController observationController = TextEditingController();
  TextEditingController cepController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController roadController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController neighborhoodController = TextEditingController();

  /// controller of service form
  TextEditingController observationServiceController = TextEditingController();
  TextEditingController partController = TextEditingController();
  TextEditingController markController = TextEditingController();
  TextEditingController priceUnitaryController = TextEditingController();
  TextEditingController quantityPartController = TextEditingController();

  TextEditingController yearFabricationController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController plateController = TextEditingController();

  List<Observation> observations = [];
  List<PurchaseItem> purchasePart = [];

  final formKey = GlobalKey<FormState>();

  bool _isDetails = false;

  double? _sumValue;

  bool _isCPF = false;

  get isCPF => _isCPF;

  double? get sumValue => _sumValue;

  get isDetails => _isDetails;

  File? get imageFile => _imageFile;

  List<VehicleType> get vehicles => _vehicles;

  VehicleType? get selectedVehicle => _selectedVehicle;

  Customer? get customer => _customer;

  set customer(Customer? value) {
    _customer = value;
    notifyListeners();
  }

  set sumValue(double? value) {
    _sumValue = value;
    notifyListeners();
  }

  set imageFile(File? value) {
    _imageFile = value;
    notifyListeners();
  }

  set selectVehicle(VehicleType? vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  set isCPF(value) {
    documentController.clear();
    _isCPF = value;
    notifyListeners();
  }

  set isDetails(value) {
    _isDetails = value;
    notifyListeners();
  }

  Future<void> _init({Customer? customer, bool? isDetails}) async {
    loadVehicles();
    if (customer != null && (isDetails ?? false)) {
      isDetails = isDetails;
      _customer = customer;
      fillFieldsFromCustomer(customer);
    } else {
      clearForm();
    }
    notifyListeners();
  }

  Future<bool?> saveForm({bool? isEdit = false}) async {
    /// TODO refatorar
    try {
      customer = Customer(
        id: customer?.id,
        name: nameController.text,
        surname: surnameController.text,
        whatsapp: whatsappController.text,
        email: emailController.text,
        document: documentController.text,
        observation: observationController.text,
        address: Address(
          cep: cepController.text,
          city: cityController.text,
          neighborhood: neighborhoodController.text,
          road: roadController.text,
          number: numberController.text,
        ),
      );

      var listDocuments = [];
      final repository = RepositoryCustomer();
      final useCaseCustomer = UseCaseCustomer(repository);

      listDocuments
        ..clear()
        ..addAll(
          await useCaseCustomer.getAllDocuments(),
        );

      if (!listDocuments.contains(customer?.document)) {
        await useCaseCustomer.addCustomer(customer!);
      }

      var vehicle = Vehicle(
        model: modelController.text,
        color: colorController.text,
        plate: plateController.text,
        manufactureYear: int.tryParse(yearFabricationController.text) ?? 0,
        type: selectedVehicle!,
      );


      var purchase = PurchaseItem(
        quantity: int.tryParse(quantityPartController.text) ?? 0,
        part: partController.text,
        brand: brandController.text,
        totalPrice: sumValue,
        unitPrice: double.tryParse(priceUnitaryController.text),
      );

      var observation = Observation(
        observation: observationServiceController.text
      );

      List<Observation> observations = [observation];
      List<PurchaseItem> purchaseItems = [purchase];

      final service = Service(
        vehicle: vehicle,
        customer: customer!,
        entryDate:  DateTime.now(),
        observations: observations,
        purchaseItems: purchaseItems,
        status: 0,
        imagePath: '',
      );

      final repositoryService = RepositoryService();
      final useCaseService = UseCaseService(repositoryService);

      await useCaseService.addService(service);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadVehicles() async {
    _vehicles = await _repository.listVehiclesTypes();
    notifyListeners();
  }

  Future<bool> onPressedDeleteCustomer({required int id}) async {
    final repository = RepositoryCustomer();
    final useCaseCustomer = UseCaseCustomer(repository);

    final result = await useCaseCustomer.deleteCustomer(id);

    return result;
  }

  Future<bool> searchCEP(String cep) async {
    final repository = RepositoryCustomer();
    final useCaseCustomer = UseCaseCustomer(repository);

    try {
      final result = await useCaseCustomer.searchCEP(cep);
      cityController.text = result?.city ?? '';
      roadController.text = result?.road ?? '';
      neighborhoodController.text = result?.neighborhood ?? '';
      return true;
    } catch (e) {
      return false;
    }
  }

  void fillFieldsFromCustomer(Customer customer) {
    nameController.text = customer.name ?? '';
    surnameController.text = customer.surname ?? '';
    emailController.text = customer.email ?? '';
    documentController.text = customer.document ?? '';
    whatsappController.text = customer.whatsapp ?? '';
    observationController.text = customer.observation ?? '';
    cepController.text = customer.address?.cep ?? '';
    cityController.text = customer.address?.city ?? '';
    roadController.text = customer.address?.road ?? '';
    numberController.text = customer.address?.number ?? '';
    neighborhoodController.text = customer.address?.neighborhood ?? '';
  }

  void clearForm() {
    nameController.clear();
    surnameController.clear();
    emailController.clear();
    documentController.clear();
    whatsappController.clear();
    observationController.clear();
    cepController.clear();
    cityController.clear();
    roadController.clear();
    numberController.clear();
    neighborhoodController.clear();
  }

  void addObservation(Observation service) {
    observations.add(service);
    observationServiceController.clear();
    notifyListeners();
  }

  void addPurchasePart(PurchaseItem service) {
    purchasePart.add(service);
    partController.clear();
    markController.clear();
    priceUnitaryController.clear();
    quantityPartController.clear();
    sumValue = 0.0;
    notifyListeners();
  }

  void sumTotal() {
    if (quantityPartController.text.isNotEmpty &&
        priceUnitaryController.text.isNotEmpty) {
      var quantity = int.tryParse(quantityPartController.text) ?? 0;

      var priceUnitary = double.tryParse(priceUnitaryController.text) ?? 0.0;
      sumValue = priceUnitary * quantity;
      notifyListeners();
    }
  }

  void selectPhoto(BuildContext context) {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Tirar foto'),
            onTap: () async {
              final picked = await picker.pickImage(source: ImageSource.camera);
              if (picked != null) {
                imageFile = File(picked.path);
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Escolher da galeria'),
            onTap: () async {
              final picked =
                  await picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                imageFile = File(picked.path);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class RegisterCustomer extends StatelessWidget {
  const RegisterCustomer({required this.isDetails});

  final bool isDetails;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Consumer<ServiceState>(
            builder: (context, state, Widget? _) {
              state.isDetails = isDetails;
              return Form(
                key: state.formKey,
                child: Column(
                  children: [
                    if (state.customer?.id == null) ...[
                      _SelectedCustomer(),
                    ] else ...[
                      _SaveEdit(),
                    ],
                    _InfoCardCustomer(),
                    _InfoCardAddress(),
                    _InfoCardObservation(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoCardCustomer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<ServiceState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Text(
            'Informações do cliente',
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
                _TextField(
                  header: 'Nome',
                  controller: state.nameController,
                  isRequired: true,
                  validator: validator,
                  maxLength: 25,
                  enabled: state.isDetails,
                ),
                _TextField(
                  header: 'Sobrenome',
                  controller: state.surnameController,
                  maxLength: 25,
                  enabled: state.isDetails,
                ),
                _TextField(
                  header: 'Documento',
                  controller: state.documentController,
                  isRequired: true,
                  validator: validator,
                  mask: state.isCPF ? cpfMask : cnpjMask,
                  isFieldDocument: true,
                  enabled: state.isDetails,
                ),
                _TextField(
                  header: 'Whatsapp',
                  controller: state.whatsappController,
                  isRequired: true,
                  validator: validator,
                  mask: phoneMask,
                  enabled: state.isDetails,
                ),
                _TextField(
                  header: 'Emai-l',
                  controller: state.emailController,
                  maxLength: 25,
                  enabled: state.isDetails,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _InfoCardAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context, listen: true);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Text(
            'Endereço do cliente',
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
                _TextField(
                  header: 'CEP',
                  controller: state.cepController,
                  isRequired: true,
                  validator: validator,
                  mask: cepMask,
                  isFieldCEP: true,
                  enabled: state.isDetails,
                ),
                _TextField(
                  header: 'Cidade',
                  controller: state.cityController,
                  isRequired: true,
                  validator: validator,
                  enabled: state.isDetails,
                ),
                _TextField(
                  header: 'Bairro',
                  controller: state.neighborhoodController,
                  isRequired: true,
                  validator: validator,
                  enabled: state.isDetails,
                ),
                _TextField(
                  header: 'Logadradouro',
                  controller: state.roadController,
                  isRequired: true,
                  validator: validator,
                  enabled: state.isDetails,
                ),
                _TextField(
                  header: 'Numero',
                  controller: state.numberController,
                  isRequired: true,
                  validator: validator,
                  enabled: state.isDetails,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _InfoCardObservation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context, listen: true);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: Text(
            'Observações',
            style: theme.textTheme.titleLarge,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: _TextField(
              header: 'Observações',
              controller: state.observationController,
              maxLength: 200,
              enabled: state.isDetails,
            ),
          ),
        )
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.header,
    required this.controller,
    this.isRequired = false,
    this.validator,
    this.maxLength = 50,
    this.mask,
    this.isFieldDocument = false,
    this.isFieldCEP = false,
    this.enabled = true,
  });

  final String header;
  final bool? isRequired;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final int maxLength;
  final TextInputFormatter? mask;
  final bool isFieldDocument;
  final bool isFieldCEP;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<ServiceState>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            enabled: !state.isDetails,
            onChanged: (value) {
              if (isFieldCEP && value.length == 10) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialogUtil(
                      title: "Prosseguir?",
                      content: "Deseja buscar automaticamente o endereço?",
                      labelButtonPrimary: 'Confirmar',
                      onPressedPrimary: () async {
                        final cep = state.cepController.text
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        state.searchCEP(cep);

                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade700, width: 1),
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              suffixIcon: isFieldDocument
                  ? GestureDetector(
                      onTap: () {
                        state.isCPF = !state.isCPF;
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Text(
                          state.isCPF ? 'CNPJ' : 'CPF',
                          style: theme.textTheme.labelSmall!.copyWith(
                              color: theme.disabledColor,
                              decoration: TextDecoration.underline,
                              decorationColor: theme.disabledColor,
                              fontSize: 13),
                        ),
                      ),
                    )
                  : null,
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

class _SelectedCustomer extends StatelessWidget {
  const _SelectedCustomer();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListCustomer(selectedCustomer: true),
          ),
        );

        if (result != null) {
          state.fillFieldsFromCustomer(result);
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
            child: Text('Selecionar cliente'),
          ),
        ),
      ),
    );
  }
}

class _SaveEdit extends StatelessWidget {
  const _SaveEdit();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context);

    return GestureDetector(
      onTap: () async {
        var result = await state.saveForm(isEdit: true);

        if (result == true) {
          Navigator.pop(context);

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

String? validator(String? value) {
  if (value!.isEmpty) {
    return 'Precisa preencher o campo';
  }

  if (value.trim().length < 3) {
    return 'Minimo de caracteres é 3';
  }
  return null;
}
