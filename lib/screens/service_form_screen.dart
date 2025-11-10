import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' hide ServiceStatus;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import '../providers/client_provider.dart';
import '../providers/mechanic_provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/service.dart';
import '../models/client.dart';
import '../models/mechanic.dart';
import '../models/vehicle.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  
  Client? _selectedClient;
  Vehicle? _selectedVehicle;
  Mechanic? _selectedMechanic;
  List<Vehicle> _clientVehicles = [];
  List<String> _beforeImages = [];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
      context.read<MechanicProvider>().loadMechanics();
    });
  }

  @override
  void dispose() {
    super.dispose();
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
          _clientVehicles = context.read<VehicleProvider>().vehicles
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
        setState(() {
          _beforeImages.add(image.path);
        });
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
    setState(() {
      _beforeImages.removeAt(index);
    });
  }









  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _saveService() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClient == null || _selectedMechanic == null || _selectedVehicle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione cliente, mecânico e veículo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }



      final service = Service(
        clientId: _selectedClient!.id!,
        vehicleId: _selectedVehicle!.id!,
        mechanicId: _selectedMechanic!.id!,
        mechanicName: _selectedMechanic!.name,
        startDate: DateTime.now(),
        status: ServiceStatus.inProgress,
        beforeImages: _beforeImages,
      );

      await context.read<ServiceProvider>().createService(service);
      
      if (context.mounted) {
        Navigator.pop(context);
        // Recarregar a lista de serviços
        context.read<ServiceProvider>().loadServices();
      }
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
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seleção de Cliente
              Consumer<ClientProvider>(
                builder: (context, clientProvider, child) {
                  return DropdownButtonFormField<Client?>(
                    value: _selectedClient,
                    decoration: const InputDecoration(
                      labelText: 'Cliente *',
                      hintText: 'Selecione um cliente',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    items: clientProvider.clients.map((client) {
                      return DropdownMenuItem<Client>(
                        value: client,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: _onClientChanged,
                    validator: (value) {
                      if (value == null) {
                        return 'Cliente é obrigatório';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Seleção de Veículo (após selecionar cliente)
              if (_selectedClient != null)
                Consumer<VehicleProvider>(
                  builder: (context, vehicleProvider, child) {
                    if (vehicleProvider.isLoading && _clientVehicles.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (_clientVehicles.isEmpty) {
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
                                'Este cliente não possui veículos cadastrados',
                                style: TextStyle(color: Colors.orange[800]),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return DropdownButtonFormField<Vehicle>(
                      value: _selectedVehicle,
                      decoration: const InputDecoration(
                        labelText: 'Veículo *',
                        hintText: 'Selecione um veículo',
                        prefixIcon: Icon(Icons.directions_car),
                        border: OutlineInputBorder(),
                      ),
                      items: _clientVehicles.map((vehicle) {
                        return DropdownMenuItem<Vehicle>(
                          value: vehicle,
                          child: Text(vehicle.displayName),
                        );
                      }).toList(),
                      onChanged: (vehicle) {
                        setState(() {
                          _selectedVehicle = vehicle;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veículo é obrigatório';
                        }
                        return null;
                      },
                    );
                  },
                ),
              if (_selectedClient != null) const SizedBox(height: 16),

              // Seleção de Mecânico
              Consumer<MechanicProvider>(
                builder: (context, mechanicProvider, child) {
                  return DropdownButtonFormField<Mechanic>(
                    value: _selectedMechanic,
                    decoration: const InputDecoration(
                      labelText: 'Mecânico *',
                      hintText: 'Selecione um mecânico',
                      prefixIcon: Icon(Icons.build),
                      border: OutlineInputBorder(),
                    ),
                    items: mechanicProvider.mechanics.map((mechanic) {
                      return DropdownMenuItem<Mechanic>(
                        value: mechanic,
                        child: Text(mechanic.name),
                      );
                    }).toList(),
                    onChanged: (mechanic) {
                      setState(() {
                        _selectedMechanic = mechanic;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Mecânico é obrigatório';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),


              // Fotos Antes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'Fotos do Veículo (Antes)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tire fotos do estado atual do veículo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
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
                            final imagePath = _beforeImages[index];
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
                                      File(imagePath),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                      onPressed: () => _removeBeforeImage(index),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
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
              ),
              const SizedBox(height: 24),

              // Informação sobre o status
              Container(
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
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveService,
                  icon: const Icon(Icons.save),
                  label: const Text('Criar Serviço'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              // Mostrar erro se houver
              Consumer<ServiceProvider>(
                builder: (context, provider, child) {
                  if (provider.error != null) {
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
                              provider.error!,
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
