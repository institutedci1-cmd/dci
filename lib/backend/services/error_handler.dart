import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppError {
  final String message;
  final String? code;

  AppError(this.message, {this.code});

  @override
  String toString() => message;
}

class ErrorHandler {
  static AppError handle(dynamic error) {
    debugPrint('App Error Caught: $error');

    if (error is FirebaseAuthException) {
      return AppError(_mapAuthError(error.code), code: error.code);
    } else if (error is PlatformException) {
      return AppError(_mapPlatformError(error.code, error.message), code: error.code);
    } else if (error is FirebaseException) {
      return AppError('Database error: ${error.message}', code: error.code);
    } else if (error is SocketException) {
      return AppError('No internet connection. Please check your network.', code: 'no_internet');
    } else if (error is AppError) {
      return error;
    }
    
    final errStr = error.toString().toLowerCase();
    if (errStr.contains('network') || errStr.contains('connection') || errStr.contains('socket')) {
      return AppError('Network connection lost. Please try again.', code: 'network_error');
    }

    return AppError('An unexpected error occurred. Please try again.');
  }

  static void show(BuildContext context, dynamic error) {
    final appError = handle(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appError.message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is malformed.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'account-exists-with-different-credential':
        return 'Account already exists with a different login method.';
      case 'operation-not-allowed':
        return 'Login method not enabled in Firebase console.';
      default:
        return 'Authentication failed ($code).';
    }
  }

  static String _mapPlatformError(String code, String? message) {
    switch (code) {
      case 'network_error':
        return 'Check your internet connection.';
      default:
        return 'Platform Error: ${message ?? code}';
    }
  }
}
