import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/backend/models/student_attendance.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/models/daily_report.dart';

class ExcelService {
  static Future<bool> exportAttendanceReport(
    List<Student> students,
    List<StudentAttendance> attendance,
    String className,
    DateTime date,
  ) async {
    if (students.isEmpty) return false;

    final excel = Excel.createExcel();
    final sheet = excel['Attendance Report'];

    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue('Class: $className'),
      TextCellValue('Date: ${dateTimeFormat('yMMMd', date)}'),
    ]);
    sheet.appendRow([TextCellValue('')]); // Spacer

    sheet.appendRow([
      TextCellValue('Roll No'),
      TextCellValue('Student Name'),
      TextCellValue('Status'),
      TextCellValue('Subject'),
    ]);

    for (final student in students) {
      final logs = attendance.where((l) => l.studentId == student.studentId).toList();
      final status = logs.isNotEmpty ? logs.first.status : 'Not Marked';
      final subject = logs.isNotEmpty ? logs.first.subject : 'N/A';

      sheet.appendRow([
        TextCellValue(student.rollNo),
        TextCellValue(student.name),
        TextCellValue(status),
        TextCellValue(subject),
      ]);
    }

    return await _saveAndShare(excel, 'Attendance_${className}_${dateTimeFormat('yyyyMMdd', date)}.xlsx');
  }

  static Future<bool> exportStudents(List<Student> students) async {
    if (students.isEmpty) return false;
    
    final excel = Excel.createExcel();
    final sheet = excel['Students'];
    
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Student ID'),
      TextCellValue('Roll No'),
      TextCellValue('Class'),
      TextCellValue('Section'),
      TextCellValue('Gender'),
      TextCellValue('Date of Birth'),
      TextCellValue('Parent Name'),
      TextCellValue('Parent Phone'),
      TextCellValue('Alternate Phone'),
      TextCellValue('Email'),
      TextCellValue('Village/City'),
      TextCellValue('Address'),
      TextCellValue('PIN Code'),
      TextCellValue('Admission Date'),
      TextCellValue('Batch'),
      TextCellValue('Fees Status'),
      TextCellValue('Notes'),
      TextCellValue('Subjects'),
    ]);

    for (final student in students) {
      sheet.appendRow([
        TextCellValue(student.name),
        TextCellValue(student.studentId),
        TextCellValue(student.rollNo),
        TextCellValue(student.className),
        TextCellValue(student.section ?? ''),
        TextCellValue(student.gender ?? ''),
        TextCellValue(student.dob ?? ''),
        TextCellValue(student.parentName ?? ''),
        TextCellValue(student.parentPhone ?? ''),
        TextCellValue(student.altPhone ?? ''),
        TextCellValue(student.email ?? ''),
        TextCellValue(student.villageCity ?? ''),
        TextCellValue(student.address ?? ''),
        TextCellValue(student.pinCode ?? ''),
        TextCellValue(student.admissionDate ?? ''),
        TextCellValue(student.batch ?? ''),
        TextCellValue(student.feesStatus ?? ''),
        TextCellValue(student.notes ?? ''),
        TextCellValue(student.subjects?.join(', ') ?? ''),
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
        debugPrint('Excel Import: Bytes are null');
        return [];
      }
      debugPrint('Excel Import: Read ${bytes.length} bytes');

      final excel = Excel.decodeBytes(bytes);
      final List<Map<String, String>> studentsData = [];

      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        for (int i = 0; i < sheet.rows.length; i++) {
          final row = sheet.rows[i];
          if (row.isEmpty) continue;

          // Skip header row
          if (i == 0) {
            final firstCell = (row[0]?.value?.toString() ?? '').toLowerCase();
            if (firstCell.contains('name') || firstCell.contains('student')) {
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
          String studentId = getVal(1);
          final rollNo = getVal(2);
          String className = normalizeClassName(getVal(3));
          final section = getVal(4);
          final gender = getVal(5);
          final dob = getVal(6);
          final parentName = getVal(7);
          final parentPhone = getVal(8);
          final altPhone = getVal(9);
          final email = getVal(10);
          final villageCity = getVal(11);
          final address = getVal(12);
          final pinCode = getVal(13);
          final admissionDate = getVal(14);
          final batch = getVal(15);
          final feesStatus = getVal(16);
          final notes = getVal(17);
          final subjects = getVal(18);

          if (name.isEmpty) continue;

          // Auto-generate ID if missing
          if (studentId.isEmpty) {
            studentId = 'STU-${const Uuid().v4().substring(0, 8).toUpperCase()}';
          }

          // Fallback class if missing
          if (className.isEmpty) {
            className = 'Unassigned';
          }

          if (studentsData.any((s) => s['student_id'] == studentId)) {
            // If duplicate ID, generate a new one to ensure import succeeds
            studentId = 'STU-${const Uuid().v4().substring(0, 8).toUpperCase()}';
          }

          studentsData.add({
            'name': name,
            'student_id': studentId,
            'roll_no': rollNo,
            'class': className,
            'section': section,
            'gender': gender,
            'dob': dob,
            'parent_name': parentName,
            'parent_phone': parentPhone,
            'alt_phone': altPhone,
            'email': email,
            'village_city': villageCity,
            'address': address,
            'pin_code': pinCode,
            'admission_date': admissionDate,
            'batch': batch,
            'fees_status': feesStatus,
            'notes': notes,
            'subjects': subjects,
          });
        }
      }
      return studentsData;
    } catch (e) {
      debugPrint('Excel import error: $e');
      return [];
    }
  }

  static Future<bool> _saveAndShare(Excel excel, String fileName) async {
    try {
      final bytes = excel.encode();
      if (bytes == null) return false;

      if (kIsWeb) {
        await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: fileName);
      } else {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(path)],
            text: 'Exported Excel File',
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Excel export error: $e');
      return false;
    }
  }
}
