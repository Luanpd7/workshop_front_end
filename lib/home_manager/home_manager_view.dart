import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:workshop_front_end/customer/view.dart';
import '../home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/list_service.dart';

/// Menus da home
class HomeManager extends StatelessWidget {
  const HomeManager();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeState>();
    final data = state.chartData;
    final labels = state.chartLabels;
    final period = state.selectedPeriod;
var index = 0;

if(state.loading){
  return Padding(
    padding: const EdgeInsets.only(top: 350),
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );

}else {
  return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'Serviços finalizados',
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
                    data: ${data},
                    type: 'line',
                    areaStyle: {}
                  }]
                }
              ''',
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'Ranking do mecânicos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: state.rankingUsers.map(
              (user) {
               index++;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white)),
                    child: ListTile(
                      leading:
                          SizedBox(
                            height: 30,
                            width: 50,
                            child: Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('${index.toString()}°', style: TextStyle(fontSize: 14),),
                         state.colorRanking(index)!,
                              ],
                            ),
                          ),
                      title: Text(user.name ?? 'Desconhecido'),
                      trailing: Text('${user.serviceLength} serviços'),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'Todos os pedidos finalizados',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 25),
        ChangeNotifierProvider<ListServicesState>(
            create: (_) => ListServicesState(),
        child: SizedBox(
            height: 500,
            child: ListViewItems(selectedService: false,)),
        ),
      ],
    );
}
  }
}
