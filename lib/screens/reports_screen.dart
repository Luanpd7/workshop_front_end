import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/report_service.dart';
import '../util/format_number.dart';

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
        title: const Text('Reports'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Parts', icon: Icon(Icons.build)),
            Tab(text: 'Services', icon: Icon(Icons.build_circle)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Select Month',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMMM/yyyy').format(_selectedDate),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadReports,
                  tooltip: 'Reload',
                ),
              ],
            ),
          ),

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
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_partsReport == null) {
      return const Center(child: Text('No data available'));
    }

    final summary = (_partsReport!['summary'] as Map?)?.cast<String, dynamic>();
    final breakdown = (_partsReport!['costBreakdown'] as Map?)?.cast<String, dynamic>();

    final totalPurchased = _parseDouble(summary?['totalPurchased'] ?? _partsReport!['totalPurchased']);
    final totalSold = _parseDouble(summary?['totalSold'] ?? _partsReport!['totalSold']);
    final profit = _parseDouble(summary?['totalProfit'], totalSold - totalPurchased);
    final laborCost = _parseDouble(summary?['laborCost'] ?? breakdown?['labor']);
    final totalPartsQty = _parseInt(summary?['totalPartsQuantity'] ?? _partsReport!['totalPartsQuantity']);
    final totalServices = _parseInt(summary?['totalServices'] ?? _partsReport!['totalServices']);
    final partsList = (_partsReport!['parts'] as List? ?? [])
        .whereType<Map>()
        .map((p) => p.cast<String, dynamic>())
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SUMMARY CARD
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _SummaryRow(label: 'Total Purchased', value: 'R\$ ${formatNumberBR(totalPurchased)}', color: Colors.blue),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Total Sold', value: 'R\$ ${formatNumberBR(totalSold)}', color: Colors.green),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Profit', value: 'R\$ ${formatNumberBR(profit)}', color: profit >= 0 ? Colors.green : Colors.red),

                  if (laborCost > 0) ...[
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Labor Cost', value: 'R\$ ${formatNumberBR(laborCost)}', color: Colors.indigo),
                  ],
                  if (totalPartsQty > 0) ...[
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Parts Quantity', value: '$totalPartsQty', color: Colors.deepPurple),
                  ],
                  if (totalServices > 0) ...[
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Services with Parts', value: '$totalServices', color: Colors.orange),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // BAR CHART
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Purchase vs Sales Chart',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                                if (value.toInt() == 0) return const Text('Purchased');
                                if (value.toInt() == 1) return const Text('Sold');
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 60,
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text('R\$ ${formatNumberBR(value.toInt())}', style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [BarChartRodData(toY: totalPurchased, color: Colors.blue, width: 40)],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [BarChartRodData(toY: totalSold, color: Colors.green, width: 40)],
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

          // BEST SELLING PARTS
          if (partsList.isNotEmpty) ...[
            Text(
              'Best Selling Parts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...partsList.take(10).map((p) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(p['name'] ?? ''),
                subtitle: Text('Code: ${p['code'] ?? ''}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${p['quantity'] ?? 0}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('R\$ ${formatNumberBR(_parseDouble(p['total']))}',
                        style: TextStyle(color: Colors.green[700])),
                  ],
                ),
              ),
            )),
          ]
        ],
      ),
    );
  }


  Widget _buildServicesReport() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildErrorWidget();
    if (_servicesReport == null) return const Center(child: Text('No data available'));

    final summary = (_servicesReport!['summary'] as Map?)?.cast<String, dynamic>();

    final totalServices = _parseInt(summary?['totalServices'] ?? _servicesReport!['totalServices']);
    final totalRevenue = _parseDouble(summary?['totalRevenue'] ?? _servicesReport!['totalRevenue']);
    final avgTicket = _parseDouble(summary?['averageTicket'] ?? _servicesReport!['averageTicket']);

    final statusStatsRaw = (_servicesReport!['servicesByStatus'] as List? ?? [])
        .whereType<Map>()
        .map((m) => m.cast<String, dynamic>())
        .toList();

    final Map<String, int> statusCounts = {};
    final Map<String, double> statusRevenue = {};

    for (final s in statusStatsRaw) {
      final status = s['status']?.toString() ?? 'unknown';
      statusCounts[status] = _parseInt(s['count']);
      statusRevenue[status] = _parseDouble(s['revenue']);
    }

    final servicesList = (_servicesReport!['services'] as List? ?? [])
        .whereType<Map>()
        .map((s) => s.cast<String, dynamic>())
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SUMMARY
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _SummaryRow(label: 'Total Services', value: totalServices.toString(), color: Colors.blue),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Total Revenue', value: 'R\$ ${formatNumberBR(totalRevenue)}', color: Colors.green),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Average Ticket', value: 'R\$ ${formatNumberBR(avgTicket)}', color: Colors.indigo),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // PIE CHART
          if (statusCounts.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Services by Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: statusCounts.entries
                              .where((e) => e.value > 0)
                              .map((e) {
                            final status = e.key;
                            final count = e.value;
                            return PieChartSectionData(
                              value: count.toDouble(),
                              title: '${_getStatusLabel(status)}\n$count',
                              color: _getStatusColor(status),
                              radius: 80,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...statusStatsRaw.map((s) {
                      final status = s['status']?.toString() ?? 'unknown';
                      final count = _parseInt(s['count']);
                      final revenue = _parseDouble(s['revenue']);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(status),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(_getStatusLabel(status)),
                        subtitle: Text('Revenue: R\$ ${formatNumberBR(revenue)}'),
                      );
                    }),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // SERVICES LIST
          if (servicesList.isNotEmpty) ...[
            Text('Completed Services',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            ...servicesList.take(20).map((service) {
              final status = service['status']?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Stack(
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Service #${service['id'] ?? ''}'),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Client: ${service['clientName'] ?? ''}'),
                          if ((service['vehicleBrand'] ?? '').toString().isNotEmpty ||
                              (service['vehicleModel'] ?? '').toString().isNotEmpty)
                            Text(
                              'Vehicle: ${service['vehicleBrand'] ?? ''} ${service['vehicleModel'] ?? ''}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          if ((service['vehiclePlate'] ?? '').toString().isNotEmpty)
                            Text('Plate: ${service['vehiclePlate']}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          if ((service['startDate'] ?? '').toString().isNotEmpty ||
                              (service['endDate'] ?? '').toString().isNotEmpty)
                            Text(
                              'Period: ${_formatDate(service['startDate'])} - ${_formatDate(service['endDate'])}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                        ],
                      ),

                      trailing: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 140, maxWidth: 180),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total: R\$ ${formatNumberBR(_parseDouble(service['totalCost']))}',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                            if (_parseDouble(service['partsCost']) > 0)
                              Text(
                                'Parts: R\$ ${formatNumberBR(_parseDouble(service['partsCost']))}',
                                style: TextStyle(color: Colors.blueGrey[600], fontSize: 12),
                              ),
                            if (_parseDouble(service['laborCost']) > 0)
                              Text(
                                'Labor: R\$ ${formatNumberBR(_parseDouble(service['laborCost']))}',
                                style: TextStyle(color: Colors.blueGrey[600], fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      top: 5,
                      right: 10,
                      child: Text(
                        _getStatusLabel(status),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }


  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error loading report', style: Theme.of(context).textTheme.headlineSmall),
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
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  double _parseDouble(dynamic value, [double fallback = 0.0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) return fallback;
      return double.tryParse(normalized.replaceAll(',', '.')) ?? fallback;
    }
    return fallback;
  }

  int _parseInt(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) return fallback;
      return int.tryParse(normalized) ?? fallback;
    }
    return fallback;
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'inProgress':
        return 'In Progress';
      case 'finished':
        return 'Finished';
      case 'washing':
        return 'Washing/Polishing';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '--';
    if (value is DateTime) return DateFormat('dd/MM/yyyy').format(value);
    if (value is String && value.isNotEmpty) {
      try {
        return DateFormat('dd/MM/yyyy').format(DateTime.parse(value));
      } catch (_) {
        return value;
      }
    }
    return '--';
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
        return Colors.purple;
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
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
