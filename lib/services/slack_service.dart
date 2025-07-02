import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:auto_stand/config/api_config.dart';

class SlackService {
  // Use proxy server for web, direct webhook for mobile/desktop
  static String get _slackEndpoint {
    if (kIsWeb) {
      // For web, use the proxy server
      // Using 127.0.0.1 instead of localhost for better compatibility
      return 'http://127.0.0.1:3000/api/slack/send';
    } else {
      // For mobile/desktop, use direct webhook
      return ApiConfig.slackWebhookUrl;
    }
  }
  
  static Future<bool> sendToSlack(String message) async {
    try {
      debugPrint('Sending message to Slack...');
      debugPrint('Using endpoint: $_slackEndpoint');
      
      final response = await http.post(
        Uri.parse(_slackEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': message,
        }),
      );
      
      if (response.statusCode == 200) {
        debugPrint('Successfully sent to Slack');
        return true;
      } else {
        debugPrint('Failed to send to Slack: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending to Slack: $e');
      return false;
    }
  }
}