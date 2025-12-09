import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import '../providers/mechanic_provider.dart';
import '../models/client.dart';
import '../models/mechanic.dart';
import '../services/vehicle_service.dart';
import 'client_form_screen.dart';
import 'client_detail_screen.dart';
import 'mechanic_form_screen.dart';
import 'mechanic_detail_screen.dart';


/// Main screen with tabs for Clients and Mechanics.
class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

/// Screen state responsible for managing tabs and loading data.
class _ClientsScreenState extends State<ClientsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _clientSearchController =
  TextEditingController();
  final TextEditingController _mechanicSearchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<ClientProvider>().loadClients();
      context.read<MechanicProvider>().loadMechanics();
      await VehicleService().testarConexao();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clientSearchController.dispose();
    _mechanicSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes e Mecânicos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Clientes'),
            Tab(icon: Icon(Icons.build), text: 'Mecânicos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ClientsTab(),     // Extracted widget
          MechanicsTab(),   // Extracted widget
        ],
      ),
      floatingActionButton: _MainFab(tabController: _tabController),
    );
  }
}



/// Tab responsible for listing all clients.
class ClientsTab extends StatelessWidget {
  const ClientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Consumer<ClientProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return ErrorState(
              message: provider.error!,
              title: "Erro ao carregar clientes",
              icon: Icons.error_outline,
              onRetry: provider.loadClients,
            );
          }

          if (provider.clients.isEmpty) {
            return EmptyState(
              title: "Nenhum cliente encontrado",
              subtitle: "Toque no botão + para adicionar um novo cliente",
              icon: Icons.people_outline,
            );
          }

          return ListView.builder(
            itemCount: provider.clients.length,
            itemBuilder: (context, index) =>
                ClientCard(client: provider.clients[index]),
          );
        },
      ),
    );
  }
}



/// Tab responsible for listing all mechanics.
class MechanicsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Consumer<MechanicProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return ErrorState(
              message: provider.error!,
              title: "Erro ao carregar mecânicos",
              icon: Icons.error_outline,
              onRetry: provider.loadMechanics,
            );
          }

          if (provider.mechanics.isEmpty) {
            return EmptyState(
              title: "Nenhum mecânico encontrado",
              subtitle: "Toque no botão + para adicionar um novo mecânico",
              icon: Icons.build_outlined,
            );
          }

          return ListView.builder(
            itemCount: provider.mechanics.length,
            itemBuilder: (context, index) =>
                MechanicCard(mechanic: provider.mechanics[index]),
          );
        },
      ),
    );
  }
}



/// Floating action button that opens correct form based on selected tab.
class _MainFab extends StatelessWidget {
  final TabController tabController;

  const _MainFab({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (tabController.index == 0) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ClientFormScreen()));
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const MechanicFormScreen()));
        }
      },
      child: const Icon(Icons.add),
    );
  }
}



/// Card widget responsible for showing a client's summary info.
class ClientCard extends StatelessWidget {
  final Client client;

  const ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(client.name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: _ClientSubtitle(client: client),
        trailing: _ClientPopupMenu(client: client),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClientDetailScreen(client: client)),
        ),
      ),
    );
  }
}

/// Subtitle widget with client phone/email/date.
class _ClientSubtitle extends StatelessWidget {
  final Client client;

  const _ClientSubtitle({required this.client});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(client.phone),
        if (client.email != null && client.email!.isNotEmpty)
          Text(client.email!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text(
          "Cadastrado em: ${_formatDate(client.registrationDate)}",
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
      ],
    );
  }
}

/// Popup menu to view, edit or delete a client.
class _ClientPopupMenu extends StatelessWidget {
  final Client client;

  const _ClientPopupMenu({required this.client});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'view':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ClientDetailScreen(client: client)));
            break;

          case 'edit':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => ClientFormScreen(client: client)));
            break;

          case 'delete':
            _showDeleteDialog(context);
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(children: [Icon(Icons.visibility), SizedBox(width: 8), Text("Ver detalhes")]),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text("Editar")]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text("Excluir", style: TextStyle(color: Colors.red))
          ]),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir Cliente"),
        content: Text('Tem certeza que deseja excluir "${client.name}"?'),
        actions: [
          TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              context.read<ClientProvider>().deleteClient(client.id!);
            },
          ),
        ],
      ),
    );
  }
}



/// Card widget responsible for showing a mechanic's summary info.
class MechanicCard extends StatelessWidget {
  final Mechanic mechanic;

  const MechanicCard({required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Text(
            mechanic.name.isEmpty ? '?' : mechanic.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(mechanic.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: _MechanicSubtitle(mechanic: mechanic),
        trailing: _MechanicPopupMenu(mechanic: mechanic),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MechanicDetailScreen(mechanic: mechanic)),
        ),
      ),
    );
  }
}

/// Subtitle widget showing mechanic phone/email/date.
class _MechanicSubtitle extends StatelessWidget {
  final Mechanic mechanic;

  const _MechanicSubtitle({required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mechanic.phone),
        if (mechanic.email != null && mechanic.email!.isNotEmpty)
          Text(mechanic.email!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text(
          "Cadastrado em: ${_formatDate(mechanic.registrationDate)}",
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
      ],
    );
  }
}

/// Popup menu to view, edit or delete a mechanic.
class _MechanicPopupMenu extends StatelessWidget {
  final Mechanic mechanic;

  const _MechanicPopupMenu({required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'view':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => MechanicDetailScreen(mechanic: mechanic)));
            break;

          case 'edit':
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => MechanicFormScreen(mechanic: mechanic)));
            break;

          case 'delete':
            _showDeleteDialog(context);
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(children: [Icon(Icons.visibility), SizedBox(width: 8), Text("Ver detalhes")]),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text("Editar")]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text("Excluir", style: TextStyle(color: Colors.red))
          ]),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir Mecânico"),
        content: Text('Tem certeza que deseja excluir "${mechanic.name}"?'),
        actions: [
          TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              context.read<MechanicProvider>().deleteMechanic(mechanic.id!);
            },
          ),
        ],
      ),
    );
  }
}



/// Reusable widget for error states with retry button.
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onRetry;

  const ErrorState({
    required this.title,
    required this.message,
    required this.icon,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

/// Reusable widget for empty list states.
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}



/// Formats a date (DD/MM/YYYY).
String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
