import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../customer/view.dart';
import '../repository/repository_service.dart';
import 'entities/service'
    '.dart';
import 'entities/vehicle.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


/// Tela responsável pelo formulario de serviço,
/// usado na tela segunda tab quando vou cadastrar
/// um serviço e na quando vou editar um serviço

class RegisterService extends StatelessWidget {
  const RegisterService({super.key, this.service, this.isDetails = false});

  final ServiceDetails? service;

  final bool isDetails;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Consumer<ServiceState>(
            builder: (context, state, Widget? _) {
              if (state.loading) {
                return Center(child: CircularProgressIndicator());
              }
              return Form(
                child: Column(
                  children: [
                    if (state.isDetails) ...[
                      FinalizeButton(
                        serviceId: service?.serviceId ?? 0,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _ButtonEdit(),
                    ] else
                      if(state.isEdit)_ButtonSaveEdit(service!.serviceId)
                      else _ButtonSave(),
                    _InfoCardService(),
                    _InfoPurchase(),
                    _InfoCardObservation(),
                    if (!state.isDetails)
                      _InfoPhoto(
                        onUploadPressed: () => state.selectPhoto(context),
                      ),
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

/// card para a informações do serviço
class _InfoCardService extends StatelessWidget {
  const _InfoCardService();

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
                if (state.isDetails) ...[
                  _TextField(
                    header: 'Veículo',
                    isRequired: true,
                    controller: TextEditingController(
                        text: state.selectedVehicle?.name ?? ''),
                    maxLength: 25,
                    enabled: false,
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: DropdownButtonFormField(
                      value: state.selectedVehicle,
                      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
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
                      items: state.isDetails == true
                          ? []
                          : state.vehicles.map(
                              (vehicle) {
                                return DropdownMenuItem<VehicleType>(
                                  value: vehicle,
                                  child: Text(vehicle.name),
                                );
                              },
                            ).toList(),
                      onChanged: (selected) {
                        state.selectVehicle = selected as VehicleType;
                      },
                    ),
                  ),
                _TextField(
                  header: 'Modelo',
                  isRequired: true,
                  controller: state.brandController,
                  maxLength: 25,
                  enabled: !state.isDetails,
                ),
                _TextField(
                  textInputType: TextInputType.number,
                  header: 'Ano de fabricação',
                  controller: state.yearFabricationController,
                  validator: validator,
                  enabled: !state.isDetails,
                ),
                _TextField(
                  header: 'Cor',
                  controller: state.colorController,
                  validator: validator,
                  enabled: !state.isDetails,
                ),
                _TextField(
                  header: 'Placa',
                  controller: state.plateController,
                  maxLength: 10,
                  enabled: !state.isDetails,
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

        // 1º caso: imagem nova do dispositivo
        if (state.imageFile != null)
          _buildImageWidget(
            context,
            Image.file(state.imageFile!, height: 200, fit: BoxFit.cover),
            onDelete: () => state.imageFile = null,
          )

        // 2º caso: imagem já salva no banco
        else if (state.imageBytes != null)
          _buildImageWidget(
            context,
            Image.memory(state.imageBytes!, height: 200, fit: BoxFit.cover),
            onDelete: () => state.imageBytes = null,
          )

        // 3º caso: nenhuma imagem
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
                    WidgetStatePropertyAll(Colors.blue.shade700),
                  ),
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

  Widget _buildImageWidget(BuildContext context, Widget imageWidget, {VoidCallback? onDelete}) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: imageWidget,
          ),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.delete,
                color: Colors.redAccent,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}



/// Util para campo de texto
class _TextField extends StatelessWidget {
  const _TextField({
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
          final result = await state.saveForm(context);
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

  _ButtonSaveEdit(this.serviceId);
  final int serviceId;
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ServiceState>(context);

    return GestureDetector(
      onTap: () async {
        final updates = {
        'model' : 'Cruze',
        };

        final repo = RepositoryService();

        final success = await repo.updateService(serviceId, updates);
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

class ButtonPdf extends StatelessWidget {
  ButtonPdf(this.serviceDetails);
  final ServiceDetails serviceDetails;

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Detalhes do Serviço  #${serviceDetails.serviceId}",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text("Dados do cliente",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),


              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Nome: ${serviceDetails.customerName}"),
                  pw.Text("Documento: ${serviceDetails.document}"),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("E-mail: ${serviceDetails.email}"),
                  pw.Text("Whatsapp: ${serviceDetails.whatsapp}"),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Text("Observação: ${serviceDetails.customerObservation}"),
              pw.SizedBox(height: 16),

              pw.Text("Dados do veículo",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),


              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Modelo: ${serviceDetails.vehicleModel}"),
                  pw.Text("Cor: ${serviceDetails.vehicleColor}"),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Placa: ${serviceDetails.vehiclePlate}"),
                  pw.Text("Ano: ${serviceDetails.manufactureYear}"),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Text("Tipo de veículo: ${serviceDetails.vehicleType}"),
              pw.SizedBox(height: 16),


              pw.Text("Dados do mecânico",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Nome: ${serviceDetails.userName}"),
                  pw.Text("E-mail: ${serviceDetails.userEmail}"),
                ],
              ),
              pw.SizedBox(height: 16),

              pw.Text("Dados do serviço",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Data de entrada: ${DateFormat('dd/MM/yyyy').format(serviceDetails.entryDate)}"),
                  pw.Text("Data de saída: ${DateFormat('dd/MM/yyyy').format(serviceDetails.exitDate!)}"),
                ],
              ),

              if (serviceDetails.purchaseItems.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  "Itens da Compra",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  cellAlignment: pw.Alignment.centerLeft,
                  headers: ['Peça', 'Marca', 'Quantidade', 'Preço Unit.', 'Total'],
                  data: serviceDetails.purchaseItems.map((item) {
                    final precoUnit = item.unitPrice?.toStringAsFixed(2);
                    final total = (item.unitPrice! * item.quantity!.toDouble()).toStringAsFixed(2);
                    return [
                      item.part,
                      item.brand,
                      item.quantity.toString(),
                      "R\$ $precoUnit",
                      "R\$ $total",
                    ];
                  }).toList(),
                ),
                pw.SizedBox(height: 16),
              ],
              if (serviceDetails.observations.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  "Observações do serviço",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  cellAlignment: pw.Alignment.centerLeft,
                  headers: ['Descrição', 'Data'],
                  data: serviceDetails.observations.map((item) {
                    return [
                      item.description,
                      DateFormat('dd/MM/yyyy  HH:mm')
                          .format(item.date!)

                    ];
                  }).toList(),
                ),
                pw.SizedBox(height: 16),
              ],




              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Valor final:  R\$ ${serviceDetails.sumValue?.toStringAsFixed(2)}"),
                ],
              ),
              pw.SizedBox(height: 16),
            ],
          );
        },
      ),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (serviceDetails.imageBytes != null && serviceDetails.imageBytes!.isNotEmpty) ...[
                pw.Text("Antes", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Image(
                  pw.MemoryImage(serviceDetails.imageBytes!),
                  width: 400,
                  height: 300,
                  fit: pw.BoxFit.cover,
                ),
                pw.SizedBox(height: 20),
              ],
              if (serviceDetails.exitImageBytes != null && serviceDetails.exitImageBytes!.isNotEmpty) ...[
                pw.Text("Depois", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Image(
                  pw.MemoryImage(serviceDetails.exitImageBytes!),
                  width: 400,
                  height: 300,
                  fit: pw.BoxFit.cover,
                ),
              ],
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () async {
        await _generatePdf(context);
      },
      child: SizedBox(
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade700, width: 1),
          ),
          child: const Center(
            child: Text(
              'Gerar PDF',
              style: TextStyle(color: Colors.white),
            ),
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
                        textInputType: TextInputType.number,
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
                  brand: state.markController.text,
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
              var observations = Observation(
                description: state.observationServiceController.text,
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

class FinalizeButton extends StatelessWidget {
  final int serviceId;

  const FinalizeButton({super.key, required this.serviceId});

  Future<Uint8List?> _chooseImageSource(BuildContext context) async {
    final picker = ImagePicker();

    return showModalBottomSheet<Uint8List?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Usar câmera'),
              onTap: () async {
                final picked =
                    await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(
                    ctx, picked != null ? await picked.readAsBytes() : null);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () async {
                final picked =
                    await picker.pickImage(source: ImageSource.gallery);
    if(context.mounted) {
      Navigator.pop(
          ctx, picked != null ? await picked.readAsBytes() : null,);
    }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ServiceState>(); // Aqui você pega o state

    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: const Text('Finalizar serviço'),
              content: const Text('Deseja finalizar este serviço?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blueAccent)),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );

        if (confirm != true) return;


        final imageBytes = await _chooseImageSource(context);
        if (imageBytes == null) {
          if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nenhuma imagem selecionada.',),
                backgroundColor: Colors.red,),
            );
          }
          state.loading = false;
          return;
        }

        var sumValue = 0.0;

        for (var e in state.purchasePart) {
          sumValue += e.totalPrice!.toDouble() ;
        }

        final updates = {
          'exitImageBytes': imageBytes,
          'exitDate': DateTime.now(),
          'status': 1,
          'sumValue' :sumValue,
        };

        final repo = RepositoryService();

        final success = await repo.updateService(serviceId, updates);
        state.loading = false;

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Serviço finalizado com sucesso.'), backgroundColor: Colors.green),
          );

         context.pop();

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao finalizar o serviço.'), backgroundColor: Colors.red),
          );
        }
      },
      child: SizedBox(
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade700, width: 1),
          ),
          child: const Center(
            child: Text('Finalizar', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
