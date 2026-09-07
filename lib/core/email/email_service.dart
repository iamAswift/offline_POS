// lib/core/email/email_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailService {
  static const String _baseUrl =
      'https://creator-yard-email-api.dawn-feather-6cd6.workers.dev';

  static const String _apiToken = String.fromEnvironment(
    'CREATOR_YARD_EMAIL_API_TOKEN',
  );

  static Future<void> sendSaleEmail({
    required String installationId,
    required int jobId,
    required String recipient,
    required String subject,
    required String body,
  }) async {
    if (_apiToken.isEmpty) {
      throw StateError('CREATOR_YARD_EMAIL_API_TOKEN is not configured.');
    }

    if (installationId.trim().isEmpty) {
      throw StateError('Installation ID is required.');
    }

    if (jobId <= 0) {
      throw StateError('Email job ID must be a positive integer.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/v1/email/sale'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiToken',
      },
      body: jsonEncode({
        'installationId': installationId.trim(),
        'jobId': jobId,
        'recipient': recipient.trim(),
        'subject': subject,
        'body': body,
      }),
    );

    Map<String, dynamic> responseData;

    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw StateError('Email API returned an invalid response.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error =
          responseData['error']?.toString() ?? 'Email API request failed.';

      throw StateError(error);
    }

    if (responseData['success'] != true) {
      final error =
          responseData['error']?.toString() ??
          'Email API failed to send the email.';

      throw StateError(error);
    }
  }
}
