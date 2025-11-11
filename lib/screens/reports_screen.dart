import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/repart.dart';
import '../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  final ReportService _reportService = ReportService();
  late TabController _tabController;
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic>? _partsReport;
  Map<String, dynamic>? _servicesReport;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final partsReport = await _reportService.getPartsReportByMonth(
        _selectedDate.year,
        _selectedDate.month,
      );
      final servicesReport = await _reportService.getServicesReportByMonth(
        _selectedDate.year,
        _selectedDate.month,
      );

      setState(() {
        _partsReport = partsReport;
        _servicesReport = servicesReport;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Peças', icon: Icon(Icons.build)),
            Tab(text: 'Serviços', icon: Icon(Icons.build_circle)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Selecionar Mês',
          ),
        ],
      ),
      body: Column(
        children: [
          // Seletor de Data
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMMM/yyyy', 'pt_BR').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadReports,
                  tooltip: 'Atualizar',
                ),
              ],
            ),
          ),

          // Conteúdo das Abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPartsReport(),
                _buildServicesReport(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsReport() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar relatório',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            ElevatedButton(
              onPressed: _loadReports,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_partsReport == null) {
      return const Center(child: Text('Nenhum dado disponível'));
    }

    // Dados mockados para demonstração (substitua com dados reais da API)
    final totalPurchased = _partsReport!['totalPurchased'] ?? 0.0;
    final totalSold = _partsReport!['totalSold'] ?? 0.0;
    final profit = totalSold - totalPurchased;
    final partsList = _partsReport!['parts'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo do Mês',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    label: 'Total Comprado',
                    value: 'R\$ ${totalPurchased.toStringAsFixed(2)}',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Total Vendido',
                    value: 'R\$ ${totalSold.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Lucro',
                    value: 'R\$ ${profit.toStringAsFixed(2)}',
                    color: profit >= 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gráfico
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gráfico de Compra vs Venda',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (totalPurchased > totalSold ? totalPurchased : totalSold) * 1.2,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() == 0) return const Text('Comprado');
                                if (value.toInt() == 1) return const Text('Vendido');
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text('R\$ ${value.toInt()}') ;
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: totalPurchased,
                                color: Colors.blue,
                                width: 40,
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: totalSold,
                                color: Colors.green,
                                width: 40,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de Peças
          if (partsList.isNotEmpty) ...[
            Text(
              'Peças Mais Vendidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...partsList.take(10).map((part) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(part['name'] ?? ''),
                    subtitle: Text('Código: ${part['code'] ?? ''}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${part['quantity'] ?? 0}x',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'R\$ ${(part['total'] ?? 0.0).toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesReport() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar relatório',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            ElevatedButton(
              onPressed: _loadReports,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_servicesReport == null) {
      return const Center(child: Text('Nenhum dado disponível'));
    }

    // Dados mockados para demonstração (substitua com dados reais da API)
    final totalServices = _servicesReport!['totalServices'] ?? 0;
    final totalRevenue = _servicesReport!['totalRevenue'] ?? 0.0;
    final servicesByStatus = _servicesReport!['servicesByStatus'] as Map? ?? {};
    final servicesList = _servicesReport!['services'] as List? ?? [];

    final pending = servicesByStatus['pending'] ?? 0;
    final inProgress = servicesByStatus['inProgress'] ?? 0;
    final finished = servicesByStatus['finished'] ?? 0;
    final washing = servicesByStatus['washing'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo do Mês',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    label: 'Total de Serviços',
                    value: totalServices.toString(),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Receita Total',
                    value: 'R\$ ${totalRevenue.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gráfico de Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Serviços por Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          if (pending > 0)
                            PieChartSectionData(
                              value: pending.toDouble(),
                              title: 'Pendente\n$pending',
                              color: Colors.orange,
                              radius: 80,
                            ),
                          if (inProgress > 0)
                            PieChartSectionData(
                              value: inProgress.toDouble(),
                              title: 'Em Andamento\n$inProgress',
                              color: Colors.blue,
                              radius: 80,
                            ),
                          if (finished > 0)
                            PieChartSectionData(
                              value: finished.toDouble(),
                              title: 'Finalizado\n$finished',
                              color: Colors.green,
                              radius: 80,
                            ),
                          if (washing > 0)
                            PieChartSectionData(
                              value: washing.toDouble(),
                              title: 'Lavagem\n$washing',
                              color: Colors.cyan,
                              radius: 80,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de Serviços
          if (servicesList.isNotEmpty) ...[
            Text(
              'Serviços Realizados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...servicesList.take(20).map((service) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('Serviço #${service['id'] ?? ''}'),
                    subtitle: Text('Cliente: ${service['clientName'] ?? ''}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          service['status'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(service['status']),
                          ),
                        ),
                        Text(
                          'R\$ ${(service['totalCost'] ?? 0.0).toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'inProgress':
        return Colors.blue;
      case 'finished':
        return Colors.green;
      case 'washing':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}




