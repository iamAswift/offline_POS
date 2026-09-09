// lib/core/email/email_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailServiceException implements Exception {
  final String message;
  final bool retryable;
  final int? statusCode;

  const EmailServiceException({
    required this.message,
    required this.retryable,
    this.statusCode,
  });

  @override
  String toString() {
    return message;
  }
}

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
      throw const EmailServiceException(
        message: 'CREATOR_YARD_EMAIL_API_TOKEN is not configured.',
        retryable: false,
      );
    }

    if (installationId.trim().isEmpty) {
      throw const EmailServiceException(
        message: 'Installation ID is required.',
        retryable: false,
      );
    }

    if (jobId <= 0) {
      throw const EmailServiceException(
        message: 'Email job ID must be a positive integer.',
        retryable: false,
      );
    }

    final http.Response response;

    try {
      response = await http.post(
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
    } catch (e) {
      throw const EmailServiceException(
        message:
            'Could not reach the email service. '
            'Please retry the email job.',
        retryable: true,
      );
    }

    Map<String, dynamic> responseData;

    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      final retryable =
          response.statusCode >= 500 ||
          response.statusCode == 408 ||
          response.statusCode == 429;

      throw EmailServiceException(
        message: 'Email API returned an invalid response.',
        retryable: retryable,
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error =
          responseData['error']?.toString() ?? 'Email API request failed.';

      final retryable =
          responseData['retryable'] == true ||
          response.statusCode == 408 ||
          response.statusCode == 409 ||
          response.statusCode == 429 ||
          response.statusCode >= 500;

      throw EmailServiceException(
        message: error,
        retryable: retryable,
        statusCode: response.statusCode,
      );
    }

    if (responseData['success'] != true) {
      final error =
          responseData['error']?.toString() ??
          'Email API failed to send the email.';

      throw EmailServiceException(
        message: error,
        retryable: responseData['retryable'] == true,
      );
    }
  }
}
