import 'dart:convert';
import 'package:http/http.dart' as http;

class WhatsappService {
  // These should be moved to a secure configuration or environment variables in production
  static const String _baseUrl = 'https://graph.facebook.com/v17.0';
  static const String _phoneNumberId = 'YOUR_PHONE_NUMBER_ID';
  static const String _accessToken = 'YOUR_ACCESS_TOKEN';

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
        print('WhatsApp message sent successfully');
        return true;
      } else {
        print('Failed to send WhatsApp message: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending WhatsApp message: $e');
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
        print('Failed to send WhatsApp text: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending WhatsApp text: $e');
      return false;
    }
  }
}
