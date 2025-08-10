import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/customer/entities/address.dart';
import 'package:workshop_front_end/domain/use_case_customer.dart';
import 'package:workshop_front_end/repository/repository_customer.dart';
import 'package:workshop_front_end/util/mask.dart';
import '../domain/use_case_service.dart';
import '../login/view.dart';
import '../repository/repository_service.dart';
import '../service/entities/service.dart';
import '../service/entities/vehicle.dart';
import '../util/modal.dart';
import 'entities/customer.dart';
import 'list_customer.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ServiceState with ChangeNotifier {
  ServiceState(
      {Customer? customer, bool? isDetails, ServiceDetails? serviceDetails}) {
    quantityPartController.addListener(sumTotal);
    priceUnitaryController.addListener(sumTotal);
    _init(
        customer: customer,
        details: isDetails,
        serviceDetails: serviceDetails);
  }

  Customer? _customer;

  bool _loading = false;

  final RepositoryService _repository = RepositoryService();

  List<VehicleType> _vehicles = [];

  VehicleType? _selectedVehicle;

  File? _imageFile;

  int? idCustomer;

  List<Observation> observations = [];

  List<PurchaseItem> purchasePart = [];

  final formKey = GlobalKey<FormState>();

  bool _isDetails = true;

  bool _isEdit = false;

  double? _sumValue;

  bool _isCPF = false;

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

  get isCPF => _isCPF;

  get loading => _loading;

  double? get sumValue => _sumValue;

  get isDetails => _isDetails;

  get isEdit => _isEdit;

  File? get imageFile => _imageFile;

  List<VehicleType> get vehicles => _vehicles;

  VehicleType? get selectedVehicle => _selectedVehicle;

  Customer? get customer => _customer;

  set loading(value) {
    _loading = value;
    notifyListeners();
  }

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

  set isEdit(value) {
    _isEdit = value;
    notifyListeners();
  }

  Future<void> _init(
      {Customer? customer,
      bool? details,
      ServiceDetails? serviceDetails}) async {
    loadVehicles();
    print('entrou');
    print('details $details');
    isDetails = details;
    if (serviceDetails != null) {

      fillFieldsFromServiceDetails(serviceDetails);
    }

    if (customer != null && (details ?? false)) {
      _customer = customer;
      fillFieldsFromCustomer(customer);
    } else {
      clearForm();
    }
    notifyListeners();
  }

  /// resgatar as informações do cliente nos formulários
  Customer? getFormCustomer(BuildContext context){
    var user = Provider.of<LoginState>(context, listen: false).user;

    customer = Customer(
      idUser: user.id!,
      id: idCustomer,
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
    return customer;
  }

  /// resgatar as informações do veiculo nos formulários
  Vehicle getFormVehicle(){
    final vehicle = Vehicle(
      model: brandController.text,
      color: colorController.text,
      plate: plateController.text,
      manufactureYear: int.parse(yearFabricationController.text),
      type: _selectedVehicle?.id ?? 0,
    );

    return vehicle;
  }

  Future<bool?> saveForm(BuildContext context, {bool? isEdit = false}) async {
    var user = Provider.of<LoginState>(context, listen: false).user;
    try {
      customer = getFormCustomer(context);

      var listDocuments = [];
      final repository = RepositoryCustomer();
      final useCaseCustomer = UseCaseCustomer(repository);

      final repositoryService = RepositoryService();
      final useCaseService = UseCaseService(repositoryService);

      listDocuments
        ..clear()
        ..addAll(
          await useCaseCustomer.getAllDocuments(),
        );

      Uint8List imageBytes = await imageFile?.readAsBytes() ?? Uint8List(0);

      final base64Image = base64Encode(imageBytes);

      final vehicle = getFormVehicle();

      int idCustomerNew;

      if (customer?.id == null) {
        idCustomerNew = await useCaseCustomer.addCustomer(customer!);
      } else {
        idCustomerNew = customer!.id!;
      }

      final success = await useCaseService.initializeService(
        idUser: user.id!,
        customer:
            customer?.id == null ? Customer(id: idCustomerNew) : customer!,
        vehicle: vehicle,
        observations: observations,
        items: purchasePart,
        status: 0,
        entryDate: DateTime.now(),
        imageBytes: base64Image,
      );

      return success;
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

  /// responsável por preencher os campos do cliente quando for detqlhes
  void fillFieldsFromCustomer(Customer customer) {
    idCustomer = customer.id;
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

  /// responsável por preencher os campos do veiculo quando for detqlhes
  void fillFieldsFromServiceDetails(ServiceDetails service) {
    brandController.text = service.vehicleModel;
    colorController.text = service.vehicleColor;
    plateController.text = service.vehiclePlate;
    yearFabricationController.text = service.manufactureYear.toString();
    selectVehicle =
        VehicleType(id: service.vehicleTypeId, name: service.vehicleType);
    observations.addAll(service.observations);
    purchasePart.addAll(service.purchaseItems);
  }

  /// Função para limpar campos
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

  /// Somar o total, tendo a unidade e a quantidade
  void sumTotal() {
    if (quantityPartController.text.isNotEmpty &&
        priceUnitaryController.text.isNotEmpty) {
      var quantity = int.tryParse(quantityPartController.text) ?? 0;

      var priceUnitary = double.tryParse(priceUnitaryController.text) ?? 0.0;
      sumValue = priceUnitary * quantity;
      notifyListeners();
    }
  }

  /// Selecionar uma foto da galeria ou abri a camera
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
              if(context.mounted){
                Navigator.pop(context);
              }
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

class RegisterCustomer extends StatelessWidget {
  const RegisterCustomer({super.key, required this.isDetails});

  final bool isDetails;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Consumer<ServiceState>(
            builder: (context, state, Widget? _) {
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

/// card para o cliente no formulário
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
                  textInputType: TextInputType.number,
                  header: 'Documento',
                  controller: state.documentController,
                  isRequired: true,
                  validator: validator,
                  mask: state.isCPF ? cpfMask : cnpjMask,
                  isFieldDocument: true,
                  enabled: state.isDetails,
                ),
                _TextField(
                  textInputType: TextInputType.number,
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

/// card para endereços no formulário
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

/// card para observações no formulário
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
    this.isFieldCEP = false,
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
  final bool isFieldCEP;
  final bool enabled;
  final TextInputType? textInputType;

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
            keyboardType: textInputType ?? TextInputType.text,
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

/// Opção de selecionar um cliente já cadastrado
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

/// Botão para salvar edição
class _SaveEdit extends StatelessWidget {
  const _SaveEdit();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context);

    return GestureDetector(
      onTap: () async {
        var result = await state.saveForm(context, isEdit: true);

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

  if (value.trim().length < 3) {
    return 'Minimo de caracteres é 3';
  }
  return null;
}
