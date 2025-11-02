
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import 'entities/service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ButtonPdf extends StatelessWidget {
  ButtonPdf(this.serviceDetails);
  final ServiceDetails serviceDetails;

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Detalhes do Serviço  #${serviceDetails.serviceId}",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text("Dados do cliente",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),


              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Nome: ${serviceDetails.customerName}"),
                  pw.Text("Documento: ${serviceDetails.customerDocument}"),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("E-mail: ${serviceDetails.customerEmail}"),
                  pw.Text("Whatsapp: ${serviceDetails.customerWhatsapp}"),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Text("Observação: ${serviceDetails.customerObservation}"),
              pw.SizedBox(height: 16),

              pw.Text("Dados do veículo",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),


              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Modelo: ${serviceDetails.vehicleModel}"),
                  pw.Text("Cor: ${serviceDetails.vehicleColor}"),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Placa: ${serviceDetails.vehiclePlate}"),
                  pw.Text("Ano: ${serviceDetails.manufactureYear}"),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Text("Tipo de veículo: ${serviceDetails.vehicleTypeName}"),
              pw.SizedBox(height: 16),


              pw.Text("Dados do mecânico",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Nome: ${serviceDetails.mechanicName}"),
                  pw.Text("E-mail: ${serviceDetails.mechanicEmail}"),
                ],
              ),
              pw.SizedBox(height: 16),

              pw.Text("Dados do serviço",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Data de entrada: ${DateFormat('dd/MM/yyyy').format(serviceDetails!.entryDate!)}"),
                  pw.Text("Data de saída: ${DateFormat('dd/MM/yyyy').format(serviceDetails.exitDate!)}"),
                ],
              ),

              // if (serviceDetails.purchaseItems.isNotEmpty) ...[
              //   pw.SizedBox(height: 16),
              //   pw.Text(
              //     "Itens da Compra",
              //     style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              //   ),
              //   pw.SizedBox(height: 10),
              //   pw.Table.fromTextArray(
              //     headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              //     headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              //     cellAlignment: pw.Alignment.centerLeft,
              //     headers: ['Peça', 'Marca', 'Quantidade', 'Preço Unit.', 'Total'],
              //     data: serviceDetails.purchaseItems.map((item) {
              //       final precoUnit = item.unitPrice?.toStringAsFixed(2);
              //       final total = (item.unitPrice! * item.quantity!.toDouble()).toStringAsFixed(2);
              //       return [
              //         item.part,
              //         item.brand,
              //         item.quantity.toString(),
              //         "R\$ $precoUnit",
              //         "R\$ $total",
              //       ];
              //     }).toList(),
              //   ),
              //   pw.SizedBox(height: 16),
              // ],
              // if (serviceDetails.observations.isNotEmpty) ...[
              //   pw.SizedBox(height: 16),
              //   pw.Text(
              //     "Observações do serviço",
              //     style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              //   ),
              //   pw.SizedBox(height: 10),
              //   pw.Table.fromTextArray(
              //     headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              //     headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              //     cellAlignment: pw.Alignment.centerLeft,
              //     headers: ['Descrição', 'Data'],
              //     data: serviceDetails.observations.map((item) {
              //       return [
              //         item.description,
              //         DateFormat('dd/MM/yyyy  HH:mm')
              //             .format(item.date!)
              //
              //       ];
              //     }).toList(),
              //   ),
              //   pw.SizedBox(height: 16),
              // ],

              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Valor final:  R\$ ${serviceDetails.sumValue?.toStringAsFixed(2)}"),
                ],
              ),
              pw.SizedBox(height: 16),
            ],
          );
        },
      ),
    );

    // pdf.addPage(
    //   pw.Page(
    //     build: (pw.Context context) {
    //       return pw.Column(
    //         crossAxisAlignment: pw.CrossAxisAlignment.center,
    //         children: [
    //           if (serviceDetails.imageBytes != null && serviceDetails.imageBytes!.isNotEmpty) ...[
    //             pw.Text("Antes", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
    //             pw.SizedBox(height: 10),
    //             pw.Image(
    //               pw.MemoryImage(serviceDetails!),
    //               width: 400,
    //               height: 300,
    //               fit: pw.BoxFit.cover,
    //             ),
    //             pw.SizedBox(height: 20),
    //           ],
    //           if (serviceDetails.exitImageBytes != null && serviceDetails.exitImageBytes!.isNotEmpty) ...[
    //             pw.Text("Depois", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
    //             pw.SizedBox(height: 10),
    //             pw.Image(
    //               pw.MemoryImage(serviceDetails.exitImageBytes!),
    //               width: 400,
    //               height: 300,
    //               fit: pw.BoxFit.cover,
    //             ),
    //           ],
    //         ],
    //       );
    //     },
    //   ),
    // );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () async {
        await _generatePdf(context);
      },
      child: SizedBox(
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade700, width: 1),
          ),
          child: const Center(
            child: Text(
              'Gerar PDF',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}