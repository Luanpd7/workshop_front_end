import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import 'package:provider/provider.dart';

import '../providers/service_provider.dart';
import '../providers/client_provider.dart';
import '../providers/mechanic_provider.dart';
import '../providers/vehicle_provider.dart';

import '../models/service.dart';
import '../models/client.dart';
import '../models/mechanic.dart';
import '../models/vehicle.dart';

/// Tela de criação de um novo serviço.
/// Permite selecionar cliente, veículo, mecânico e fotos do veículo.
class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  /// FormKey para validação
  final _formKey = GlobalKey<FormState>();

  /// ImagePicker para capturar fotos
  final ImagePicker _imagePicker = ImagePicker();

  /// Campos selecionados pelos ComboBox
  Client? _selectedClient;
  Vehicle? _selectedVehicle;
  Mechanic? _selectedMechanic;

  /// Veículos pertencentes ao cliente selecionado
  List<Vehicle> _clientVehicles = [];

  /// Imagens tiradas antes do serviço
  List<String> _beforeImages = [];


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
      context.read<MechanicProvider>().loadMechanics();
    });
  }


  void _onClientChanged(Client? client) {
    setState(() {
      _selectedClient = client;
      _selectedVehicle = null;
      _clientVehicles = [];
    });

    if (client != null) {
      context.read<VehicleProvider>().loadVehicles(clientId: client.id).then((_) {
        setState(() {
          _clientVehicles = context.read<VehicleProvider>()
              .vehicles
              .where((v) => v.clientId == client.id)
              .toList();
        });
      });
    }
  }


  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
  }


  Future<void> _pickBeforeImage() async {
    await _requestPermissions();

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _beforeImages.add(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeBeforeImage(int index) {
    setState(() => _beforeImages.removeAt(index));
  }


  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClient == null ||
        _selectedVehicle == null ||
        _selectedMechanic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione cliente, mecânico e veículo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newService = Service(
      clientId: _selectedClient!.id!,
      vehicleId: _selectedVehicle!.id!,
      mechanicId: _selectedMechanic!.id!,
      mechanicName: _selectedMechanic!.name,
      startDate: DateTime.now(),
      status: ServiceStatus.inProgress,
      beforeImages: _beforeImages,
    );

    await context.read<ServiceProvider>().createService(newService);

    if (context.mounted) {
      Navigator.pop(context);
      context.read<ServiceProvider>().loadServices();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Serviço'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<ServiceProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return TextButton(
                onPressed: _saveService,
                child: const Text('Salvar'),
              );
            },
          ),
        ],
      ),


      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [


              Consumer<ClientProvider>(
                builder: (_, provider, __) {
                  return DropdownButtonFormField<Client>(
                    value: _selectedClient,
                    decoration: const InputDecoration(
                      labelText: 'Cliente *',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    items: provider.clients.map((client) {
                      return DropdownMenuItem(
                        value: client,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: _onClientChanged,
                    validator: (val) => val == null ? 'Cliente é obrigatório' : null,
                  );
                },
              ),
              const SizedBox(height: 16),


              if (_selectedClient != null)
                Consumer<VehicleProvider>(
                  builder: (_, vp, __) {
                    if (vp.isLoading && _clientVehicles.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (_clientVehicles.isEmpty) {
                      return _buildWarningCard(
                        'Este cliente não possui veículos cadastrados',
                      );
                    }

                    return DropdownButtonFormField<Vehicle>(
                      value: _selectedVehicle,
                      decoration: const InputDecoration(
                        labelText: 'Veículo *',
                        prefixIcon: Icon(Icons.directions_car),
                        border: OutlineInputBorder(),
                      ),
                      items: _clientVehicles.map((v) {
                        return DropdownMenuItem(
                          value: v,
                          child: Text(v.displayName),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedVehicle = v),
                      validator: (v) => v == null ? 'Veículo é obrigatório' : null,
                    );
                  },
                ),
              if (_selectedClient != null) const SizedBox(height: 16),


              Consumer<MechanicProvider>(
                builder: (_, provider, __) {
                  return DropdownButtonFormField<Mechanic>(
                    value: _selectedMechanic,
                    decoration: const InputDecoration(
                      labelText: 'Mecânico *',
                      prefixIcon: Icon(Icons.build),
                      border: OutlineInputBorder(),
                    ),
                    items: provider.mechanics.map((m) {
                      return DropdownMenuItem(value: m, child: Text(m.name));
                    }).toList(),
                    onChanged: (m) => setState(() => _selectedMechanic = m),
                    validator: (m) => m == null ? 'Mecânico é obrigatório' : null,
                  );
                },
              ),
              const SizedBox(height: 24),


              _buildBeforeImagesCard(),

              const SizedBox(height: 24),


              _buildInfoCard(),

              const SizedBox(height: 24),


              ElevatedButton.icon(
                onPressed: _saveService,
                icon: const Icon(Icons.save),
                label: const Text('Criar Serviço'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),


              Consumer<ServiceProvider>(
                builder: (_, provider, __) {
                  if (provider.error == null) return const SizedBox.shrink();
                  return _buildErrorCard(provider.error!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildWarningCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeImagesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt,
                    color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Fotos do Veículo (Antes)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Tire fotos do estado atual do veículo',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _pickBeforeImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Tirar Foto'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            if (_beforeImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_beforeImages.length, (index) {
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_beforeImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeBeforeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'O serviço será criado com status "Em Andamento"',
              style: TextStyle(color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }
}
