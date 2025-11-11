import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/service_provider.dart';
import '../models/service.dart';
import 'mechanic_service_edit_screen.dart';
import 'settings_screen.dart';

class MechanicHomeScreen extends StatefulWidget {
  const MechanicHomeScreen({super.key});

  @override
  State<MechanicHomeScreen> createState() => _MechanicHomeScreenState();
}

class _MechanicHomeScreenState extends State<MechanicHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mechanicId = context.read<AuthProvider>().mechanicId;
      if (mechanicId != null) {
        context.read<ServiceProvider>().loadServices();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<ServiceProvider>().searchServices(query);
  }

  List<Service> get _myServices {
    final mechanicId = context.read<AuthProvider>().mechanicId;


    if (mechanicId == null) return [];





    return context.read<ServiceProvider>().services
        .where((service)  {
      return service.mechanicId == mechanicId;
    })
        .toList();

  }

  @override
  Widget build(BuildContext context) {
    final mechanicId = context.read<AuthProvider>().mechanicId;
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myServices),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              // O AuthWrapper vai redirecionar automaticamente
            },
            tooltip: localizations.logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.build_circle,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.appTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(localizations.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(localizations.logout),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthProvider>().logout();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localizations.searchServices,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          
          // Lista de serviços
          Expanded(
            child: Consumer<ServiceProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.errorLoadingServices,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (mechanicId != null) {
                              provider.loadServices();
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(localizations.tryAgain),
                        ),
                      ],
                    ),
                  );
                }

                final myServices = _myServices;

                if (myServices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.build_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.noServiceAssigned,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.noServiceAssignedDescription,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: myServices.length,
                  itemBuilder: (context, index) {
                    final service = myServices[index];
                    return _MechanicServiceCard(service: service);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MechanicServiceCard extends StatelessWidget {
  final Service service;

  const _MechanicServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    Color statusColor;
    IconData statusIcon;

    switch (service.status) {
      case ServiceStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case ServiceStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.build;
        break;
      case ServiceStatus.finished:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case ServiceStatus.washing:
        statusColor = Colors.purple;
        statusIcon = Icons.cleaning_services_outlined;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(statusIcon, color: Colors.white),
        ),
        title: Text(
          '${localizations.service} #${service.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations.status}: ${service.statusDisplay}'),
            if (service.startDate != null)
              Text('${localizations.startDate}: ${_formatDate(service.startDate!)}'),
            if (service.totalCost > 0)
              Text(
                '${localizations.value}: R\$ ${service.totalCost.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MechanicServiceEditScreen(service: service),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

