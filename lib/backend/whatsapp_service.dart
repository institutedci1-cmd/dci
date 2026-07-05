import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WhatsAppService {
  static final _functions = FirebaseFunctions.instance;

  /// Sends a WhatsApp text message via the `sendWhatsAppMessage` callable function.
  /// Throws if the user is not authenticated or the function returns an error.
  static Future<Map<String, dynamic>> sendMessage({
    required String to,
    required String message,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final callable = _functions.httpsCallable('sendWhatsAppMessage');
    final result = await callable.call(<String, dynamic>{
      'to': to,
      'message': message,
    });

    return Map<String, dynamic>.from(result.data as Map);
  }
}
