import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/models/exam_result.dart';
import 'package:intl/intl.dart';

class ReportCardService {
  static Future<void> generateAndPrintReportCard({
    required Student student,
    required List<ExamResult> results,
    required String instituteName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(instituteName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('STUDENT PROGRESS REPORT', style: pw.TextStyle(fontSize: 18)),
                    pw.SizedBox(height: 20),
                  ],
                ),
              ),
              
              // Student Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Student Name: ${student.name}'),
                      pw.Text('Class: ${student.className}'),
                      pw.Text('Roll No: ${student.rollNo}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Student ID: ${student.studentId}'),
                      pw.Text('Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Results Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Subject', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Max Marks', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Obtained', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Grade', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Remarks', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...results.map((result) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(result.subject)),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(result.totalMarks.toString())),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(result.marksObtained.toString())),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(result.grade)),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(result.remarks)),
                    ],
                  )),
                ],
              ),

              pw.SizedBox(height: 40),
              
              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total Percentage: ${calculateOverallPercentage(results).toStringAsFixed(2)}%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Final Grade: ${calculateOverallGrade(results)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),
              
              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(children: [pw.SizedBox(width: 100, child: pw.Divider()), pw.Text('Parent Signature')]),
                  pw.Column(children: [pw.SizedBox(width: 100, child: pw.Divider()), pw.Text('Class Teacher')]),
                  pw.Column(children: [pw.SizedBox(width: 100, child: pw.Divider()), pw.Text('Principal')]),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> generateAndPrintMeritList({
    required String examTitle,
    required String className,
    required List<ExamResult> results,
    required String instituteName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(instituteName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('EXAMINATION MERIT LIST', style: pw.TextStyle(fontSize: 18)),
                    pw.Text('$examTitle - $className', style: const pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 20),
                  ],
                ),
              ),
              
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Rank', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Student Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Marks', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Grade', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...results.asMap().entries.map((entry) {
                    final index = entry.key;
                    final result = entry.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text((index + 1).toString())),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(result.studentName)),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${result.marksObtained}/${result.totalMarks}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(result.grade)),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('Generated on: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static double calculateOverallPercentage(List<ExamResult> results) {
    if (results.isEmpty) return 0.0;
    double totalObtained = 0;
    int totalMax = 0;
    for (var r in results) {
      totalObtained += r.marksObtained;
      totalMax += r.totalMarks;
    }
    return (totalObtained / totalMax) * 100;
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
}
