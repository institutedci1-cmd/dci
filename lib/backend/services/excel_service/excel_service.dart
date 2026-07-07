import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import '../../models/student.dart';
import '../../models/daily_report.dart';

class ExcelService {
  static Future<bool> exportStudents(List<Student> students) async {
    if (students.isEmpty) return false;
    
    final excel = Excel.createExcel();
    final sheet = excel['Students'];
    
    // In some versions, Sheet1 is created by default. 
    // We try to remove it after creating our own.
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Student ID'),
      TextCellValue('Class'),
      TextCellValue('Parent Phone'),
    ]);

    for (final student in students) {
      sheet.appendRow([
        TextCellValue(student.name),
        TextCellValue(student.studentId),
        TextCellValue(student.className),
        TextCellValue(student.parentPhone ?? ''),
      ]);
    }

    return await _saveAndShare(excel, 'Students_List.xlsx');
  }

  static Future<bool> exportDailyReports(List<DailyReport> reports) async {
    if (reports.isEmpty) return false;

    final excel = Excel.createExcel();
    final sheet = excel['Daily Reports'];
    
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Class'),
      TextCellValue('Subject'),
      TextCellValue('Teacher'),
      TextCellValue('Chapter'),
      TextCellValue('Topics'),
      TextCellValue('Present'),
      TextCellValue('Absent'),
    ]);

    for (final report in reports) {
      sheet.appendRow([
        TextCellValue(report.createdAt?.toString() ?? ''),
        TextCellValue(report.className),
        TextCellValue(report.subject),
        TextCellValue(report.teacher),
        TextCellValue(report.chapter),
        TextCellValue(report.topics),
        IntCellValue(report.presentCount),
        IntCellValue(report.absentCount),
      ]);
    }

    return await _saveAndShare(excel, 'Daily_Reports.xlsx');
  }

  static Future<List<Map<String, String>>> importStudents() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return [];

      Uint8List? bytes;
      if (kIsWeb) {
        bytes = result.files.first.bytes;
      } else {
        final path = result.files.first.path;
        if (path != null) {
          bytes = await File(path).readAsBytes();
        }
      }

      if (bytes == null) {
        print('Excel Import: Bytes are null');
        return [];
      }
      print('Excel Import: Read ${bytes.length} bytes');

      final excel = Excel.decodeBytes(bytes);
      final List<Map<String, String>> studentsData = [];

      print('Excel Import: Tables found: ${excel.tables.keys.join(', ')}');

      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        print('Excel Import: Processing sheet $table, rows: ${sheet.maxRows}');

        for (int i = 0; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          // Skip header row if it contains "Name" or "Student ID"
          if (i == 0) {
            final firstCell = (row[0]?.value?.toString() ?? '').toLowerCase();
            if (firstCell.contains('name') || firstCell.contains('student')) {
              print('Excel Import: Skipping header row');
              continue;
            }
          }

          String getVal(int index) {
            try {
              if (index >= row.length) return '';
              final cell = row[index];
              if (cell == null || cell.value == null) return '';

              final val = cell.value;
              if (val is TextCellValue) return val.value.toString().trim();
              if (val is IntCellValue) return val.value.toString().trim();
              if (val is DoubleCellValue) return val.value.toString().trim();
              if (val is BoolCellValue) return val.value.toString().trim();
              
              return val.toString().trim();
            } catch (e) {
              return '';
            }
          }

          final name = getVal(0);
          final studentId = getVal(1);
          final className = getVal(2);
          final parentPhone = getVal(3);

          if (name.isEmpty && studentId.isEmpty) continue;

          if (name.isEmpty || studentId.isEmpty || className.isEmpty) {
            print('Excel Import: Skipping row $i due to missing required fields (Name: $name, ID: $studentId, Class: $className)');
            continue;
          }

          if (studentsData.any((s) => s['student_id'] == studentId)) {
            continue;
          }

          studentsData.add({
            'name': name,
            'student_id': studentId,
            'class': className,
            'parent_phone': parentPhone,
          });
        }
      }
      print('Excel Import: Total students parsed: ${studentsData.length}');
      return studentsData;
    } catch (e) {
      print('Excel import error: $e');
      return [];
    }
  }

  static Future<bool> _saveAndShare(Excel excel, String fileName) async {
    try {
      final bytes = excel.encode();
      if (bytes == null) return false;

      if (kIsWeb) {
        // Printing.sharePdf is often used for generic file downloads on web in Flutter
        await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: fileName);
      } else {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(path)],
          text: 'Exported Excel File',
        );
      }
      return true;
    } catch (e) {
      print('Excel export error: $e');
      return false;
    }
  }
}
