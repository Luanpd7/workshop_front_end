import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:workshop_front_end/login/entities/login.dart';
import 'package:workshop_front_end/login/view.dart';
import '../domain/use_case_service.dart';
import '../id_context.dart';
import '../mechanic/mechanic_area.dart';
import '../repository/repository_service.dart';
import '../service/entities/service.dart';
import '../service/list_service.dart';

/// State da home
class HomeState with ChangeNotifier {
  String _selectedPeriod = '7d';
  List<ServiceDetails> _services = [];

  List<UserRanking> rankingUsers = [];

  bool loading = false;

  String get selectedPeriod => _selectedPeriod;

  HomeState() {
    _init();
  }

  /// Para selecionar periodo no gráfico
  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  Future<void> _init() async {
    loading = true;
    notifyListeners();
    final repository = RepositoryService();
    final useCaseService = UseCaseService(repository);
    final id = UserContext().id;
    _services =
        await useCaseService.getAllServices(idUser: id == 1 ? null : id);
    rankingUsers = await useCaseService.getRankingUsers();

    loading = false;
    notifyListeners();
  }

  /// Função responsável por agrupar os serviços pela data
  Map<String, int> _groupServicesByDate() {
    final now = DateTime.now();
    final Map<String, int> result = {};

    for (final service in _services) {
      final date = service.entryDate;
      if (date != null) {
        if (_selectedPeriod == '7d' &&
            date.isAfter(now.subtract(Duration(days: 6)))) {
          final label = _formatWeekdayLabel(date);
          result[label] = (result[label] ?? 0) + 1;
        } else if (_selectedPeriod == '1m' &&
            date.isAfter(DateTime(now.year, now.month - 1))) {
          final label = 'Dia ${date.day}';
          result[label] = (result[label] ?? 0) + 1;
        } else if (_selectedPeriod == '1y' &&
            date.isAfter(DateTime(now.year - 1))) {
          final label = _monthName(date.month);
          result[label] = (result[label] ?? 0) + 1;
        }
      }
    }

    return result;
  }

  List<int?>? get chartData {
    final grouped = _groupServicesByDate();
    return chartLabels.map((label) => grouped[label] ?? 0).toList();
  }

  Icon? colorRanking(int index) {
    switch (index) {
      case 1:
        return Icon(
          Icons.emoji_events,
          color: Colors.amber,
        );
      case 2:
        return Icon(
          Icons.emoji_events,
          color: Colors.grey,
        );
      case 3:
        return Icon(
          Icons.emoji_events,
          color: Colors.brown,
        );
      default:
        return null;
    }
  }

  /// Label do gráfico
  List<String> get chartLabels {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case '1m':
        return List.generate(30, (i) => 'Dia ${i + 1}');
      case '1y':
        return [
          'Jan',
          'Fev',
          'Mar',
          'Abr',
          'Mai',
          'Jun',
          'Jul',
          'Ago',
          'Set',
          'Out',
          'Nov',
          'Dez'
        ];
      case '7d':
      default:
        final weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
        final today = now.weekday;
        return List.generate(7, (i) => weekDays[(today - 7 + i) % 7]);
    }
  }

  String _formatWeekdayLabel(DateTime date) {
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days[date.weekday - 1];
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return months[month - 1];
  }
}

/// TELA PRINCIPAL
class Home extends StatelessWidget {
  Home({this.isManager = false});

  bool? isManager;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeState()),
        ChangeNotifierProvider(create: (_) => ListServicesState()),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Oficina do Paulo"),
          backgroundColor: Colors.blue.shade700,
        ),
        drawer: const _Drawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              isManager == true ? _ItemsHome() : MechanicArea(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menus da home
class _ItemsHome extends StatelessWidget {
  const _ItemsHome();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeState>();
    final data = state.chartData;
    final labels = state.chartLabels;
    final period = state.selectedPeriod;

    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'Serviços iniciados',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('7 dias'),
                selected: period == '7d',
                onSelected: (_) => state.setSelectedPeriod('7d'),
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('1 mês'),
                selected: period == '1m',
                onSelected: (_) => state.setSelectedPeriod('1m'),
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('1 ano'),
                selected: period == '1y',
                onSelected: (_) => state.setSelectedPeriod('1y'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Echarts(
              option: '''
                {
                  tooltip: {
                   trigger: 'axis',
                   formatter: '{b}: {c} serviços'
                  },
                  xAxis: {
                    type: 'category',
                    data: ${labels.map((e) => '"$e"').toList()}
                  },
                  yAxis: {
                    type: 'value',
                    name: 'Quantidade'
                  },
                  series: [{
                    data: ${data ?? 0},
                    type: 'line',
                    areaStyle: {}
                  }]
                }
              ''',
            ),
          ),
        ),
        const SizedBox(height: 20),
        ItemHome(
          label: 'Serviços',
          icon: Icons.account_balance,
          subtitle: 'Gerenciar serviços',
          onPressed: () {
            context.push('/listService');
          },
        ),
        ItemHome(
          label: 'Clientes',
          icon: Icons.supervised_user_circle,
          subtitle: 'Gerenciar clientes',
          onPressed: () {
            context.push('/listCustomers');
          },
        ),
        ItemHome(
          label: 'Veículos',
          icon: Icons.directions_car,
          subtitle: 'Visualizar e gerenciar veículos',
          onPressed: () {
            context.push('/listVehicle');
          },
        ),
        ItemHome(
          label: 'Relatórios',
          icon: Icons.account_balance,
          subtitle: 'Visualizar e gerenciar relatórios',
          onPressed: () {
            context.push('');
          },
        ),
      ],
    );
  }
}

/// Util da estrutura dos menus
class ItemHome extends StatelessWidget {
  const ItemHome({
    required this.label,
    required this.subtitle,
    required this.onPressed,
    required this.icon,
    this.showFlagNewService,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final void Function() onPressed;
  final bool? showFlagNewService;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Stack(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.grey.withAlpha(50),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Icon(
                            icon,
                            size: 30,
                          ),
                        ],
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall!
                            .copyWith(color: theme.disabledColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (showFlagNewService ?? false) ...[
          Positioned(
            right: 37,
            top: 23,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: Colors.red),
              child: const Center(
                child: Text('2'),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Barra lateral
class _Drawer extends StatelessWidget {
  const _Drawer();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<LoginState>(context, listen: false).user;
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${user?.name ?? ''}',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('${user?.email ?? ''}',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Início"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Adicionar novo mecânico"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Configurações"),
            onTap: () {
              context.push("/settings");
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Sair"),
            onTap: () {
              context.go("/");
            },
          ),
        ],
      ),
    );
  }
}
