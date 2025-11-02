
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/use_case_customer.dart';
import '../domain/use_case_service.dart';
import '../domain/use_case_vehicle.dart';
import '../login/entities/login.dart';
import '../login/view.dart';
import '../repository/repository_customer.dart';
import '../repository/repository_service.dart';
import '../repository/repository_vehicle.dart';
import 'entities/service.dart';
import 'entities/vehicle.dart';

/// Tela responsável pelo formulario de serviço,
/// usado na tela segunda tab quando vou cadastrar
/// um serviço e na quando vou editar um serviço

class ServiceState with ChangeNotifier {
  ServiceState() {
    _init();
  }

  bool _loading = false;

  final RepositoryService _repository = RepositoryService();

  List<Vehicle> _vehicles = [];

  List<User> _users = [];

  Vehicle? _selectedVehicle;

  User? _selectedUser;


  List<File> imageFiles = [];
  List<Uint8List> imageBytesList = [];


  List<File> audioFiles = [];



  List<Observation> observations = [];

  List<PurchaseItem> purchasePart = [];

  final formKey = GlobalKey<FormState>();

  bool _isDetails = false;

  bool _isEdit = false;

  double? _sumValue;

  /// controller of service form
  TextEditingController observationServiceController = TextEditingController();
  TextEditingController partController = TextEditingController();
  TextEditingController markController = TextEditingController();
  TextEditingController priceUnitaryController = TextEditingController();
  TextEditingController quantityPartController = TextEditingController();

  get loading => _loading;

  double? get sumValue => _sumValue;

  get isDetails => _isDetails;

  get isEdit => _isEdit;


  List<Vehicle> get vehicles => _vehicles;

  List<User> get users => _users;

  Vehicle? get selectedVehicle => _selectedVehicle;

  User? get selectedUser => _selectedUser;

  set loading(value) {
    _loading = value;
    notifyListeners();
  }

  set sumValue(double? value) {
    _sumValue = value;
    notifyListeners();
  }

  set selectVehicle(Vehicle? vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  set selectUser(User? user) {
    _selectedUser = user;
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

  Future<void> _init() async {
    await loadData();
    notifyListeners();
  }

  Future<void> loadData() async {
    loading = true;
    await getAllVehicles();
    await getAllMechanics();
    loading = false;
  }

  Future<void> getAllMechanics() async {
    final repositoryService = RepositoryService();
    final useCaseService = UseCaseService(repositoryService);

    var result = await useCaseService.getAllMechanics();

    users
      ..clear()
      ..addAll(result);
  }

  Future<void> getAllVehicles() async {
    final repository = RepositoryVehicle();
    final useCase = UseCaseVehicle(repository);

    var result = await useCase.getAllVehicles();

    vehicles
      ..clear()
      ..addAll(result);
  }


  Future<bool?> _saveForm(BuildContext context, {bool? isEdit = false}) async {
    var user = Provider.of<LoginState>(context, listen: false).user;
    try {


      final repositoryService = RepositoryService();
      final useCaseService = UseCaseService(repositoryService);




      final service = Service(vehicleId: selectedVehicle!.id!, status: 3, entryDate: DateTime.now(), idUser: selectedUser!.id!);
      final success = await useCaseService.initializeService(
        service: service,
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  void addImageFile(File file) {
    imageFiles.add(file);
    notifyListeners();
  }

  void addImageBytes(Uint8List bytes) {
    imageBytesList.add(bytes);
    notifyListeners();
  }

  void removeImageFile(File file) {
    imageFiles.remove(file);
    notifyListeners();
  }

  void removeImageBytes(Uint8List bytes) {
    imageBytesList.remove(bytes);
    notifyListeners();
  }

  void addAudioFile(File file) {
    audioFiles.add(file);
    notifyListeners();
  }

  void removeAudioFile(File file) {
    audioFiles.remove(file);
    notifyListeners();
  }

  void clearAudios() {
    audioFiles.clear();
    notifyListeners();
  }

  Future<bool> onPressedDeleteCustomer({required int id}) async {
    final repository = RepositoryCustomer();
    final useCaseCustomer = UseCaseCustomer(repository);

    final result = await useCaseCustomer.deleteCustomer(id);

    return result;
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

}

class RegisterService extends StatelessWidget {
  const RegisterService({super.key, this.service, this.isDetails = false});

  final ServiceDetails? service;

  final bool isDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Iniciar um serviço"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: ChangeNotifierProvider(
            create: (context) => ServiceState(),
            child: Consumer<ServiceState>(
              builder: (context, state, Widget? _) {
                if (state.loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Form(
                  child: Column(
                    children: [
                      _ButtonSave(),
                      _InfoCardVehicle(),
                      _InfoCardMechanic(),

                      if (!state.isDetails && !state.isEdit)
                        _InfoPhoto(
                        )
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

/// card para a informações do serviço
class _InfoCardVehicle extends StatelessWidget {
  const _InfoCardVehicle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<ServiceState>(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
          ),
          child: Text(
            'Veículo',
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
                DropdownButtonFormField(
                  value: state.selectedVehicle,
                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                  decoration: InputDecoration(
                    label: Text(
                      'Selecionar veículo',
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: theme.disabledColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue.shade700, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: state.vehicles.map(
                    (vehicle) {
                      return DropdownMenuItem<Vehicle>(
                        value: vehicle,
                        child:
                            Text('${vehicle.plate} - ${vehicle.model ?? ''}'),
                      );
                    },
                  ).toList(),
                  onChanged: (selected) {
                    state.selectVehicle = selected;
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

/// card para a informações do serviço
class _InfoCardMechanic extends StatelessWidget {
  const _InfoCardMechanic();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<ServiceState>(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
          ),
          child: Text(
            'Mecânico',
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
                DropdownButtonFormField(
                  value: state.selectedUser,
                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                  decoration: InputDecoration(
                    label: Text(
                      'Selecionar mecânico',
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: theme.disabledColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.blue.shade700, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: state.users.map(
                        (user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child:
                        Text('${user.id} - ${user.name}'),
                      );
                    },
                  ).toList(),
                  onChanged: (selected) {
                    state.selectUser = selected;
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

/// card para a compra de itens
class _InfoPurchase extends StatelessWidget {
  const _InfoPurchase();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context, listen: true);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 25,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Compra de peças',
                style: theme.textTheme.titleLarge,
              ),
              if (state.isDetails != true)
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

/// card para a observação
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
            vertical: 25,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Observação',
                style: theme.textTheme.titleLarge,
              ),
              if (state.isDetails != true)
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

class _InfoPhoto extends StatelessWidget {
  const _InfoPhoto();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final state = Provider.of<ServiceState>(context, listen: false);
    final picker = ImagePicker();

    if (source == ImageSource.camera) {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        state.addImageFile(File(photo.path));
      }
    } else {
      final List<XFile> photos = await picker.pickMultiImage();
      for (final photo in photos) {
        state.addImageFile(File(photo.path));
      }
    }
  }

  void _showPickerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Text(
            'Fotos iniciais',
            style: theme.textTheme.titleLarge,
          ),
        ),
        if (state.imageFiles.isNotEmpty || state.imageBytesList.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.imageFiles.length + state.imageBytesList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              Widget imageWidget;
              VoidCallback? onDelete;

              if (index < state.imageFiles.length) {
                final file = state.imageFiles[index];
                imageWidget = Image.file(file, fit: BoxFit.cover);
                onDelete = () => state.removeImageFile(file);
              } else {
                final bytes = state.imageBytesList[index - state.imageFiles.length];
                imageWidget = Image.memory(bytes, fit: BoxFit.cover);
                onDelete = () => state.removeImageBytes(bytes);
              }

              return Stack(
                children: [
                  Positioned.fill(child: imageWidget),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 15,
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        else
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 250,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue.shade700),
                  ),
                  onPressed: () => _showPickerMenu(context),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Anexar ou tirar foto'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}






/// Util para campo de texto
class DefaultTextField extends StatelessWidget {
  const DefaultTextField({
    required this.header,
    required this.controller,
    this.isRequired = false,
    this.bigField = false,
    this.validator,
    this.maxLength = 50,
    this.enabled = true,
    this.textInputType,
  });

  final String header;
  final bool? isRequired;
  final bool? bigField;
  final bool enabled;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final int maxLength;
  final TextInputType? textInputType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            enabled: enabled,
            keyboardType: textInputType ?? TextInputType.text,
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
            maxLength: maxLength,
            validator: validator,
            controller: controller,
          ),
        ],
      ),
    );
  }
}

/// Botão para salvar serviço
class _ButtonSave extends StatelessWidget {
  const _ButtonSave();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context);

    return GestureDetector(
      onTap: () async {
        if (state.formKey.currentState?.validate() ?? true) {
          final result = await state._saveForm(context);
          if (result == true) {
            Fluttertoast.showToast(
              msg: "Cadastrado com sucesso!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            if (context.mounted) {
              Navigator.pop(context);
            }
          } else if (result == false) {
            Fluttertoast.showToast(
              msg: "Erro ao cadastrar cliente!",
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        }
      },
      child: Container(
        height: 50,
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
    );
  }
}

/// Botão para salvar serviço
class _ButtonEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context);

    return GestureDetector(
      onTap: () async {
        state.isDetails = false;
        state.isEdit = true;
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
            child: Text('Editar'),
          ),
        ),
      ),
    );
  }
}

/// Botão para salvar serviço
class _ButtonSaveEdit extends StatelessWidget {
  _ButtonSaveEdit(this.vehicleId);

  final int vehicleId;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context);

    return GestureDetector(
      onTap: () async {
        final repo = RepositoryService();

        final success = true;
        //await repo.updateVehicle(vehicleId, updates);

        if (success == true) {
          Fluttertoast.showToast(
            msg: "Editado com sucesso!",
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          if (context.mounted) {
            Navigator.pop(context);
          }
        } else if (success == false) {
          Fluttertoast.showToast(
            msg: "Erro ao editar!",
            backgroundColor: Colors.red,
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
            child: Text('Salvar Alterações'),
          ),
        ),
      ),
    );
  }
}

void showVehicleModal(BuildContext context) {
  final state = Provider.of<ServiceState>(context, listen: false);
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
                    Consumer<ServiceState>(
                      builder: (__, state, _) {
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

void showObservationModal(BuildContext context) {
  final state = Provider.of<ServiceState>(context, listen: false);
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

String? validator(String? value) {
  if (value!.isEmpty) {
    return 'Precisa preencher o campo';
  }

  if (value.trim().length < 3) {
    return 'Minimo de caracteres é 3';
  }
  return null;
}

