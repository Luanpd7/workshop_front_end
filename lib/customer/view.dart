import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/customer/entities/address.dart';
import 'package:workshop_front_end/domain/use_case_customer.dart';
import 'package:workshop_front_end/repository/repository_customer.dart';
import 'package:workshop_front_end/util/mask.dart';
import '../util/modal.dart';
import 'entities/customer.dart';
import 'list_customer.dart';

class CustomerState with ChangeNotifier {
  CustomerState({Customer? customer}) {
    _init(customer: customer);
  }

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

  final _formKey = GlobalKey<FormState>();

  bool _isDetails = false;

  bool _isCPF = false;

  get isCPF => _isCPF;

  get isDetails => _isDetails;

  set isCPF(value) {
    _isCPF = value;
    notifyListeners();
  }

  set isDetails(value) {
    print('alterando para value = $value');
    print('antes = $_isDetails');
    _isDetails = value;
    print('depois = $_isDetails');
    notifyListeners();
  }

  Future<void> _init({Customer? customer, bool? isDetails}) async {
    _isDetails = isDetails ?? false;
    if (customer != null && (isDetails ?? false)) {
      fillFieldsFromCustomer(customer);
    } else {
      clearForm();
    }
  }

  Future<bool?> saveForm(Customer customer) async {
    try {
      var listDocuments = [];
      final repository = RepositoryCustomer();
      final useCaseCustomer = UseCaseCustomer(repository);

      listDocuments
        ..clear()
        ..addAll(
          await useCaseCustomer.getAllDocuments(),
        );

      if (listDocuments.contains(customer.document)) {
        Fluttertoast.showToast(
          msg: "Cliente já cadastrado",
          backgroundColor: Colors.yellow,
          textColor: Colors.orange,
        );
        return null;
      }

      await useCaseCustomer.addCustomer(customer);

      return true;
    } catch (e) {
      return false;
    }
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
}

class RegisterCustomer extends StatelessWidget {
  const RegisterCustomer({this.customer, this.isDetails = false});

  final Customer? customer;

  final bool isDetails;

  @override
  Widget build(BuildContext context) {
    Provider.of<CustomerState>(context)
        ._init(customer: customer, isDetails: isDetails);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Consumer<CustomerState>(
            builder: (context, state, Widget? _) {
              return Form(
                key: state._formKey,
                child: Column(
                  children: [
                    if (!state.isDetails) _SelectedCustomer(),
                    _InfoCardCustomer(),
                    _InfoCardAddress(),
                    _InfoCardObservation(),
                    if (!state.isDetails) _SaveButton(),
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
    final state = Provider.of<CustomerState>(context, listen: true);
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
                  maxLength: 15,
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
    final state = Provider.of<CustomerState>(context, listen: true);
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
    final state = Provider.of<CustomerState>(context, listen: true);
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
    final state = Provider.of<CustomerState>(context, listen: true);
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

class _SaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<CustomerState>(context, listen: true);
    return ElevatedButton(
      child: Text('Salvar'),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Colors.blue.shade700,
        ),
      ),
      onPressed: () async {
        if (state._formKey.currentState!.validate()) {
          final customer = Customer(
            name: state.nameController.text,
            surname: state.surnameController.text,
            whatsapp: state.whatsappController.text,
            email: state.emailController.text,
            document: state.documentController.text,
            observation: state.observationController.text,
            address: Address(
              cep: state.cepController.text,
              city: state.cityController.text,
              neighborhood: state.neighborhoodController.text,
              road: state.roadController.text,
              number: state.numberController.text,
            ),
          );

          final result = await state.saveForm(customer);

          if (result == true) {
            state.clearForm();
            Fluttertoast.showToast(
              msg: "Cadastrado com sucesso!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            if(context.mounted) {
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
    );
  }
}

class _SelectedCustomer extends StatelessWidget {
  const _SelectedCustomer();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<CustomerState>(context);

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

String? validator(String? value) {

  if (value!.isEmpty) {
    return 'Precisa preencher o campo';
  }

  if (value.trim().length < 3) {
    return 'Minimo de caracteres é 3';
  }
  return null;
}
