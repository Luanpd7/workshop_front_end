import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mechanic_provider.dart';
import '../models/mechanic.dart';
import 'mechanic_form_screen.dart';

/// Main screen that displays mechanic details.
class MechanicDetailScreen extends StatelessWidget {
  final Mechanic mechanic;

  const MechanicDetailScreen({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MechanicDetailAppBar(mechanic: mechanic),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MechanicInfoCard(mechanic: mechanic),
            const SizedBox(height: 24),
            MechanicActionsRow(mechanic: mechanic),
            MechanicErrorBox(),
          ],
        ),
      ),
    );
  }
}

//
// ─────────────────────────────────────────────────────────────
//   APP BAR
// ─────────────────────────────────────────────────────────────
//

/// AppBar with actions for editing and deleting.
class MechanicDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Mechanic mechanic;

  const MechanicDetailAppBar({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Detalhes do Mecânico'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MechanicFormScreen(mechanic: mechanic),
                ),
              );
            } else if (value == 'delete') {
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

//
// ─────────────────────────────────────────────────────────────
//   INFO CARD
// ─────────────────────────────────────────────────────────────
//

/// Card that displays all mechanic information.
class MechanicInfoCard extends StatelessWidget {
  final Mechanic mechanic;

  const MechanicInfoCard({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MechanicHeader(mechanic: mechanic),
            const SizedBox(height: 24),
            _InfoTile(icon: Icons.phone, title: 'Telefone', value: mechanic.phone),
            const SizedBox(height: 16),
            if (mechanic.email != null && mechanic.email!.isNotEmpty)
              ...[
                _InfoTile(
                    icon: Icons.email, title: 'Email', value: mechanic.email!),
                const SizedBox(height: 16),
              ],
            _InfoTile(
              icon: Icons.calendar_today,
              title: 'Data de Cadastro',
              value: _formatFullDate(mechanic.registrationDate),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header with avatar, name and registration date.
class MechanicHeader extends StatelessWidget {
  final Mechanic mechanic;

  const MechanicHeader({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Text(
            mechanic.name.isNotEmpty
                ? mechanic.name[0].toUpperCase()
                : '?',
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
                mechanic.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mecânico desde ${_formatDate(mechanic.registrationDate)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//
// ─────────────────────────────────────────────────────────────
//   ACTION BUTTONS
// ─────────────────────────────────────────────────────────────
//

/// Edit and delete buttons displayed at bottom of screen.
class MechanicActionsRow extends StatelessWidget {
  final Mechanic mechanic;

  const MechanicActionsRow({super.key, required this.mechanic});

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
                  builder: (context) => MechanicFormScreen(mechanic: mechanic),
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
            icon: const Icon(Icons.delete),
            label: const Text('Excluir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

//
// ─────────────────────────────────────────────────────────────
//   ERROR BOX
// ─────────────────────────────────────────────────────────────
//

/// Error box displayed when provider contains an error.
class MechanicErrorBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MechanicProvider>(
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

//
// ─────────────────────────────────────────────────────────────
//   DELETE DIALOG
// ─────────────────────────────────────────────────────────────
//

/// Shows confirmation dialog for deleting mechanic.
void _showDeleteDialog(BuildContext context) {
  final mechanic = (context.findAncestorWidgetOfExactType<MechanicDetailScreen>()!).mechanic;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Excluir Mecânico'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tem certeza que deseja excluir o mecânico "${mechanic.name}"?'),
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
            context.read<MechanicProvider>().deleteMechanic(mechanic.id!);
            Navigator.pop(context);
          },
          child: const Text('Excluir', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

//
// ─────────────────────────────────────────────────────────────
//   UTILS
// ─────────────────────────────────────────────────────────────
//

/// Formats date as dd/MM/yyyy.
String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

/// Formats date with month name.
String _formatFullDate(DateTime date) {
  const months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  return '${date.day} de ${months[date.month - 1]} de ${date.year}';
}

//
// ─────────────────────────────────────────────────────────────
//   INFO TILE
// ─────────────────────────────────────────────────────────────
//

/// Single line of description inside info card.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

