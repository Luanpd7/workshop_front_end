// MechanicServiceEditScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../models/note.dart';
import '../models/part.dart';
import '../providers/service_provider.dart';
import 'package:flutter/services.dart';
import '../util/format_number.dart';
import 'package:intl/intl.dart';

/// Enum to select whether part dialog uses existing catalog or a new part.
enum _PartDialogMode { existing, newPart }

/// Main screen widget for editing a mechanic service.
class MechanicServiceEditScreen extends StatefulWidget {
  /// The service to be edited on this screen.
  final Service service;

  /// Default constructor.
  const MechanicServiceEditScreen({super.key, required this.service});

  @override
  State<MechanicServiceEditScreen> createState() =>
      _MechanicServiceEditScreenState();
}

/// State for the MechanicServiceEditScreen.
class _MechanicServiceEditScreenState extends State<MechanicServiceEditScreen> {
  /// Image picker used to capture after images.
  final ImagePicker _imagePicker = ImagePicker();

  /// Controller for the "add note" text field.
  final _noteController = TextEditingController();

  /// Controllers for part form fields used by AddPartDialog and parts logic.
  final _partCodeController = TextEditingController();
  final _partNameController = TextEditingController();
  final _partBrandController = TextEditingController();
  final _partPriceController = TextEditingController();
  final _partQuantityController = TextEditingController();

  /// Controllers for labor inputs.
  final _laborHoursController = TextEditingController();
  final _laborCostController = TextEditingController();

  /// Local copy of the service being edited.
  late Service _service;

  /// Controllers that encapsulate lists & logic for notes, parts and labor.
  late NotesController _notesController;
  late PartsController _partsController;
  late LaborController _laborController;

  /// Selected status of the service.
  ServiceStatus? _selectedStatus;

  /// List of available parts from other services (catalog).
  List<Part> _availableParts = [];

  /// List of after images paths for the service.
  List<String> _afterImages = [];

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _notesController = NotesController(initialNotes: List.from(_service.notes));
    _partsController = PartsController(initialParts: List.from(_service.parts));
    _afterImages = List.from(_service.afterImages);
    _laborController = LaborController(
      hours: _service.laborHours,
      hourlyRate: _service.laborCost,
    );

    _selectedStatus = _service.status;

    _laborHoursController.text = _laborController.hours.toStringAsFixed(2);
    _laborCostController.text = _laborController.hourlyRate > 0
        ? _laborController.hourlyRate.toStringAsFixed(2)
        : '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAvailableParts();
    });
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

  /// Helper to refresh catalog of available parts across services.
  void _refreshAvailableParts() {
    final services = context.read<ServiceProvider>().services;
    final Map<String, Part> uniqueParts = {};
    for (final service in services) {
      for (final part in service.parts) {
        final key = part.code.toLowerCase();
        uniqueParts[key] = part;
      }
    }
    setState(() {
      _availableParts = uniqueParts.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  /// Opens device camera to pick an after-image.
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

  /// Adds a note from the note text field into the notes controller.
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
      _notesController.add(Note(
        dateTime: DateTime.now(),
        observation: _noteController.text.trim(),
      ));
      _noteController.clear();
    });
  }

  /// Removes a note by index from notes controller.
  void _removeNote(int index) {
    setState(() {
      _notesController.removeAt(index);
    });
  }

  /// Reset part form controllers to defaults.
  void _resetPartForm() {
    _partCodeController.clear();
    _partNameController.clear();
    _partBrandController.clear();
    _partPriceController.clear();
    _partQuantityController.text = '1';
  }

  /// Prefills part form controllers with a Part instance.
  void _prefillPartForm(Part part) {
    _partCodeController.text = part.code;
    _partNameController.text = part.name;
    _partBrandController.text = part.brand;
    final formattedPrice = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
    ).format(part.price);
    _partPriceController.value = TextEditingValue(
      text: formattedPrice,
      selection: TextSelection.collapsed(offset: formattedPrice.length),
    );
    if (_partQuantityController.text.isEmpty) {
      _partQuantityController.text = '1';
    }
  }

  /// Update labor cost when inputs change.
  void _updateLaborCost() {
    final hours = double.tryParse(
      _laborHoursController.text.replaceAll(',', '.'),
    ) ??
        0.0;
    final hourlyRate = double.tryParse(
      _laborCostController.text
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.'),
    ) ??
        0.0;
    setState(() {
      _laborController.update(hours: hours, hourlyRate: hourlyRate);
    });
  }

  /// Shows the AddPartDialog to let user add a new or existing part.
  void _showAddPartDialog() {
    _refreshAvailableParts();
    _resetPartForm();
    showDialog(
      context: context,
      builder: (dialogContext) {
        Part? selectedCatalogPart =
        _availableParts.isNotEmpty ? _availableParts.first : null;
        if (selectedCatalogPart != null) {
          _prefillPartForm(selectedCatalogPart);
        }
        _PartDialogMode mode = selectedCatalogPart != null
            ? _PartDialogMode.existing
            : _PartDialogMode.newPart;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void selectCatalogPart(Part? part) {
              selectedCatalogPart = part;
              if (part != null) {
                _prefillPartForm(part);
              }
              setStateDialog(() {});
            }

            final bool hasCatalog = _availableParts.isNotEmpty;

            return AlertDialog(
              title: const Text('Adicionar peça'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasCatalog)
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Existente'),
                              selected: mode == _PartDialogMode.existing,
                              onSelected: (selected) {
                                if (!hasCatalog) return;
                                if (selected) {
                                  setStateDialog(() {
                                    mode = _PartDialogMode.existing;
                                    if (selectedCatalogPart == null &&
                                        _availableParts.isNotEmpty) {
                                      selectedCatalogPart = _availableParts.first;
                                      _prefillPartForm(selectedCatalogPart!);
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Nova Peça'),
                              selected: mode == _PartDialogMode.newPart,
                              onSelected: (selected) {
                                if (selected) {
                                  setStateDialog(() {
                                    mode = _PartDialogMode.newPart;
                                    _resetPartForm();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    if (hasCatalog) const SizedBox(height: 16),
                    if (mode == _PartDialogMode.existing && hasCatalog) ...[
                      DropdownButtonFormField<Part>(
                        value: selectedCatalogPart,
                        decoration: const InputDecoration(
                          labelText: 'Selecione uma peça',
                          border: OutlineInputBorder(),
                        ),
                        items: _availableParts.map((part) {
                          return DropdownMenuItem<Part>(
                            value: part,
                            child: Text('${part.name} (${part.code})'),
                          );
                        }).toList(),
                        onChanged: selectCatalogPart,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _partCodeController,
                      readOnly: mode == _PartDialogMode.existing,
                      decoration: const InputDecoration(
                        labelText: 'Código',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _partNameController,
                      readOnly: mode == _PartDialogMode.existing,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _partBrandController,
                      readOnly: mode == _PartDialogMode.existing,
                      decoration: const InputDecoration(
                        labelText: 'Marca (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _partPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [RealInputFormatter()],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _partQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final added = _addPart();
                    if (added) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Validates and adds a part from controllers into parts controller.
  bool _addPart() {
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
      return false;
    }
    final price = double.tryParse(_partPriceController.text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.'));
    final quantity = int.tryParse(_partQuantityController.text);
    if (price == null || quantity == null || price <= 0 || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preço e quantidade devem ser números válidos'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    final newCode = _partCodeController.text.trim();
    final exists = _partsController.parts
        .any((part) => part.code.toLowerCase() == newCode.toLowerCase());
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta peça já foi adicionada ao serviço'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    setState(() {
      _partsController.add(Part(
        code: newCode,
        name: _partNameController.text.trim(),
        brand: _partBrandController.text.trim().isEmpty
            ? 'Sem marca'
            : _partBrandController.text.trim(),
        price: price,
        quantity: quantity,
        total: price * quantity,
      ));
      _resetPartForm();
    });
    return true;
  }

  /// Removes a part by index from parts controller.
  void _removePart(int index) {
    setState(() {
      _partsController.removeAt(index);
    });
  }

  /// Removes an after image by index.
  void _removeImage(int index) {
    setState(() {
      _afterImages.removeAt(index);
    });
  }

  /// Whether this service can be edited.
  bool get _canEdit => _service.status != ServiceStatus.finished;

  /// Whether this service can be finalized (must have at least one after image).
  bool get _canFinalize =>
      _service.status != ServiceStatus.finished && _afterImages.isNotEmpty;

  /// Saves the service by creating a copy and calling provider update.
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
    _updateLaborCost();

    final partsTotal =
    _partsController.parts.fold(0.0, (sum, part) => sum + part.total);
    final laborHours = _laborController.hours;
    final laborCost = _laborController.totalCost;
    final totalCost = partsTotal + laborCost;

    final updatedService = _service.copyWith(
      status: _selectedStatus,
      notes: _notesController.notes,
      parts: _partsController.parts,
      afterImages: _afterImages,
      laborHours: laborHours,
      laborCost: laborCost,
      totalCost: totalCost,
      endDate:
      _selectedStatus == ServiceStatus.finished ? DateTime.now() : _service.endDate,
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

  /// Finalizes the service and updates provider.
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
    _updateLaborCost();

    final partsTotal =
    _partsController.parts.fold(0.0, (sum, part) => sum + part.total);
    final laborHours = _laborController.hours;
    final laborCost = _laborController.totalCost;
    final totalCost = partsTotal + laborCost;

    final updatedService = _service.copyWith(
      status: ServiceStatus.finished,
      notes: _notesController.notes,
      parts: _partsController.parts,
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

  /// Formats a DateTime to dd/MM/yyyy HH:mm format.
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final partsTotal =
    _partsController.parts.fold(0.0, (sum, part) => sum + part.total);
    final laborCost = _laborController.totalCost;
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
            // Status card
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
            // Notes section
            NotesSection(
              notesController: _notesController,
              noteController: _noteController,
              addNote: _addNote,
              removeNote: _removeNote,
              formatDateTime: _formatDateTime,
            ),
            const SizedBox(height: 16),
            // Parts section
            PartsSection(
              partsController: _partsController,
              availableParts: _availableParts,
              showAddPartDialog: _showAddPartDialog,
              removePart: _removePart,
            ),
            const SizedBox(height: 16),
            // Labor section
            LaborSection(
              laborHoursController: _laborHoursController,
              laborCostController: _laborCostController,
              updateLaborCost: _updateLaborCost,
              laborController: _laborController,
            ),
            const SizedBox(height: 16),
            // Financial summary
            FinancialSummarySection(
              partsTotal: partsTotal,
              laborCost: laborCost,
              totalCost: totalCost,
            ),
            const SizedBox(height: 16),
            // After images section
            AfterImagesSection(
              afterImages: _afterImages,
              pickImage: _pickImage,
              removeImage: _removeImage,
            ),
            const SizedBox(height: 24),
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
}

/// Controller class to manage notes list and simple ops.
class NotesController {
  /// Internal notes list.
  final List<Note> _notes;

  /// Constructor with initial notes.
  NotesController({List<Note>? initialNotes})
      : _notes = initialNotes ?? <Note>[];

  /// Returns immutable copy of notes.
  List<Note> get notes => List.unmodifiable(_notes);

  /// Adds a note to the list.
  void add(Note note) => _notes.add(note);

  /// Removes a note at given index.
  void removeAt(int index) => _notes.removeAt(index);
}

/// Controller class to manage parts list and simple ops.
class PartsController {
  /// Internal parts list.
  final List<Part> _parts;

  /// Constructor with initial parts.
  PartsController({List<Part>? initialParts})
      : _parts = initialParts ?? <Part>[];

  /// Returns the mutable parts list (use with care).
  List<Part> get parts => _parts;

  /// Adds a part to the list.
  void add(Part part) => _parts.add(part);

  /// Removes part at index.
  void removeAt(int index) => _parts.removeAt(index);
}

/// Controller class to manage labor calculations.
class LaborController {
  /// Worked hours.
  double hours;

  /// Hourly rate.
  double hourlyRate;

  /// Total labor cost computed.
  double get totalCost => hours * hourlyRate;

  /// Constructor with initial values.
  LaborController({this.hours = 0.0, double? hourlyRate})
      : hourlyRate = hourlyRate ?? (hours > 0 ? 0.0 : 0.0);

  /// Updates hours and hourly rate and recalculates.
  void update({double? hours, double? hourlyRate}) {
    if (hours != null) this.hours = hours;
    if (hourlyRate != null) this.hourlyRate = hourlyRate;
  }
}

/// Widget that shows notes UI block.
class NotesSection extends StatelessWidget {
  /// Notes controller providing data.
  final NotesController notesController;

  /// External text controller for the new note field.
  final TextEditingController noteController;

  /// Callback to add a note.
  final VoidCallback addNote;

  /// Callback to remove a note by index.
  final void Function(int) removeNote;

  /// Formatter function for note DateTime.
  final String Function(DateTime) formatDateTime;

  /// Constructor.
  const NotesSection({
    super.key,
    required this.notesController,
    required this.noteController,
    required this.addNote,
    required this.removeNote,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card wrapper for notes UI.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Observações',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Nova observação',
              hintText: 'Digite uma observação...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: addNote,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Observação'),
          ),
          if (notesController.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...List.generate(notesController.notes.length, (index) {
              final note = notesController.notes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(note.observation),
                  subtitle: Text(formatDateTime(note.dateTime)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeNote(index),
                  ),
                ),
              );
            }),
          ],
        ]),
      ),
    );
  }
}

/// Widget that shows parts UI block and interactions.
class PartsSection extends StatelessWidget {
  /// Parts controller with current parts.
  final PartsController partsController;

  /// Catalog of available parts to pick from.
  final List<Part> availableParts;

  /// Callback to open part addition dialog.
  final VoidCallback showAddPartDialog;

  /// Callback to remove a part by index.
  final void Function(int) removePart;

  /// Constructor.
  const PartsSection({
    super.key,
    required this.partsController,
    required this.availableParts,
    required this.showAddPartDialog,
    required this.removePart,
  });

  @override
  Widget build(BuildContext context) {
    final partsTotal =
    partsController.parts.fold(0.0, (sum, part) => sum + part.total);
    return Card(
      // Card wrapper for parts UI.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Peças e Itens',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Selecione uma peça existente ou cadastre uma nova utilizando o botão abaixo.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: showAddPartDialog,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Peça'),
          ),
          if (partsController.parts.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...List.generate(partsController.parts.length, (index) {
              final part = partsController.parts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${part.name} (${part.code})'),
                  subtitle:
                  Text('${part.brand} - ${part.quantity}x R\$ ${formatNumberBR(part.price)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${formatNumberBR(part.total)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => removePart(index),
                        ),
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
                    'R\$ ${formatNumberBR(partsTotal)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

/// Widget that shows labor input and calculated cost.
class LaborSection extends StatelessWidget {
  /// Controller for labor hours input.
  final TextEditingController laborHoursController;

  /// Controller for hourly rate input.
  final TextEditingController laborCostController;

  /// Callback to update labor calculation.
  final VoidCallback updateLaborCost;

  /// Labor controller holding state and calculations.
  final LaborController laborController;

  /// Constructor.
  const LaborSection({
    super.key,
    required this.laborHoursController,
    required this.laborCostController,
    required this.updateLaborCost,
    required this.laborController,
  });

  @override
  Widget build(BuildContext context) {
    final laborCost = laborController.totalCost;
    return Card(
      // Card wrapper for labor UI.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Mão de Obra',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: TextField(
                controller: laborHoursController,
                decoration: const InputDecoration(
                  labelText: 'Horas Trabalhadas',
                  hintText: '0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  updateLaborCost();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: laborCostController,
                decoration: const InputDecoration(
                  labelText: 'Valor por Hora (R\$)',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [RealInputFormatter()],
                onChanged: (value) {
                  updateLaborCost();
                },
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'Custo de Mão de Obra:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'R\$ ${formatNumberBR(laborCost)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Widget that shows financial summary block.
class FinancialSummarySection extends StatelessWidget {
  /// Total value of parts.
  final double partsTotal;

  /// Total value of labor.
  final double laborCost;

  /// Combined total.
  final double totalCost;

  /// Constructor.
  const FinancialSummarySection({
    super.key,
    required this.partsTotal,
    required this.laborCost,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card wrapper for financial summary.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Resumo Financeiro',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total de Peças:', style: Theme.of(context).textTheme.bodyLarge),
            Text('R\$ ${formatNumberBR(partsTotal)}',
                style: Theme.of(context).textTheme.bodyLarge),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Mão de Obra:', style: Theme.of(context).textTheme.bodyLarge),
            Text('R\$ ${formatNumberBR(laborCost)}',
                style: Theme.of(context).textTheme.bodyLarge),
          ]),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'Total Geral:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'R\$ ${formatNumberBR(totalCost)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// Widget that handles after images capture and preview.
class AfterImagesSection extends StatelessWidget {
  /// List of after image paths.
  final List<String> afterImages;

  /// Callback to take a photo.
  final Future<void> Function() pickImage;

  /// Callback to remove an image by index.
  final void Function(int) removeImage;

  /// Constructor.
  const AfterImagesSection({
    super.key,
    required this.afterImages,
    required this.pickImage,
    required this.removeImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card wrapper for after images UI.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'Fotos do Serviço',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (afterImages.isEmpty)
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
          ]),
          const SizedBox(height: 8),
          Text(
            'Tire uma foto antes de finalizar o serviço',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => pickImage(),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Tirar Foto'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          if (afterImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(afterImages.length, (index) {
                final imagePath = afterImages[index];
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
                        child: imagePath.startsWith('http') ||
                            imagePath.startsWith('https')
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
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 16),
                          onPressed: () => removeImage(index),
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
        ]),
      ),
    );
  }
}
