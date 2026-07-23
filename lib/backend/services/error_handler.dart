import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:d_c_i_teacher_app/backend/repositories/audit_repository.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';

class ErrorHandler {
  static void show(BuildContext context, dynamic error, {AuditRepository? auditRepo, String? errorContext}) {
    debugPrint('App Error: $error');
    
    if (auditRepo != null) {
      auditRepo.logError(error, context: errorContext);
    }
    
    String message = 'An unexpected error occurred.';
    
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = error.message ?? message;
      }
    } else if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          message = 'You do not have permission to perform this action.';
          break;
        case 'not-found':
          message = 'The requested resource was not found.';
          break;
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
        backgroundColor: FlutterFlowTheme.of(context).error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
