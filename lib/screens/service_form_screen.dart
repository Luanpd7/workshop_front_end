import 'package:flutter/material.dart';
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
  Client? _selectedClient;
  Vehicle? _selectedVehicle;
  Mechanic? _selectedMechanic;
  List<Vehicle> _clientVehicles = [];

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
          _clientVehicles = context.read<VehicleProvider>().vehicles
              .where((v) => v.clientId == client.id)
              .toList();
        });
      });
    }
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
