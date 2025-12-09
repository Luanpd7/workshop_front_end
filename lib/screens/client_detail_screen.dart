import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'client_form_screen.dart';
import 'vehicle_form_screen.dart';
import 'vehicles_screen.dart';
import '../providers/client_provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/client.dart';


/// Screen that displays details about a specific client.
class ClientDetailScreen extends StatelessWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClientDetailAppBar(client: client),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClientHeaderCard(client: client),
            const SizedBox(height: 24),

            ClientVehiclesSection(client: client),
            const SizedBox(height: 24),

            ClientActionsRow(client: client),
            ClientErrorMessage(),
          ],
        ),
      ),
    );
  }
}


/// AppBar that contains options to edit or delete the client.
class ClientDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Client client;

  const ClientDetailAppBar({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Detalhes do Cliente'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientFormScreen(client: client),
                ),
              );
            } else {
              _showDeleteDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


/// Shows the client's avatar, name, phone, email, and registration date.
class ClientHeaderCard extends StatelessWidget {
  final Client client;

  const ClientHeaderCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClientAvatarHeader(client: client),
            const SizedBox(height: 24),

            ClientInfoTile(
              icon: Icons.phone,
              title: 'Telefone',
              value: client.phone,
            ),
            const SizedBox(height: 16),

            if (client.email != null && client.email!.isNotEmpty) ...[
              ClientInfoTile(
                icon: Icons.email,
                title: 'Email',
                value: client.email!,
              ),
              const SizedBox(height: 16),
            ],

            ClientInfoTile(
              icon: Icons.calendar_today,
              title: 'Data de Cadastro',
              value: _formatFullDate(client.registrationDate),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'Janeiro','Fevereiro','Março','Abril','Maio','Junho',
      'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

/// Displays the client's avatar with first letter and basic info.
class ClientAvatarHeader extends StatelessWidget {
  final Client client;

  const ClientAvatarHeader({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cliente desde ${_formatDate(client.registrationDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2,'0')}/'
        '${date.month.toString().padLeft(2,'0')}/'
        '${date.year}';
  }
}


/// Small tile used to display a labeled client field with icon.
class ClientInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ClientInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}


/// Card that shows last registered vehicles and links to full list.
class ClientVehiclesSection extends StatelessWidget {
  final Client client;

  const ClientVehiclesSection({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            VehiclesHeader(client: client),
            const SizedBox(height: 16),
            VehiclesPreviewList(client: client),
          ],
        ),
      ),
    );
  }
}

/// Header with "View all" and "Add vehicle" buttons.
class VehiclesHeader extends StatelessWidget {
  final Client client;

  const VehiclesHeader({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Veículos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehiclesScreen(client: client),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('Ver todos'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleFormScreen(client: client),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shows up to 3 recent client vehicles.
class VehiclesPreviewList extends StatelessWidget {
  final Client client;

  const VehiclesPreviewList({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.filterClientId != client.id) {
          WidgetsBinding.instance.addPostFrameCallback(
                (_) => provider.loadVehicles(clientId: client.id),
          );
        }

        final vehicles = provider.vehicles
            .where((v) => v.clientId == client.id)
            .take(3)
            .toList();

        if (vehicles.isEmpty) {
          return EmptyVehiclesBox();
        }

        return Column(
          children: vehicles.map(
                (v) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.directions_car, color: Colors.white),
              ),
              title: Text(v.displayName),
              subtitle: Text('Placa: ${v.plateDisplay}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehiclesScreen(client: client),
                  ),
                );
              },
            ),
          ).toList(),
        );
      },
    );
  }
}

/// Shown when client has no vehicles.
class EmptyVehiclesBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car_outlined, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nenhum veículo cadastrado',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}


/// Row containing "Edit" and "Delete" buttons.
class ClientActionsRow extends StatelessWidget {
  final Client client;

  const ClientActionsRow({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientFormScreen(client: client),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showDeleteDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: const Text('Excluir'),
          ),
        ),
      ],
    );
  }
}


/// Displays provider error message if present.
class ClientErrorMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ClientProvider>(
      builder: (context, provider, _) {
        if (provider.error == null) return const SizedBox.shrink();

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
      },
    );
  }
}


/// Shows a confirmation dialog before deleting a client.
void _showDeleteDialog(BuildContext context) {
  final client = (context.widget as ClientDetailScreen).client;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Excluir Cliente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tem certeza que deseja excluir o cliente "${client.name}"?'),
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
                Icon(Icons.warning, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Esta ação não pode ser desfeita.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<ClientProvider>().deleteClient(client.id!);
            Navigator.pop(context);
          },
          child: const Text('Excluir', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
