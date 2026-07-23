import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/models/exam_result.dart';
import 'package:intl/intl.dart';

class ReportCardService {
  static const PdfColor primaryBlue = PdfColor.fromInt(0xFF1565C0);
  static const PdfColor secondaryOrange = PdfColor.fromInt(0xFFFB8C00);
  static const PdfColor dividerGrey = PdfColor.fromInt(0xFFE0E0E0);

  static Future<void> generateAndPrintReportCard({
    required Student student,
    required List<ExamResult> results,
    required String instituteName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(instituteName, 'STUDENT PROGRESS REPORT'),
              pw.SizedBox(height: 24),
              _buildStudentInfo(student),
              pw.SizedBox(height: 32),
              _buildResultsTable(results),
              pw.SizedBox(height: 32),
              _buildSummary(results),
              pw.Spacer(),
              _buildSignatures(),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'This is a computer-generated document and does not require a physical stamp unless specified.',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildHeader(String instituteName, String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primaryBlue, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                instituteName.toUpperCase(),
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: primaryBlue),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Empowering Educators, Inspiring Minds',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: secondaryOrange),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStudentInfo(Student student) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Student Name', student.name),
                _buildInfoRow('Class', student.className),
                _buildInfoRow('Roll Number', student.rollNo),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Student ID', student.studentId),
                _buildInfoRow('Academic Year', '2026-27'),
                _buildInfoRow('Report Date', DateFormat('dd MMM yyyy').format(DateTime.now())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.TextSpan(text: value, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildResultsTable(List<ExamResult> results) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5), // Black border for B&W printing
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200), // Grey for B&W compatibility
          children: [
            _buildTableHeader('Subject'),
            _buildTableHeader('Max'),
            _buildTableHeader('Obtained'),
            _buildTableHeader('Grade'),
            _buildTableHeader('Remarks'),
          ],
        ),
        ...results.map((r) => pw.TableRow(
          children: [
            _buildTableCell(r.subject, align: pw.Alignment.centerLeft),
            _buildTableCell(r.totalMarks.toString()),
            _buildTableCell(r.marksObtained.toString()),
            _buildTableCell(r.grade, isBold: true),
            _buildTableCell(r.remarks, align: pw.Alignment.centerLeft),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(color: PdfColors.black, fontWeight: pw.FontWeight.bold, fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {pw.Alignment align = pw.Alignment.center, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Align(
        alignment: align,
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
        ),
      ),
    );
  }

  static pw.Widget _buildSummary(List<ExamResult> results) {
    final percentage = calculateOverallPercentage(results);
    final grade = calculateOverallGrade(results);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 200,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: primaryBlue),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              _buildSummaryRow('Overall Marks', '${_calculateTotalObtained(results)} / ${_calculateTotalMax(results)}'),
              pw.Divider(color: dividerGrey),
              _buildSummaryRow('Percentage', '${percentage.toStringAsFixed(1)}%'),
              pw.Divider(color: dividerGrey),
              _buildSummaryRow('Final Grade', grade, isGrade: true),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value, {bool isGrade = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isGrade ? 14 : 10,
            fontWeight: pw.FontWeight.bold,
            color: isGrade ? secondaryOrange : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSignatures() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildSignatureLine('Parent Signature'),
        _buildSignatureLine('Class Teacher'),
        _buildSignatureLine('Principal'),
      ],
    );
  }

  static pw.Widget _buildSignatureLine(String label) {
    return pw.Column(
      children: [
        pw.Container(
          width: 120,
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 0.5)),
          ),
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center),
        ),
      ],
    );
  }

  static double calculateOverallPercentage(List<ExamResult> results) {
    if (results.isEmpty) return 0.0;
    return (_calculateTotalObtained(results) / _calculateTotalMax(results)) * 100;
  }

  static double _calculateTotalObtained(List<ExamResult> results) {
    return results.fold(0, (sum, r) => sum + r.marksObtained);
  }

  static int _calculateTotalMax(List<ExamResult> results) {
    return results.fold(0, (sum, r) => sum + r.totalMarks);
  }

  static String calculateOverallGrade(List<ExamResult> results) {
    double percentage = calculateOverallPercentage(results);
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    if (percentage >= 35) return 'E';
    return 'F';
  }

  static Future<void> generateAndPrintMeritList({
    required String examTitle,
    required String className,
    required List<ExamResult> results,
    required String instituteName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(instituteName, 'EXAMINATION MERIT LIST'),
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 16),
            pw.Text(
              'Exam: $examTitle | Class: $className',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 24),
            pw.Table(
              border: pw.TableBorder.all(color: dividerGrey, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: primaryBlue),
                  children: [
                    _buildTableHeader('Rank'),
                    _buildTableHeader('Student Name'),
                    _buildTableHeader('Marks'),
                    _buildTableHeader('Grade'),
                  ],
                ),
                ...results.asMap().entries.map((entry) {
                  final index = entry.key;
                  final r = entry.value;
                  final isTop3 = index < 3;
                  return pw.TableRow(
                    decoration: isTop3 ? pw.BoxDecoration(color: PdfColors.yellow100) : null,
                    children: [
                      _buildTableCell((index + 1).toString(), isBold: isTop3),
                      _buildTableCell(r.studentName, align: pw.Alignment.centerLeft, isBold: isTop3),
                      _buildTableCell('${r.marksObtained}/${r.totalMarks}', isBold: isTop3),
                      _buildTableCell(r.grade, isBold: isTop3),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Generated on: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
