import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/daily_report.dart';

class PdfService {
  static Future<void> exportDailyReport(DailyReport report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('DCI Teachers - Daily Report',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              _buildRow('Class:', report.className),
              _buildRow('Subject:', report.subject),
              _buildRow('Teacher:', report.teacher),
              _buildRow('Date:', report.createdAt?.toString() ?? 'N/A'),
              pw.Divider(),
              pw.Text('Content Covered', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              _buildRow('Chapter:', report.chapter),
              _buildRow('Topics:', report.topics),
              pw.SizedBox(height: 10),
              pw.Text('Attendance Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              _buildRow('Present:', report.presentCount.toString()),
              _buildRow('Absent:', report.absentCount.toString()),
              pw.SizedBox(height: 10),
              pw.Text('Additional Info', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              _buildRow('Homework:', report.homeworkAssigned),
              _buildRow('Remarks:', report.remarks),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
