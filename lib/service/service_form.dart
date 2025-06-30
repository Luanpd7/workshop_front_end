import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/util/mask.dart';
import '../customer/view.dart';
import 'entities/service'
    '.dart';
import 'package:intl/intl.dart';

class RegisterService extends StatelessWidget {
  const RegisterService({this.service, this.isDetails = false});

  final Service? service;

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
                    _ButtonSave(),
                    _InfoCardService(),
                    _InfoPurchase(),
                    _InfoCardObservation(),
                    _InfoPhoto(
                      onUploadPressed: () => state.selectPhoto(context),
                    )
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

class _InfoCardService extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = Provider.of<ServiceState>(context, listen: true);
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
                    decoration: InputDecoration(
                      label: Text(
                        'Veículo',
                        style: theme.textTheme.labelSmall!
                            .copyWith(color: theme.disabledColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blue.shade700, width: 1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: [],
                    onChanged: (value) {},
                  ),
                ),
                _TextField(
                  header: 'Modelo',
                  isRequired: true,
                  controller: state.surnameController,
                  maxLength: 25,
                ),
                _TextField(
                  header: 'Ano de fabricação',
                  controller: state.documentController,
                  isRequired: true,
                  validator: validator,
                ),
                _TextField(
                  header: 'Cor',
                  controller: state.whatsappController,
                  isRequired: true,
                  validator: validator,
                  mask: phoneMask,
                ),
                _TextField(
                  header: 'Placa',
                  controller: state.emailController,
                  maxLength: 25,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _InfoPurchase extends StatelessWidget {
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
                          mark: item.mark ?? '',
                          part: item.part ?? '',
                          quantity: item.quantity.toString(),
                          priceTotal: item.priceTotal?.toStringAsFixed(2) ?? '0.00',
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
                            observation: item.observation ?? '',
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
  final VoidCallback onUploadPressed;

  const _InfoPhoto({required this.onUploadPressed});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context, listen: true);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Text(
            'Foto do veículo atualmente',
            style: theme.textTheme.titleLarge,
          ),
        ),
        if (state.imageFile != null)
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Image.file(
                    state.imageFile!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                GestureDetector(
                  onTap: () => state.imageFile = null,
                  child: Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 30,
                  ),
                )
              ],
            ),
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
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.blue.shade700)),
                  onPressed: onUploadPressed,
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

class _TextField extends StatelessWidget {
  const _TextField({
    required this.header,
    required this.controller,
    this.isRequired = false,
    this.bigField = false,
    this.validator,
    this.maxLength = 50,
    this.mask,
  });

  final String header;
  final bool? isRequired;
  final bool? bigField;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final int maxLength;
  final TextInputFormatter? mask;

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

class _ButtonSave extends StatelessWidget {
  const _ButtonSave();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context);

    return GestureDetector(
      onTap: () async {
        if (state.formKey.currentState!.validate()) {
          final result = await state.saveForm();
          if (result == true) {
            state.clearForm();
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
                _TextField(
                  header: 'Peça',
                  isRequired: true,
                  controller: state.partController,
                  maxLength: 15,
                ),
                _TextField(
                  header: 'Marca',
                  isRequired: true,
                  controller: state.markController,
                  maxLength: 25,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _TextField(
                        header: 'Preço uni.',
                        isRequired: true,
                        controller: state.priceUnitaryController,
                        maxLength: 10,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: _TextField(
                        header: 'Qtd.',
                        isRequired: true,
                        controller: state.quantityPartController,
                        maxLength: 10,
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
                var purchasePart = Service(
                  part: state.partController.text,
                  quantity: quantity,
                  priceTotal: priceTotal,
                  mark: state.markController.text,
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
                child: _TextField(
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
              var observations = Service(
                observation: state.observationServiceController.text,
                date: DateTime.now(),
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
                  width: 145,
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
                  width: 145,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Preço total: ', style: TextStyle(fontSize: 15)),
                      Text('R\$ $priceTotal',
                          style: TextStyle(color: theme.disabledColor),
                          overflow: TextOverflow.ellipsis),
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
