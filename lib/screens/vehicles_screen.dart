import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/vehicle_provider.dart';
import '../providers/client_provider.dart';
import '../models/vehicle.dart';
import '../models/client.dart';
import 'vehicle_form_screen.dart';
import 'vehicle_detail_screen.dart';

/// Screen that lists vehicles optionally filtered by a selected client.
class VehiclesScreen extends StatefulWidget {
  final Client? client;

  const VehiclesScreen({super.key, this.client});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

/// State class responsible for managing vehicle listing and filtering.
class _VehiclesScreenState extends State<VehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadVehicles(clientId: widget.client?.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Expanded(child: _buildVehicleList()),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(context),
    );
  }

  /// Builds the page AppBar with dynamic title and actions.
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.client != null
          ? 'Veículos de ${widget.client!.name}'
          : 'Veículos'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        if (widget.client == null)
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showClientFilter,
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _searchController.clear();
            context.read<VehicleProvider>().loadVehicles(clientId: widget.client?.id);
          },
        ),
      ],
    );
  }

  /// Builds the vehicle list area with loading and error handling.
  Widget _buildVehicleList() {
    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _ErrorView(message: provider.error!);
        }

        if (provider.vehicles.isEmpty) {
          return _EmptyVehiclesView(client: widget.client);
        }

        return ListView.builder(
          itemCount: provider.vehicles.length,
          itemBuilder: (context, index) {
            return VehicleCard(vehicle: provider.vehicles[index]);
          },
        );
      },
    );
  }

  /// Builds floating action button for adding a new vehicle.
  FloatingActionButton _buildAddButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleFormScreen(client: widget.client),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  /// Shows dialog to select a client to filter vehicles.
  void _showClientFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Cliente'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<ClientProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return _ClientFilterList(provider: provider);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}

/// Card representing a single vehicle in the list.
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.directions_car, color: Colors.white),
        ),
        title: Text(vehicle.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: _buildSubtitle(),
        trailing: _buildMenu(context),
        onTap: () => _viewDetails(context),
      ),
    );
  }

  /// Builds subtitle information (plate and optional color).
  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Placa: ${vehicle.plateDisplay}'),
        if (vehicle.color != null)
          Text(
            'Cor: ${vehicle.colorDisplay}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
      ],
    );
  }

  /// Builds popup menu with actions: view, edit, delete.
  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'view':
            _viewDetails(context);
            break;
          case 'edit':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VehicleFormScreen(vehicle: vehicle)),
            );
            break;
          case 'delete':
            _showDeleteDialog(context);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(children: [Icon(Icons.visibility), SizedBox(width: 8), Text('Ver detalhes')]),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Editar')]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.red))]),
        ),
      ],
    );
  }

  /// Opens the details page of the selected vehicle.
  void _viewDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: vehicle)),
    );
  }

  /// Shows dialog to confirm deletion.
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Veículo'),
        content: Text('Tem certeza que deseja excluir o veículo "${vehicle.displayName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<VehicleProvider>().deleteVehicle(vehicle.id!);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Widget that displays an empty-state message when no vehicles exist.
class _EmptyVehiclesView extends StatelessWidget {
  final Client? client;

  const _EmptyVehiclesView({required this.client});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            client != null ? 'Nenhum veículo cadastrado' : 'Nenhum veículo encontrado',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            client != null
                ? 'Toque no botão + para adicionar um veículo'
                : 'Toque no botão + para adicionar um novo veículo',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Widget that displays an error message with retry option.
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Erro ao carregar veículos', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// List widget for selecting a client to filter vehicle results.
class _ClientFilterList extends StatelessWidget {
  final ClientProvider provider;

  const _ClientFilterList({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: provider.clients.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('Todos os veículos'),
            onTap: () {
              context.read<VehicleProvider>().clearFilter();
              Navigator.pop(context);
            },
          );
        }

        final client = provider.clients[index - 1];
        return ListTile(
          leading: CircleAvatar(child: Text(client.name[0].toUpperCase())),
          title: Text(client.name),
          subtitle: Text(client.phone),
          onTap: () {
            context.read<VehicleProvider>().loadVehicles(clientId: client.id);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
