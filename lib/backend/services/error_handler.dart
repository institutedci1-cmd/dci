import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '/backend/repositories/audit_repository.dart';

class ErrorHandler {
  static void show(BuildContext context, dynamic error, {AuditRepository? auditRepo, String? errorContext}) {
    debugPrint('App Error: $error');
    
    if (auditRepo != null) {
      auditRepo.logError(error, context: errorContext);
    }
    
    String message = 'An unexpected error occurred.';
    
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          message = 'You do not have permission to perform this action.';
        case 'not-found':
          message = 'The requested resource was not found.';
        default:
          message = error.message ?? message;
      }
    } else if (error is Exception) {
      message = error.toString().replaceAll('Exception: ', '');
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
