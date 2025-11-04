import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider.dart';
import '../providers/client_provider.dart';
import '../models/service.dart';
import '../models/client.dart';
import 'service_form_screen.dart';


class ServicesScreen extends StatefulWidget {
  final Client? client;

  const ServicesScreen({super.key, this.client});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices(clientId: widget.client?.id);
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

  void _onStatusFilterChanged(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    context.read<ServiceProvider>().loadServices(
      status: status,
      clientId: widget.client?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client != null 
            ? 'Serviços de ${widget.client!.name}'
            : 'Serviços'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              context.read<ServiceProvider>().loadServices(clientId: widget.client?.id);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar serviços...',
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
          // Filtros de status
          if (widget.client == null) _buildStatusFilter(),
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
                          'Erro ao carregar serviços',
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
                          onPressed: () => provider.loadServices(clientId: widget.client?.id),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.services.isEmpty) {
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
                          widget.client != null 
                              ? 'Nenhum serviço encontrado'
                              : 'Nenhum serviço cadastrado',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.client != null
                              ? 'Este cliente ainda não possui serviços'
                              : 'Toque no botão + para adicionar um novo serviço',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.services.length,
                  itemBuilder: (context, index) {
                    final service = provider.services[index];
                    return _ServiceCard(service: service);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ServiceFormScreen(client: widget.client),
          //   ),
          // );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  Widget _buildStatusFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _StatusChip(
            label: 'Todos',
            isSelected: _selectedStatus == null,
            onTap: () => _onStatusFilterChanged(null),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Pendentes',
            isSelected: _selectedStatus == 'pending',
            onTap: () => _onStatusFilterChanged('pending'),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Em Andamento',
            isSelected: _selectedStatus == 'inProgress',
            onTap: () => _onStatusFilterChanged('inProgress'),
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Finalizados',
            isSelected: _selectedStatus == 'finished',
            onTap: () => _onStatusFilterChanged('finished'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<ClientProvider>(
              builder: (context, clientProvider, child) {
                return DropdownButtonFormField<Client?>(
                  value: widget.client,
                  decoration: const InputDecoration(
                    labelText: 'Cliente',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<Client?>(
                      value: null,
                      child: Text('Todos os clientes'),
                    ),
                    ...clientProvider.clients.map((client) {
                      return DropdownMenuItem<Client?>(
                        value: client,
                        child: Text(client.name),
                      );
                    }),
                  ],
                  onChanged: (client) {
                    Navigator.pop(context);
                    context.read<ServiceProvider>().loadServices(clientId: client?.id);
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(service.status),
          child: Icon(
            _getStatusIcon(service.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          'Serviço #${service.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mecânico: ${service.mechanicName}'),
            if (service.startDate != null)
              Text('Início: ${_formatDate(service.startDate!)}'),
            Text('Status: ${service.statusDisplay}'),
            if (service.totalCost > 0)
              Text(
                'Valor: R\$ ${service.totalCost.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ServiceDetailScreen(service: service),
                //   ),
                // );
                break;
              case 'edit':
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ServiceFormScreen(service: service),
                //   ),
                // );
                break;
              case 'delete':
                _showDeleteDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Ver detalhes'),
                ],
              ),
            ),
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
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ServiceDetailScreen(service: service),
          //   ),
          // );
        },
      ),
    );
  }

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return Colors.orange;
      case ServiceStatus.inProgress:
        return Colors.blue;
      case ServiceStatus.finished:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return Icons.schedule;
      case ServiceStatus.inProgress:
        return Icons.build;
      case ServiceStatus.finished:
        return Icons.check_circle;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: Text('Tem certeza que deseja excluir o serviço #${service.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ServiceProvider>().deleteService(service.id!);
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
