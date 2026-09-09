// lib/core/email/email_credits_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/system/installation_identity.dart';
import '../../database/daos/settings_dao.dart';

class EmailCreditPackage {
  final String id;
  final int credits;
  final int priceNgn;

  const EmailCreditPackage({
    required this.id,
    required this.credits,
    required this.priceNgn,
  });

  factory EmailCreditPackage.fromJson(Map<String, dynamic> json) {
    return EmailCreditPackage(
      id: json['id']?.toString() ?? '',
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      priceNgn: (json['priceNgn'] as num?)?.toInt() ?? 0,
    );
  }
}

class EmailCreditPurchase {
  final String packageId;
  final int credits;
  final int amountNgn;
  final String txRef;
  final String status;
  final String checkoutUrl;

  const EmailCreditPurchase({
    required this.packageId,
    required this.credits,
    required this.amountNgn,
    required this.txRef,
    required this.status,
    required this.checkoutUrl,
  });

  factory EmailCreditPurchase.fromJson(Map<String, dynamic> json) {
    final payment = json['payment'] as Map<String, dynamic>?;

    return EmailCreditPurchase(
      packageId: json['packageId']?.toString() ?? '',
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      amountNgn: (json['amountNgn'] as num?)?.toInt() ?? 0,
      txRef: json['txRef']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      checkoutUrl: payment?['link']?.toString() ?? '',
    );
  }
}

class EmailCreditLedgerEntry {
  final int id;
  final String type;
  final int amount;
  final String? reference;
  final String? description;
  final DateTime createdAt;

  const EmailCreditLedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.reference,
    required this.description,
    required this.createdAt,
  });

  factory EmailCreditLedgerEntry.fromJson(Map<String, dynamic> json) {
    return EmailCreditLedgerEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      reference: json['reference']?.toString(),
      description: json['description']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class EmailCreditBalance {
  final int accountId;
  final int balance;
  final String createdAt;
  final String updatedAt;

  const EmailCreditBalance({
    required this.accountId,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmailCreditBalance.fromJson(Map<String, dynamic> json) {
    return EmailCreditBalance(
      accountId: (json['id'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

class EmailCreditLedger {
  final List<EmailCreditLedgerEntry> entries;
  final int balance;

  const EmailCreditLedger({required this.entries, required this.balance});
}

class EmailCreditsService {
  EmailCreditsService({required this.settingsDao});

  static const String _baseUrl =
      'https://creator-yard-email-api.dawn-feather-6cd6.workers.dev';

  static const String _apiToken = String.fromEnvironment(
    'CREATOR_YARD_EMAIL_API_TOKEN',
  );

  final SettingsDao settingsDao;

  Future<String> _getInstallationId() {
    return InstallationIdentity.getInstallationId(settingsDao);
  }

  Map<String, String> _headers() {
    if (_apiToken.isEmpty) {
      throw StateError('CREATOR_YARD_EMAIL_API_TOKEN is not configured.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiToken',
    };
  }

  Future<Map<String, dynamic>> _decodeResponse(http.Response response) async {
    Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw StateError('Email credits API returned an invalid response.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error =
          data['error']?.toString() ?? 'Email credits API request failed.';

      throw StateError(error);
    }

    if (data['success'] != true) {
      final error =
          data['error']?.toString() ?? 'Email credits API request failed.';

      throw StateError(error);
    }

    return data;
  }

  /// Fetch the authoritative available
  /// email credit packages.
  ///
  /// Package pricing comes from the
  /// Creator Yard Worker.
  /// Flutter does not define or override
  /// package prices.
  Future<List<EmailCreditPackage>> getPackages() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/v1/email/credits/packages'),
      headers: _headers(),
    );

    final data = await _decodeResponse(response);

    final rawPackages = data['packages'] as List<dynamic>? ?? const [];

    return rawPackages
        .whereType<Map<String, dynamic>>()
        .map(EmailCreditPackage.fromJson)
        .where(
          (package) =>
              package.id.isNotEmpty &&
              package.credits > 0 &&
              package.priceNgn > 0,
        )
        .toList();
  }

  /// Start a server-controlled
  /// Flutterwave credit purchase.
  ///
  /// Flutter only sends:
  /// - packageId
  /// - customerEmail
  /// - optional customerName
  ///
  /// The Worker determines:
  /// - credit quantity
  /// - price
  /// - transaction reference
  /// - Flutterwave checkout URL
  Future<EmailCreditPurchase> purchaseCredits({
    required String packageId,
    required String customerEmail,
    String? customerName,
  }) async {
    final installationId = await _getInstallationId();

    final normalizedPackageId = packageId.trim();

    final normalizedEmail = customerEmail.trim().toLowerCase();

    final normalizedName = customerName?.trim();

    if (normalizedPackageId.isEmpty) {
      throw ArgumentError.value(packageId, 'packageId', 'cannot be empty.');
    }

    if (normalizedEmail.isEmpty) {
      throw ArgumentError.value(
        customerEmail,
        'customerEmail',
        'cannot be empty.',
      );
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/v1/email/credits/purchase'),
      headers: _headers(),
      body: jsonEncode({
        'installationId': installationId,
        'packageId': normalizedPackageId,
        'customerEmail': normalizedEmail,
        if (normalizedName != null && normalizedName.isNotEmpty)
          'customerName': normalizedName,
      }),
    );

    final data = await _decodeResponse(response);

    final purchaseData = data['purchase'] as Map<String, dynamic>?;

    if (purchaseData == null) {
      throw StateError('Email credits API returned no purchase details.');
    }

    final paymentData = data['payment'] as Map<String, dynamic>?;

    return EmailCreditPurchase.fromJson({
      ...purchaseData,
      'payment': paymentData,
    });
  }

  /// Fetch the authoritative current
  /// credit balance.
  Future<EmailCreditBalance> getBalance() async {
    final installationId = await _getInstallationId();

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/v1/email/credits/balance'
        '?installationId=${Uri.encodeQueryComponent(installationId)}',
      ),
      headers: _headers(),
    );

    final data = await _decodeResponse(response);

    final creditAccount = data['creditAccount'] as Map<String, dynamic>?;

    if (creditAccount == null) {
      throw StateError('Email credits API returned no credit account.');
    }

    return EmailCreditBalance.fromJson(creditAccount);
  }

  /// Fetch the authoritative credit ledger.
  Future<EmailCreditLedger> getLedger({int limit = 50, int offset = 0}) async {
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'must be between 1 and 100.');
    }

    if (offset < 0) {
      throw ArgumentError.value(offset, 'offset', 'cannot be negative.');
    }

    final installationId = await _getInstallationId();

    final uri = Uri.parse('$_baseUrl/v1/email/credits/ledger').replace(
      queryParameters: {
        'installationId': installationId,
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    final response = await http.get(uri, headers: _headers());

    final data = await _decodeResponse(response);

    final rawEntries = data['ledger'] as List<dynamic>? ?? const [];

    final entries = rawEntries
        .whereType<Map<String, dynamic>>()
        .map(EmailCreditLedgerEntry.fromJson)
        .toList();

    final balance = (data['balance'] as num?)?.toInt() ?? 0;

    return EmailCreditLedger(entries: entries, balance: balance);
  }
}
