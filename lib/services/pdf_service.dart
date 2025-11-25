import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/service.dart';
import '../models/client.dart';
import '../models/vehicle.dart';
import '../util/format_number.dart';

class PdfService {
  static Future<void> generateServiceReceipt({
    required Service service,
    required Client client,
    required Vehicle vehicle,
  }) async {
    final pdf = pw.Document();

    // Carregar imagens antes e depois
    List<pw.MemoryImage> beforeImages = [];
    List<pw.MemoryImage> afterImages = [];




    for (var imagePath in service.beforeImages) {
      try {
        if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
          // Se for URL, você precisaria baixar a imagem
          // Por enquanto, vamos pular URLs
          continue;
        }
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          beforeImages.add(pw.MemoryImage(bytes));
        }
      } catch (e) {
        print('Erro ao carregar imagem antes: $e');
      }
    }

    for (var imagePath in service.afterImages) {
      try {
        if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
          // Se for URL, você precisaria baixar a imagem
          continue;
        }
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          afterImages.add(pw.MemoryImage(bytes));
        }
      } catch (e) {
        print('Erro ao carregar imagem depois: $e');
      }
    }

    // Calcular valores para o gráfico
     final partsTotal = service.partsTotal;
    final laborCost = service.laborCost;
     final totalCost = partsTotal + laborCost;



    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Cabeçalho
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'COMPROVANTE DE SERVIÇO',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Serviço #${service.id}',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Informações do Cliente e Veículo
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Cliente',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(client.name),
                    if (client.phone.isNotEmpty) pw.Text(client.phone),
                    if (client.email != null && client.email!.isNotEmpty)
                      pw.Text(client.email!),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Veículo',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(vehicle.displayName),
                    if (vehicle.plate != null) pw.Text('Placa: ${vehicle.plate}'),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Informações do Serviço
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Informações do Serviço',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Mecânico: ${service.mechanicName}'),
                    pw.Text('Status: ${service.statusDisplay}'),
                  ],
                ),
                if (service.startDate != null)
                  pw.Text('Data de Início: ${_formatDate(service.startDate!)}'),
                if (service.endDate != null)
                  pw.Text('Data de Término: ${_formatDate(service.endDate!)}'),
                if (service.laborHours > 0)
                  pw.Text('Horas Trabalhadas: ${service.laborHours.toStringAsFixed(2)}h'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Fotos Antes e Depois
          if (beforeImages.isNotEmpty || afterImages.isNotEmpty) ...[
            pw.Text(
              'Fotos do Veículo',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (beforeImages.isNotEmpty)
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'ANTES',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red700,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        ...beforeImages.take(2).map((img) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Image(img, fit: pw.BoxFit.cover, width: 200, height: 150),
                            )),
                      ],
                    ),
                  ),
                if (beforeImages.isNotEmpty && afterImages.isNotEmpty)
                  pw.SizedBox(width: 20),
                if (afterImages.isNotEmpty)
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'DEPOIS',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        ...afterImages.take(2).map((img) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Image(img, fit: pw.BoxFit.cover, width: 200, height: 150),
                            )),
                      ],
                    ),
                  ),
              ],
            ),
            pw.SizedBox(height: 30),
          ],

          // Peças
          if (service.parts.isNotEmpty) ...[
            pw.Text(
              'Peças Utilizadas',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Código', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Nome', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Qtd', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Preço Unit.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ...service.parts.map((part) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(part.code),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(part.name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(part.quantity.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('R\$ ${formatNumberBR(part.price)}'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('R\$ ${formatNumberBR(part.total)}'),
                        ),
                      ],
                    )),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // Resumo Financeiro
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total de Peças:'),
                    pw.Text('R\$ ${formatNumberBR(partsTotal)}'),
                  ],
                ),
                if (laborCost > 0) ...[
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Mão de Obra:'),
                      pw.Text('R\$ ${formatNumberBR(laborCost)}'),
                    ],
                  ),
                ],
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL GERAL:',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'R\$ ${formatNumberBR(totalCost)}',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Gráfico de Custos (simulado com tabela)
          if (partsTotal > 0 || laborCost > 0) ...[
            pw.Text(
              'Divisão de Custos',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              height: 200,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
    // TODO
                  // PEÇAS
                  if (partsTotal > 0)
                    pw.Expanded(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            height: (partsTotal / totalCost * 180).clamp(10.0, 180.0),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue400,
                              borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '${((partsTotal / totalCost) * 100).toStringAsFixed(1)}%',
                                style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Peças\nR\$ ${formatNumberBR(partsTotal)}',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),

                  // MÃO DE OBRA
                  if (laborCost > 0)
                    pw.Expanded(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            height: (laborCost / totalCost * 180).clamp(10.0, 180.0),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green400,
                              borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '${((laborCost / totalCost) * 100).toStringAsFixed(1)}%',
                                style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Mão de Obra\nR\$ ${formatNumberBR(laborCost)}',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),

                ],
              ),),
            pw.SizedBox(height: 20),
          ],

          // Observações
          if (service.notes.isNotEmpty) ...[
            pw.Text(
              'Observações',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            ...service.notes.map((note) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          note.observation,
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          _formatDate(note.dateTime),
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );

    // Imprimir ou compartilhar PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

