import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/customer/entities/address.dart';
import 'package:workshop_front_end/domain/use_case_customer.dart';
import 'package:workshop_front_end/repository/repository_customer.dart';
import 'entities/customer.dart';

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

  Future<void> _init({Customer? customer}) async{
    if(customer != null){
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
  }

  Future<void> saveForm(Customer customer) async {
    final repository = RepositoryCustomer();
    final useCaseCustomer = UseCaseCustomer(repository);

    await useCaseCustomer.addCustomer(customer);

  }

  Future<bool> onPressedDeleteCustomer({required int id})async{
    final repository = RepositoryCustomer();
    final useCaseCustomer = UseCaseCustomer(repository);

   final result =  await useCaseCustomer.deleteCustomer(id);

    return result;
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
  const RegisterCustomer({this.customer});

  final Customer? customer;
  @override
  Widget build(BuildContext context) {
     Provider.of<CustomerState>(context)._init(customer: customer);
    return  Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Consumer<CustomerState>(
              builder: (context, state, Widget? _) {
                return Form(
                  key: state._formKey,
                  child: Column(
                    children: [
                      _InfoCardCustomer(),
                      _InfoCardAddress(),
                      _InfoCardObservation(),
                      _SaveButton(),
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
    final state = Provider.of<CustomerState>(context, listen: false);
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
                ),
                _TextField(
                  header: 'Sobrenome',
                  controller: state.surnameController,
                ),
                _TextField(
                  header: 'Documento',
                  controller: state.documentController,
                  isRequired: true,
                  validator: validator,
                ),
                _TextField(
                  header: 'Whatsapp',
                  controller: state.whatsappController,
                  isRequired: true,
                  validator: validator,
                ),
                _TextField(
                  header: 'Emai-l',
                  controller: state.emailController,
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
    final state = Provider.of<CustomerState>(context, listen: false);
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
                ),
                _TextField(
                  header: 'Cidade',
                  controller: state.cityController,
                  isRequired: true,
                  validator: validator,
                ),
                _TextField(
                  header: 'Bairro',
                  controller: state.neighborhoodController,
                  isRequired: true,
                  validator: validator,
                ),
                _TextField(
                  header: 'Logadradouro',
                  controller: state.roadController,
                  isRequired: true,
                  validator: validator,
                ),
                _TextField(
                  header: 'Numero',
                  controller: state.numberController,
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

class _InfoCardObservation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<CustomerState>(context, listen: false);
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
  });

  final String header;
  final bool? isRequired;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue.shade700, width: 1), borderRadius: BorderRadius.all(Radius.circular(15)) ),
            label:  Row(
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
                    style:
                    theme.textTheme.labelLarge!.copyWith(color: Colors.red),
                  ),
              ],
            ),
          ),
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
    final state = Provider.of<CustomerState>(context, listen: false);
    return ElevatedButton(
      child: Text('Salvar'),
      onPressed: () async {
        if (state._formKey.currentState!.validate()) {
          final customer = Customer(
           name:  state.nameController.text,
           surname:  state.surnameController.text,
           whatsapp:  state.whatsappController.text,
           email:  state.emailController.text,
           document:  state.documentController.text,
          observation:   state.observationController.text,
            address: Address(
              cep: state.cepController.text,
              city: state.cityController.text,
              neighborhood:  state.neighborhoodController.text,
              road:  state.roadController.text,
              number:  state.numberController.text,
            ),
          );


          await state.saveForm( customer);

          state.clearForm();
          Fluttertoast.showToast(
              msg: "Cadastrado com sucesso!",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
            Navigator.pop(context);



        }
      },
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
