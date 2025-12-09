import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/client_provider.dart';
import '../models/vehicle.dart';
import 'vehicle_form_screen.dart';

/// Screen that displays detailed information about a vehicle.
class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VehicleDetailAppBar(vehicle: vehicle),
      body: VehicleDetailBody(vehicle: vehicle),
    );
  }
}

/// AppBar containing vehicle actions such as edit and delete.
class VehicleDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Vehicle vehicle;

  const VehicleDetailAppBar({super.key, required this.vehicle});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Detalhes do Veículo'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleFormScreen(vehicle: vehicle),
                  ),
                );
                break;
              case 'delete':
                _showDeleteDialog(context);
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Shows confirmation dialog before deleting a vehicle.
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VehicleDeleteDialog(vehicle: vehicle),
    );
  }
}

/// Main body containing all vehicle details and actions.
class VehicleDetailBody extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailBody({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VehicleCard(vehicle: vehicle),
          const SizedBox(height: 24),
          VehicleActions(vehicle: vehicle),
          const SizedBox(height: 16),
          const VehicleErrorBox(),
        ],
      ),
    );
  }
}

/// Card displaying all the basic and optional vehicle information.
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VehicleHeader(vehicle: vehicle),
            const SizedBox(height: 24),

            _InfoTile(icon: Icons.branding_watermark, title: 'Marca', value: vehicle.brand),
            const SizedBox(height: 16),

            _InfoTile(icon: Icons.directions_car, title: 'Modelo', value: vehicle.model),
            const SizedBox(height: 16),

            _InfoTile(icon: Icons.calendar_today, title: 'Ano', value: vehicle.year.toString()),
            const SizedBox(height: 16),

            if (_hasValue(vehicle.color))
              ...[
                _InfoTile(icon: Icons.palette, title: 'Cor', value: vehicle.color!),
                const SizedBox(height: 16),
              ],

            if (_hasValue(vehicle.plate))
              ...[
                _InfoTile(icon: Icons.confirmation_number, title: 'Placa', value: vehicle.plate!),
                const SizedBox(height: 16),
              ],

            const ClientInfoSection(),
          ],
        ),
      ),
    );
  }

  /// Returns true when a string is not null and not empty.
  bool _hasValue(String? value) => value != null && value.isNotEmpty;
}

/// Header with avatar, name and ID.
class VehicleHeader extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleHeader({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.directions_car, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${vehicle.id}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Section that displays the client linked to the vehicle.
class ClientInfoSection extends StatelessWidget {
  const ClientInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientProvider>(
      builder: (context, provider, child) {
        final vehicle = context.findAncestorWidgetOfExactType<VehicleCard>()!.vehicle;
        final client = provider.clients.where((c) => c.id == vehicle.clientId).firstOrNull;

        if (client == null) return const SizedBox.shrink();

        return Column(
          children: [
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cliente', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                      const SizedBox(height: 2),
                      Text(client.name, style: Theme.of(context).textTheme.bodyLarge),
                      Text(
                        client.phone,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Row of edit and delete buttons.
class VehicleActions extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleActions({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VehicleFormScreen(vehicle: vehicle)),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => VehicleDeleteDialog(vehicle: vehicle),
            ),
            icon: const Icon(Icons.delete),
            label: const Text('Excluir'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Shows backend errors from the VehicleProvider.
class VehicleErrorBox extends StatelessWidget {
  const VehicleErrorBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, provider, child) {
        if (provider.error == null) return const SizedBox.shrink();

        return Container(
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
              Expanded(child: Text(provider.error!, style: TextStyle(color: Colors.red[600]))),
            ],
          ),
        );
      },
    );
  }
}

/// Dialog to confirm vehicle deletion.
class VehicleDeleteDialog extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDeleteDialog({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir Veículo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tem certeza que deseja excluir o veículo "${vehicle.displayName}"?'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[600], size: 20),
                const SizedBox(width: 8),
                const Expanded(child: Text('Esta ação não pode ser desfeita.', style: TextStyle(fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<VehicleProvider>().deleteVehicle(vehicle.id!);
            Navigator.pop(context);
          },
          child: const Text('Excluir', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

/// Reusable tile to show an icon, title and value.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
