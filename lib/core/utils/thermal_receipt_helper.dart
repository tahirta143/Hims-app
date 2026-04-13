import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ThermalReceiptHelper {
  static Future<Uint8List> generateReceipt({
    required String hospitalName,
    required String receiptId,
    required String mrNumber,
    required String patientName,
    required String age,
    required String gender,
    required String date,
    required String time,
    required List<Map<String, dynamic>> items,
    required double total,
    required double discount,
    required double payable,
    required String cashier,
    String? qrData,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          72 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      hospitalName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'OPD RECEIPT',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 1, color: PdfColors.black),
              
              // MR and Receipt ID
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('MR: $mrNumber',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text(receiptId, style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.SizedBox(height: 2),
              // Patient Name
              pw.Text(patientName,
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              // Age/Gender and Date/Time
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('$age Y / $gender', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('$date $time', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 0.5, color: PdfColors.black),

              // Items Header
              pw.Row(
                children: [
                  pw.Expanded(
                      flex: 3,
                      child: pw.Text('Service',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text('Qty',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(
                      flex: 1,
                      child: pw.Text('Rate',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold))),
                ],
              ),
              pw.SizedBox(height: 2),
              
              // Items List
              ...items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                            flex: 3,
                            child: pw.Text(item['name'] ?? '',
                                style: const pw.TextStyle(fontSize: 9))),
                        pw.Expanded(
                            flex: 1,
                            child: pw.Text('${item['qty'] ?? 1}',
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(fontSize: 9))),
                        pw.Expanded(
                            flex: 1,
                            child: pw.Text('${(item['rate'] ?? 0).toInt()}',
                                textAlign: pw.TextAlign.right,
                                style: const pw.TextStyle(fontSize: 9))),
                      ],
                    ),
                  )),
              
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 0.5, color: PdfColors.black),

              // Totals
              if (discount > 0) ...[
                _buildTotalRow('Subtotal', total),
                _buildTotalRow('Discount', discount, isNegative: true),
              ],
              _buildTotalRow('Grand Total', payable, isBold: true),
              
              pw.SizedBox(height: 5),
              // Amount in words
              pw.Text(
                'Amount in words: ${numberToWordsPKR(payable.toInt())} Rupees Only',
                style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
              ),
              
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 0.5, color: PdfColors.black),
              pw.SizedBox(height: 2),
              pw.Text('Cashier: $cashier', style: const pw.TextStyle(fontSize: 9)),
              
              if (qrData != null) ...[
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Container(
                        width: 100,
                        height: 100,
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrData,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('Scan to verify receipt',
                          style: const pw.TextStyle(fontSize: 7)),
                    ],
                  ),
                ),
              ],
              
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Thank you for visiting',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTotalRow(String label, double value,
      {bool isBold = false, bool isNegative = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(
            '${isNegative ? "- " : ""}PKR ${value.toInt()}',
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  static String numberToWordsPKR(int n) {
    if (n == 0) return 'Zero';
    
    final units = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    
    String convert(int n) {
      if (n < 20) return units[n];
      if (n < 100) return tens[n ~/ 10] + (n % 10 != 0 ? ' ' + units[n % 10] : '');
      if (n < 1000) return units[n ~/ 100] + ' Hundred' + (n % 100 != 0 ? ' ' + convert(n % 100) : '');
      if (n < 100000) return convert(n ~/ 1000) + ' Thousand' + (n % 1000 != 0 ? ' ' + convert(n % 1000) : '');
      if (n < 10000000) return convert(n ~/ 100000) + ' Lakh' + (n % 100000 != 0 ? ' ' + convert(n % 100000) : '');
      return convert(n ~/ 10000000) + ' Crore' + (n % 10000000 != 0 ? ' ' + convert(n % 10000000) : '');
    }
    
    return convert(n);
  }
}
