import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../models/client.dart';
import '../models/mechanic.dart';
import '../models/vehicle.dart';
import '../providers/client_provider.dart';
import '../providers/mechanic_provider.dart';
import '../providers/vehicle_provider.dart';
import '../services/pdf_service.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Service service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Serviço #${service.id}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (service.status == ServiceStatus.finished)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _generatePdf(context),
              tooltip: 'Gerar Comprovante PDF',
            ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadRelatedData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar dados',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status do Serviço
                _buildStatusCard(context),
                const SizedBox(height: 16),

                // Informações do Cliente
                _buildClientCard(context),
                const SizedBox(height: 16),

                // Informações do Mecânico
                _buildMechanicCard(context),
                const SizedBox(height: 16),

                // Informações do Serviço
                _buildServiceInfoCard(context),
                const SizedBox(height: 16),

                // Fotos Antes e Depois
                if (service.beforeImages.isNotEmpty || service.afterImages.isNotEmpty)
                  _buildPhotosCard(context),
                const SizedBox(height: 16),

                // Peças e Custos
                if (service.parts.isNotEmpty || service.laborCost > 0)
                  _buildCostsCard(context),
                const SizedBox(height: 16),

                // Botão para gerar PDF
                if (service.status == ServiceStatus.finished)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _generatePdf(context),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Gerar Comprovante PDF'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _generatePdf(BuildContext context) {
    final clientProvider = context.read<ClientProvider>();
    final vehicleProvider = context.read<VehicleProvider>();
    
    try {
      final client = clientProvider.clients
          .firstWhere((c) => c.id == service.clientId);
      final vehicle = vehicleProvider.vehicles
          .firstWhere((v) => v.id == service.vehicleId);

      PdfService.generateServiceReceipt(
        service: service,
        client: client,
        vehicle: vehicle,
      ).catchError((e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao gerar PDF: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPhotosCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Fotos do Veículo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            if (service.beforeImages.isNotEmpty) ...[
              Text(
                'ANTES',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: service.beforeImages.length,
                  itemBuilder: (context, index) {
                    final imagePath = service.beforeImages[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imagePath.startsWith('http') || imagePath.startsWith('https')
                            ? Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              )
                            : Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (service.afterImages.isNotEmpty) ...[
              Text(
                'DEPOIS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: service.afterImages.length,
                  itemBuilder: (context, index) {
                    final imagePath = service.afterImages[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imagePath.startsWith('http') || imagePath.startsWith('https')
                            ? Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              )
                            : Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCostsCard(BuildContext context) {
    final partsTotal = service.partsTotal;
    final laborCost = service.laborCost;
    final totalCost = service.serviceTotal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Custos e Peças',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            if (service.parts.isNotEmpty) ...[
              Text(
                'Peças Utilizadas:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...service.parts.map((part) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('${part.name} (${part.quantity}x)'),
                        ),
                        Text('R\$ ${part.total.toStringAsFixed(2)}'),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
              _InfoRow(label: 'Total de Peças', value: 'R\$ ${partsTotal.toStringAsFixed(2)}'),
            ],
            if (laborCost > 0) ...[
              const SizedBox(height: 8),
              _InfoRow(label: 'Horas Trabalhadas', value: '${service.laborHours.toStringAsFixed(2)}h'),
              _InfoRow(label: 'Custo de Mão de Obra', value: 'R\$ ${laborCost.toStringAsFixed(2)}'),
            ],
            if (totalCost > 0) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL GERAL',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'R\$ ${totalCost.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _loadRelatedData(BuildContext context) async {
    await context.read<ClientProvider>().loadClients();
    await context.read<MechanicProvider>().loadMechanics();
    await context.read<VehicleProvider>().loadVehicles();
  }

  Widget _buildStatusCard(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (service.status) {
      case ServiceStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case ServiceStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.build;
        break;
      case ServiceStatus.finished:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case ServiceStatus.washing:
        statusColor = Colors.cyan;
        statusIcon = Icons.local_car_wash;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: statusColor,
              radius: 24,
              child: Icon(statusIcon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.statusDisplay,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context) {
    final client = context.read<ClientProvider>().clients
        .firstWhere((c) => c.id == service.clientId, orElse: () => Client(
          id: service.clientId,
          name: 'Cliente não encontrado',
          phone: '',
          registrationDate: DateTime.now(),
        ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Cliente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _InfoRow(label: 'Nome', value: client.name),
            const SizedBox(height: 8),
            _InfoRow(label: 'Telefone', value: client.phone),
            if (client.email != null && client.email!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoRow(label: 'Email', value: client.email!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMechanicCard(BuildContext context) {
    final mechanic = context.read<MechanicProvider>().mechanics
        .firstWhere((m) => m.id == service.mechanicId, orElse: () => Mechanic(
          id: service.mechanicId,
          name: service.mechanicName,
          phone: '',
          registrationDate: DateTime.now(),
        ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Mecânico',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _InfoRow(label: 'Nome', value: mechanic.name),
            const SizedBox(height: 8),
            _InfoRow(label: 'Telefone', value: mechanic.phone),
            if (mechanic.email != null && mechanic.email!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoRow(label: 'Email', value: mechanic.email!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard(BuildContext context) {
    final vehicle = context.read<VehicleProvider>().vehicles
        .firstWhere((v) => v.id == service.vehicleId, orElse: () => Vehicle(
          id: service.vehicleId,
          clientId: service.clientId,
          brand: 'Veículo',
          model: 'não encontrado',
          year: 0,
        ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  'Informações do Serviço',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _InfoRow(label: 'Veículo', value: vehicle.displayName),
            if (vehicle.plate != null) ...[
              const SizedBox(height: 8),
              _InfoRow(label: 'Placa', value: vehicle.plate!),
            ],
            if (service.startDate != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Data de Início',
                value: _formatDate(service.startDate!),
              ),
            ],
            if (service.endDate != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Data de Término',
                value: _formatDate(service.endDate!),
              ),
            ],
            if (service.totalCost > 0) ...[
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Valor Total',
                value: 'R\$ ${service.totalCost.toStringAsFixed(2)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

