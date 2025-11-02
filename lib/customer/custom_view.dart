import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/customer/entities/address.dart';
import 'package:workshop_front_end/domain/use_case_customer.dart';
import 'package:workshop_front_end/repository/repository_customer.dart';
import 'package:workshop_front_end/util/mask.dart';
import '../login/view.dart';
import '../util/modal.dart';
import 'entities/customer.dart';

class _CustomerState with ChangeNotifier {
  _CustomerState(this._customer){
    unawaited(_init(_customer));
  }

  Customer? _customer;

  bool _loading = false;

  int? idCustomer;

  final formKey = GlobalKey<FormState>();

  bool _isEdit = true;

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

  get loading => _loading;

  get isCPF => _isCPF;

  get isEdit => _isEdit;

  set isEdit(value) {
    _isEdit = value;
    notifyListeners();
  }

  set isCPF(value) {
    documentController.clear();
    _isCPF = value;
    notifyListeners();
  }

  Future<void> _init(Customer? customer, ) async {
    if(customer != null){
      _isEdit = false;
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

    notifyListeners();
  }

  Future<bool?> saveForm(BuildContext context) async {
    try {
      final repository = RepositoryCustomer();
      final useCaseCustomer = UseCaseCustomer(repository);
      var user = Provider.of<LoginState>(context, listen: false).user;

        await useCaseCustomer.addCustomer(
          Customer(
            idUser: user?.id,
              name: nameController.text,
              surname: surnameController.text,
              document: documentController.text,
              whatsapp: whatsappController.text,
              email: emailController.text,
              address: Address(
                city: cityController.text,
                cep: cepController.text,
                neighborhood: neighborhoodController.text,
                road: roadController.text,
                number: numberController.text,
              ),
              observation: observationController.text,),
        );


      return true;
    } catch (e) {
      return false;
    }
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


}

class RegisterCustomer extends StatelessWidget {
  const RegisterCustomer({super.key, required this.isEdit, this.customer});

  final bool isEdit;

  final Customer? customer;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _CustomerState(customer),
      child: Consumer<_CustomerState>(
        builder: (context, state, Widget? _) {
          return Scaffold(
            appBar: AppBar(
              title: isEdit ? Text("Cliente ${customer?.name}") : Text(
                  "Fomulário do cliente"),
              backgroundColor: Colors.blue.shade700,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isEdit) ...[
                        _ButtonEdit(customer: customer !),
                        _ButtonDelete(
                          id: customer!.id!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: state.formKey,
                  child: Column(
                    children: [
                      if (state._isEdit) ...[
                        _SaveButton(),
                      ],
                      _InfoCardCustomer(),
                      _InfoCardAddress(),
                      _InfoCardObservation(),
                    ],
                  ),
                ),
              ),
            ),
          )
          ;
        })
      );}
}

/// card para o cliente no formulário
class _InfoCardCustomer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<_CustomerState>(context);
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
                  enabled: state.isEdit,
                ),
                _TextField(
                  header: 'Sobrenome',
                  controller: state.surnameController,
                  maxLength: 25,
                  enabled: state.isEdit,
                ),
                _TextField(
                  textInputType: TextInputType.number,
                  header: 'Documento',
                  controller: state.documentController,
                  isRequired: true,
                  validator: validator,
                  mask: state.isCPF ? cpfMask : cnpjMask,
                  isFieldDocument: true,
                  enabled: state.isEdit,
                ),
                _TextField(
                  textInputType: TextInputType.number,
                  header: 'Whatsapp',
                  controller: state.whatsappController,
                  isRequired: true,
                  validator: validator,
                  mask: phoneMask,
                  enabled: state.isEdit,
                ),
                _TextField(
                  header: 'E-mail',
                  controller: state.emailController,
                  maxLength: 25,
                  enabled: state.isEdit,
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
    final state = Provider.of<_CustomerState>(context, listen: true);
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
                  enabled: state.isEdit,
                ),
                _TextField(
                  header: 'Cidade',
                  controller: state.cityController,
                  isRequired: true,
                  validator: validator,
                  enabled: state.isEdit,
                ),
                _TextField(
                  header: 'Bairro',
                  controller: state.neighborhoodController,
                  isRequired: true,
                  validator: validator,
                  enabled: state.isEdit,
                ),
                _TextField(
                  header: 'Logadradouro',
                  controller: state.roadController,
                  isRequired: true,
                  validator: validator,
                  enabled: state.isEdit,
                ),
                _TextField(
                  header: 'Numero',
                  controller: state.numberController,
                  isRequired: true,
                  validator: validator,
                  enabled: state.isEdit,
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
    final state = Provider.of<_CustomerState>(context, listen: true);
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
              enabled: state.isEdit,
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
    final state = Provider.of<_CustomerState>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            keyboardType: textInputType ?? TextInputType.text,
            enabled: enabled,
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

/// Botão para salvar edição
class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<_CustomerState>(context);

    return GestureDetector(
      onTap: () async {
        var result = await state.saveForm(context);

        if (result == true) {
          if (context.mounted) {
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

class _ButtonEdit extends StatelessWidget {
  const _ButtonEdit({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<_CustomerState>(context);
    return GestureDetector(
      onTap: () {
        state.isEdit = true;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 40,
          width: 60,
          child: Icon(
            size: 28,
            Icons.edit,
          ),
        ),
      ),
    );
  }
}

class _ButtonDelete extends StatelessWidget {
  const _ButtonDelete({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<_CustomerState>(context);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialogUtil(
                title: "Atenção",
                content: "Você irá excluir o cliente permanentemente",
                labelButtonPrimary: 'Confirmar',
                onPressedPrimary: () async {
                  final result = true;

                  if (result) {
                    Fluttertoast.showToast(
                      msg: "Deletado com sucesso!",
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context, 'update');
                    }
                  } else {
                    Fluttertoast.showToast(
                      msg: "Ocorreu um erro ao deletar!",
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                });
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 40,
          width: 60,
          child: Icon(
            size: 28,
            Icons.delete,
          ),
        ),
      ),
    );
  }
}