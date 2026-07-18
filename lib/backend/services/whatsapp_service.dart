import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class WhatsappService {
  // These should be moved to a secure configuration or environment variables in production
  static const String _baseUrl = 'https://graph.facebook.com/v17.0';
  static const String _phoneNumberId = 'YOUR_PHONE_NUMBER_ID';
  static const String _accessToken = 'YOUR_ACCESS_TOKEN';

  /// Opens the WhatsApp app on the device with a pre-filled message.
  /// If [phone] is provided, it opens a direct chat with that number.
  /// If [phone] is null, it opens the WhatsApp contact/group picker.
  Future<bool> launchWhatsapp({String? phone, required String message}) async {
    String url;
    if (phone != null && phone.isNotEmpty) {
      // Format phone number: remove non-digits
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      url = "https://wa.me/$cleanPhone/?text=${Uri.encodeComponent(message)}";
    } else {
      // This protocol often triggers the contact picker in the app
      url = "whatsapp://send?text=${Uri.encodeComponent(message)}";
    }

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to wa.me if whatsapp:// protocol is not supported
        final webUrl = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");
        return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendTemplateMessage({
    required String to,
    required String templateName,
    List<String> parameters = const [],
    String languageCode = 'en_US',
  }) async {
    final url = Uri.parse('$_baseUrl/$_phoneNumberId/messages');
    
    final body = {
      "messaging_product": "whatsapp",
      "to": to,
      "type": "template",
      "template": {
        "name": templateName,
        "language": {"code": languageCode},
        "components": [
          if (parameters.isNotEmpty)
            {
              "type": "body",
              "parameters": parameters.map((p) => {"type": "text", "text": p}).toList(),
            }
        ]
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendTextMessage({
    required String to,
    required String message,
  }) async {
    final url = Uri.parse('$_baseUrl/$_phoneNumberId/messages');
    
    final body = {
      "messaging_product": "whatsapp",
      "recipient_type": "individual",
      "to": to,
      "type": "text",
      "text": {"preview_url": false, "body": message}
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
