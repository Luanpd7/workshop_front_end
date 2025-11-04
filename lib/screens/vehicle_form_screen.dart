import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/client_provider.dart';
import '../models/vehicle.dart';
import '../models/client.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;
  final Client? client;

  const VehicleFormScreen({super.key, this.vehicle, this.client});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();

  Client? _selectedClient;
  bool get isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    print('--------------- ${widget.client}');
    _selectedClient = widget.client;
    
    if (isEditing) {
      _brandController.text = widget.vehicle!.brand;
      _modelController.text = widget.vehicle!.model;
      _yearController.text = widget.vehicle!.year.toString();
      _colorController.text = widget.vehicle!.color ?? '';
      _plateController.text = widget.vehicle!.plate ?? '';
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    print('------------------------- 0');
    if (_formKey.currentState!.validate() && _selectedClient != null) {
      print('------------------------- 1');
      final vehicle = Vehicle(
        id: widget.vehicle?.id,
        clientId: _selectedClient!.id!,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        color: _colorController.text.trim().isEmpty 
            ? null 
            : _colorController.text.trim(),
        plate: _plateController.text.trim().isEmpty 
            ? null 
            : _plateController.text.trim(),
      );

      if (isEditing) {
        print('------------------------- 2');
        context.read<VehicleProvider>().updateVehicle(vehicle);
      } else {
        context.read<VehicleProvider>().createVehicle(vehicle);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Veículo' : 'Novo Veículo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<VehicleProvider>(
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
                onPressed: _saveVehicle,
                child: const Text('Salvar'),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Seleção de Cliente
              if (!isEditing) ...[
                Consumer<ClientProvider>(
                  builder: (context, clientProvider, child) {
                    return DropdownButtonFormField<Client>(
                      value: _selectedClient,
                      decoration: const InputDecoration(
                        labelText: 'Cliente *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      items: clientProvider.clients.map((client) {
                        return DropdownMenuItem<Client>(
                          value: client,
                          child: Text(client.name),
                        );
                      }).toList(),
                      onChanged: (client) {
                        setState(() {
                          _selectedClient = client;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione um cliente';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Campo Marca
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marca *',
                  hintText: 'Ex: Toyota, Ford, Honda',
                  prefixIcon: Icon(Icons.branding_watermark),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Marca é obrigatória';
                  }
                  if (value.trim().length < 2) {
                    return 'Marca deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Campo Modelo
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Modelo *',
                  hintText: 'Ex: Corolla, Focus, Civic',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Modelo é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'Modelo deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Campo Ano
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Ano *',
                  hintText: 'Ex: 2020',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ano é obrigatório';
                  }
                  final year = int.tryParse(value.trim());
                  if (year == null) {
                    return 'Ano deve ser um número válido';
                  }
                  final currentYear = DateTime.now().year;
                  if (year < 1900 || year > currentYear + 1) {
                    return 'Ano deve estar entre 1900 e ${currentYear + 1}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Cor
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Cor (opcional)',
                  hintText: 'Ex: Branco, Preto, Prata',
                  prefixIcon: Icon(Icons.palette),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Campo Placa
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Placa (opcional)',
                  hintText: 'Ex: ABC-1234',
                  prefixIcon: Icon(Icons.confirmation_number),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final plate = value.trim().toUpperCase();
                    if (plate.length < 7 || plate.length > 8) {
                      return 'Placa deve ter 7 ou 8 caracteres';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveVehicle,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Atualizar Veículo' : 'Criar Veículo'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              // Mostrar erro se houver
              Consumer<VehicleProvider>(
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
