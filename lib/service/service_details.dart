import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/service/entities/service.dart';
import 'package:workshop_front_end/service/service_form.dart';
import '../customer/view.dart';
import 'package:intl/intl.dart';

import '../domain/use_case_service.dart';
import '../repository/repository_service.dart';

class ServiceDetailsState with ChangeNotifier {
  ServiceDetailsState({this.serviceDetails, required this.context}) {
    _init(serviceDetails!);
  }

  bool _loading =  true;
  ServiceDetails? serviceDetails;
  final BuildContext context;

  Future<void> _init(ServiceDetails serviceDetailsInitialize) async {

    final repository = RepositoryService();
    final useCaseService = UseCaseService(repository);
    var result = await useCaseService.getImageServiceById(serviceDetailsInitialize.serviceId);


    serviceDetails = serviceDetailsInitialize;

    if (result != null) {
      serviceDetails = serviceDetails!.copyWith(
        imageBytes: result['image'],
        exitImageBytes: result['exit_image'],
      );
    }
    _loading = false;
    notifyListeners();
  }
}

/// Informações do serviço quando é finalizado
class ServiceDetail extends StatelessWidget {
  const ServiceDetail({super.key, required this.serviceDetails});

  final ServiceDetails serviceDetails;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ServiceDetailsState>(
      create: (_) =>
          ServiceDetailsState(context: context, serviceDetails: serviceDetails),
      child: Consumer<ServiceDetailsState>(
        builder: (context, state, _) {
          return ChangeNotifierProvider<ServiceState>(
            create: (_) =>
                ServiceState(isDetails: true, serviceDetails: serviceDetails),
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                title: Text("Detalhes do serviço #${serviceDetails.serviceId}"),
                backgroundColor: Colors.blue.shade700,
              ),
              body: state._loading == true ?    Center(
                child: CircularProgressIndicator(),
          ) :  state.serviceDetails?.status == 0
                  ? RegisterService(
                      isDetails: true,
                      service: state.serviceDetails,
                    )
                  : _Content(),
            ),
          );
        },
      ),
    );
  }
}

/// Informações do serviço quando é finalizado
class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceDetailsState>(
      builder: (context, state, __) {
        final details = state.serviceDetails!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ButtonPdf(details),
              SizedBox(
                height: 20,
              ),
              const Text(
                'Dados do Cliente',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nome',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            '${details.customerName} ${details.customerSurname}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Documento',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.document),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.email),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Whatsapp',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.whatsapp),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Observação',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.customerObservation),
                      ],
                    ),
                  ),
                  Spacer()
                ],
              ),
              const SizedBox(height: 45),
              const Text(
                'Dados do Veículo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Modelo',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.vehicleModel),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cor',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.vehicleColor),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Placa',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.vehiclePlate),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ano',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.manufactureYear.toString()),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tipo de Veículo',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.vehicleType),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 45),
              const Text(
                'Dados do Mecânico',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nome',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.userName),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('E-mail',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(details.userEmail),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 45),
              const Text(
                'Itens de compra do serviço',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Column(
                  children: details.purchaseItems.map(
                (item) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Peça',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(item.part ?? ''),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Marca',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(item.brand ?? ''),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Valor unitário',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(item.unitPrice.toString()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Quantidade',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(item.quantity.toString()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Valor total',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(item.totalPrice.toString()),
                              ],
                            ),
                          ),
                          Spacer()
                        ],
                      ),
                      if (details.purchaseItems.last != item)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            color: Color.fromRGBO(207, 196, 255, 1.0),
                          ),
                        ),
                    ],
                  );
                },
              ).toList()),
              const SizedBox(height: 45),
              const Text(
                'Observação do serviço',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Column(
                  children: details.observations.map(
                (item) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Observação',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(item.description.toString()),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Data',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(item.date != null
                                    ? DateFormat('dd/MM/yyyy – HH:mm')
                                        .format(item.date!)
                                    : 'Sem data'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (details.observations.last != item)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            color: Color.fromRGBO(207, 196, 255, 1.0),
                          ),
                        ),
                    ],
                  );
                },
              ).toList()),
            ],
          ),
        );
      },
    );
  }
}
