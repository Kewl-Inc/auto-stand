import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:auto_stand/config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SlackService {
  // Get Slack webhook URL from environment or config
  static String get _slackWebhookUrl {
    try {
      final envUrl = dotenv.env['SLACK_WEBHOOK_URL'];
      if (envUrl != null && envUrl.isNotEmpty && envUrl != 'your-slack-webhook-url-here') {
        return envUrl;
      }
      return ApiConfig.slackWebhookUrl;
    } catch (e) {
      return ApiConfig.slackWebhookUrl;
    }
  }
  
  // Use proxy server for web, direct webhook for mobile/desktop
  static String get _slackEndpoint {
    if (kIsWeb) {
      // For web, use the proxy server
      // Using 127.0.0.1 instead of localhost for better compatibility
      return 'http://127.0.0.1:3000/api/slack/send';
    } else {
      // For mobile/desktop, use direct webhook
      return _slackWebhookUrl;
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