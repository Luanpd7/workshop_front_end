import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../models/note.dart';
import '../models/part.dart';
import '../providers/service_provider.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class MechanicServiceEditScreen extends StatefulWidget {
  final Service service;

  const MechanicServiceEditScreen({super.key, required this.service});

  @override
  State<MechanicServiceEditScreen> createState() => _MechanicServiceEditScreenState();
}

class _MechanicServiceEditScreenState extends State<MechanicServiceEditScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final _noteController = TextEditingController();
  final _partCodeController = TextEditingController();
  final _partNameController = TextEditingController();
  final _partBrandController = TextEditingController();
  final _partPriceController = TextEditingController();
  final _partQuantityController = TextEditingController();
  final _laborHoursController = TextEditingController();
  final _laborCostController = TextEditingController();

  // Máscaras para preço (duas casas decimais) e quantidade (inteiro)
  final _currencyMask = MaskTextInputFormatter(
    mask: '##########,##',
    filter: { '#': RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy,
  );

  late Service _service;
  List<Note> _notes = [];
  List<Part> _parts = [];
  List<String> _afterImages = [];
  ServiceStatus? _selectedStatus;
  double _laborHours = 0.0;
  double _laborCost = 0.0;

  bool get _canEdit => _service.status != ServiceStatus.finished;
  bool get _canFinalize => _service.status != ServiceStatus.finished && _afterImages.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _notes = List.from(_service.notes);
    _parts = List.from(_service.parts);
    _afterImages = List.from(_service.afterImages);
    _selectedStatus = _service.status;
    _laborHours = _service.laborHours;
    _laborCost = _service.laborCost;
    _laborHoursController.text = _laborHours.toStringAsFixed(2);
    _laborCostController.text = _laborCost.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _partCodeController.dispose();
    _partNameController.dispose();
    _partBrandController.dispose();
    _partPriceController.dispose();
    _partQuantityController.dispose();
    _laborHoursController.dispose();
    _laborCostController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _afterImages.add(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao capturar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addNote() {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma observação'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _notes.add(Note(
        dateTime: DateTime.now(),
        observation: _noteController.text.trim(),
      ));
      _noteController.clear();
    });
  }

  void _removeNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _addPart() {
    if (_partCodeController.text.trim().isEmpty ||
        _partNameController.text.trim().isEmpty ||
        _partPriceController.text.trim().isEmpty ||
        _partQuantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos da peça'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final price = double.tryParse(_partPriceController.text.replaceAll(',', '.'));
    final quantity = int.tryParse(_partQuantityController.text);

    if (price == null || quantity == null || price <= 0 || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preço e quantidade devem ser números válidos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _parts.add(Part(
        code: _partCodeController.text.trim(),
        name: _partNameController.text.trim(),
        brand: _partBrandController.text.trim().isEmpty ? 'Sem marca' : _partBrandController.text.trim(),
        price: price,
        quantity: quantity,
        total: price * quantity,
      ));

      _partCodeController.clear();
      _partNameController.clear();
      _partBrandController.clear();
      _partPriceController.clear();
      _partQuantityController.clear();
    });
  }

  void _removePart(int index) {
    setState(() {
      _parts.removeAt(index);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _afterImages.removeAt(index);
    });
  }

  Future<void> _saveService() async {
    if (!_canEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serviço já finalizado, não pode ser editado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final partsTotal = _parts.fold(0.0, (sum, part) => sum + part.total);
    final laborHours = double.tryParse(_laborHoursController.text.replaceAll(',', '.')) ?? 0.0;
    final laborCost = double.tryParse(_laborCostController.text.replaceAll(',', '.')) ?? 0.0;
    final totalCost = partsTotal + laborCost;

    final updatedService = _service.copyWith(
      status: _selectedStatus,
      notes: _notes,
      parts: _parts,
      afterImages: _afterImages,
      laborHours: laborHours,
      laborCost: laborCost,
      totalCost: totalCost,
      endDate: _selectedStatus == ServiceStatus.finished ? DateTime.now() : _service.endDate,
    );

    await context.read<ServiceProvider>().updateService(updatedService);
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serviço atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _finalizeService() async {
    if (!_canFinalize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('É necessário tirar uma foto antes de finalizar o serviço'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final partsTotal = _parts.fold(0.0, (sum, part) => sum + part.total);
    final laborHours = double.tryParse(_laborHoursController.text.replaceAll(',', '.')) ?? 0.0;
    final laborCost = double.tryParse(_laborCostController.text.replaceAll(',', '.')) ?? 0.0;
    final totalCost = partsTotal + laborCost;

    final updatedService = _service.copyWith(
      status: ServiceStatus.finished,
      notes: _notes,
      parts: _parts,
      afterImages: _afterImages,
      laborHours: laborHours,
      laborCost: laborCost,
      totalCost: totalCost,
      endDate: DateTime.now(),
    );

    await context.read<ServiceProvider>().updateService(updatedService);
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serviço finalizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final partsTotal = _parts.fold(0.0, (sum, part) => sum + part.total);
    final laborCost = double.tryParse(_laborCostController.text.replaceAll(',', '.')) ?? 0.0;
    final totalCost = partsTotal + laborCost;

    return Scaffold(
      appBar: AppBar(
        title: Text('Serviço #${_service.id}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_canEdit)
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
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveService,
                  tooltip: 'Salvar alterações',
                );
              },
            ),
        ],
      ),
      body: !_canEdit
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Serviço Finalizado',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Este serviço não pode mais ser editado',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status do Serviço',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<ServiceStatus>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: ServiceStatus.values.map((status) {
                              String label;
                              switch (status) {
                                case ServiceStatus.pending:
                                  label = 'Pendente';
                                  break;
                                case ServiceStatus.inProgress:
                                  label = 'Em Andamento';
                                  break;
                                case ServiceStatus.finished:
                                  label = 'Finalizado';
                                  break;
                                case ServiceStatus.washing:
                                  label = 'Lavagem/Polimento';
                                  break;
                              }
                              return DropdownMenuItem<ServiceStatus>(
                                value: status,
                                child: Text(label),
                              );
                            }).toList(),
                            onChanged: (status) {
                              setState(() {
                                _selectedStatus = status;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Observações
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Observações',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: 'Nova observação',
                              hintText: 'Digite uma observação...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _addNote,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Observação'),
                          ),
                          if (_notes.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            ...List.generate(_notes.length, (index) {
                              final note = _notes[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(note.observation),
                                  subtitle: Text(_formatDateTime(note.dateTime)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeNote(index),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Peças/Itens
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peças e Itens',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _partCodeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Código',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _partNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nome',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _partBrandController,
                                  decoration: const InputDecoration(
                                    labelText: 'Marca (opcional)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _partPriceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Preço',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [_currencyMask],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _partQuantityController,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantidade',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _addPart,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Peça'),
                          ),
                          if (_parts.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            ...List.generate(_parts.length, (index) {
                              final part = _parts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text('${part.name} (${part.code})'),
                                  subtitle: Text('${part.brand} - ${part.quantity}x R\$ ${part.price.toStringAsFixed(2)}'),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'R\$ ${part.total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () => _removePart(index),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                border: Border.all(color: Colors.green[200]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total de Peças:',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${partsTotal.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mão de Obra
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mão de Obra',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _laborHoursController,
                                  decoration: const InputDecoration(
                                    labelText: 'Horas Trabalhadas',
                                    hintText: '0.00',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.access_time),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\\.,]')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _laborCostController,
                                  decoration: const InputDecoration(
                                    labelText: 'Custo de Mão de Obra (R\$)',
                                    hintText: '0.00',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [_currencyMask],
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              border: Border.all(color: Colors.blue[200]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Custo de Mão de Obra:',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'R\$ ${laborCost.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resumo Total
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumo Financeiro',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total de Peças:',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'R\$ ${partsTotal.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mão de Obra:',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'R\$ ${laborCost.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Geral:',
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fotos
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fotos do Serviço',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_afterImages.isEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Obrigatório',
                                    style: TextStyle(
                                      color: Colors.orange[800],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tire uma foto antes de finalizar o serviço',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Tirar Foto'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          if (_afterImages.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(_afterImages.length, (index) {
                                final imagePath = _afterImages[index];
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
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                          onPressed: () => _removeImage(index),
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

                  // Botão Finalizar
                  if (_selectedStatus != ServiceStatus.finished)
                    ElevatedButton.icon(
                      onPressed: _canFinalize ? _finalizeService : null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Finalizar Serviço'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

