// lib/shared/pdf_report.dart

import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/app_database.dart';
import '../database/daos/settings_dao.dart';
import '../database/tables/product_table.dart';

import '../core/business/business_identity.dart';

import 'package:supermarket_inventory/models/reconciliation_row.dart';

class PdfReport {
  // ============================================================
  // BUSINESS IDENTITY
  // ============================================================

  static Future<_PdfBusinessIdentity>
      _loadBusinessIdentity() async {
    final settingsDao = SettingsDao(getDatabase());

    final results = await Future.wait([
      BusinessIdentity.getBusinessName(settingsDao),
      BusinessIdentity.getBusinessTagline(settingsDao),
      BusinessIdentity.getBusinessPhone(settingsDao),
      BusinessIdentity.getBusinessEmail(settingsDao),
      BusinessIdentity.getBusinessAddress(settingsDao),
      BusinessIdentity.getBusinessLogo(settingsDao),
    ]);

    return _PdfBusinessIdentity(
      name: results[0] as String,
      tagline: results[1] as String,
      phone: results[2] as String,
      email: results[3] as String,
      address: results[4] as String,
      logoPath: results[5] as String?,
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  static Future<pw.MemoryImage?> _loadLogo(
    String? logoPath,
  ) async {
    if (logoPath == null ||
        logoPath.trim().isEmpty) {
      return null;
    }

    try {
      final file = File(logoPath);

      if (!await file.exists()) {
        return null;
      }

      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        return null;
      }

      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // PDF HEADER
  // ============================================================

  static Future<pw.Widget> _buildBusinessHeader(
    _PdfBusinessIdentity business,
  ) async {
    final logo = await _loadLogo(
      business.logoPath,
    );

    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(
        bottom: 20,
      ),
      padding: const pw.EdgeInsets.only(
        bottom: 15,
      ),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey300,
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          if (logo != null)
            pw.Container(
              width: 55,
              height: 55,
              margin: const pw.EdgeInsets.only(
                right: 15,
              ),
              child: pw.Image(
                logo,
                fit: pw.BoxFit.contain,
              ),
            ),

          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  business.name.isEmpty
                      ? BusinessIdentity.defaultBusinessName
                      : business.name,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),

                if (business.tagline.isNotEmpty)
                  pw.Padding(
                    padding:
                        const pw.EdgeInsets.only(
                      top: 3,
                    ),
                    child: pw.Text(
                      business.tagline,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),

                if (business.address.isNotEmpty)
                  pw.Padding(
                    padding:
                        const pw.EdgeInsets.only(
                      top: 5,
                    ),
                    child: pw.Text(
                      business.address,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),

                if (business.phone.isNotEmpty ||
                    business.email.isNotEmpty)
                  pw.Padding(
                    padding:
                        const pw.EdgeInsets.only(
                      top: 2,
                    ),
                    child: pw.Text(
                      [
                        if (business.phone.isNotEmpty)
                          business.phone,
                        if (business.email.isNotEmpty)
                          business.email,
                      ].join('  •  '),
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GENERIC REPORT
  // ============================================================

  static Future<File> generateReport({
    required String title,
    required List<Map<String, dynamic>> sections,
  }) async {
    final pdf = pw.Document();

    // ----------------------------------------------------------
    // BUSINESS IDENTITY
    // ----------------------------------------------------------

    final business =
        await _loadBusinessIdentity();

    // ----------------------------------------------------------
    // FONT
    // ----------------------------------------------------------

    final ttf = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/Roboto-Regular.ttf',
      ),
    );

    // ----------------------------------------------------------
    // BUSINESS HEADER
    // ----------------------------------------------------------

    final businessHeader =
        await _buildBusinessHeader(
      business,
    );

    // ----------------------------------------------------------
    // PDF
    // ----------------------------------------------------------

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: ttf,
        ),

        build: (context) => [
          // BUSINESS HEADER

          businessHeader,

          // REPORT TITLE

          pw.Header(
            level: 0,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ),

          // ------------------------------------------------------
          // REPORT SECTIONS
          // ------------------------------------------------------

          for (final section in sections) ...[
            pw.Header(
              level: 1,
              child: pw.Text(
                section['title'],
              ),
            ),

            pw.Table.fromTextArray(
              headers:
                  List<String>.from(
                section['headers'],
              ),
              data:
                  (section['rows'] as List)
                      .map((row)=> (row as List)
                          .map((cell) => cell.toString())
                          .toList())
                      .toList()
            ),

            pw.SizedBox(
              height: 20,
            ),
          ],
        ],

        // --------------------------------------------------------
        // FOOTER
        // --------------------------------------------------------

        footer: (context) {
          return pw.Container(
            alignment:
                pw.Alignment.center,
            margin:
                const pw.EdgeInsets.only(
              top: 10,
            ),
            child: pw.Text(
              '${business.name.isEmpty ? BusinessIdentity.defaultBusinessName : business.name} • ${context.pageNumber} / ${context.pagesCount}',
              style:
                  const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
              ),
            ),
          );
        },
      ),
    );

    // ==========================================================
    // SAVE
    // ==========================================================

    final dir =
        await getApplicationDocumentsDirectory();

    final file = File(
      '${dir.path}/$title.pdf',
    );

    await file.writeAsBytes(
      await pdf.save(),
    );

    return file;
  }

  // ============================================================
  // DASHBOARD REPORT
  // ============================================================

  static Future<File> generateDashboardReport({
    required double totalSales,
    required int itemsSold,
    required double profit,
    required Map<String, double>
        paymentBreakdown,
    required List<Map<String, dynamic>>
        categorySummary,
    required List<Map<String, dynamic>>
        salesTrend,
  }) {
    return generateReport(
      title: 'Reports Dashboard',
      sections: [
        {
          'title': 'Overview',
          'headers': [
            'Metric',
            'Value',
          ],
          'rows': [
            [
              'Sales',
              '₦${totalSales.toStringAsFixed(2)}',
            ],
            [
              'Items Sold',
              '$itemsSold',
            ],
            [
              'Profit',
              '₦${profit.toStringAsFixed(2)}',
            ],
          ],
        },
        {
          'title': 'Payment Breakdown',
          'headers': [
            'Method',
            'Amount',
          ],
          'rows': paymentBreakdown.entries
              .map(
                (e) => [
                  e.key,
                  '₦${e.value.toStringAsFixed(2)}',
                ],
              )
              .toList(),
        },
        {
          'title': 'Category Performance',
          'headers': [
            'Category',
            'Sales',
            'Profit',
            'Stock Value',
          ],
          'rows': categorySummary
              .map(
                (cat) => [
                  cat['categoryName'],
                  '₦${(cat['totalSales'] as double).toStringAsFixed(2)}',
                  '₦${(cat['profit'] as double).toStringAsFixed(2)}',
                  '₦${(cat['stockValue'] as double).toStringAsFixed(2)}',
                ],
              )
              .toList(),
        },
        {
          'title': 'Sales Trend',
          'headers': [
            'Date',
            'Sales',
          ],
          'rows': salesTrend
              .map(
                (trend) => [
                  trend['date'],
                  '₦${(trend['totalSales'] as double).toStringAsFixed(2)}',
                ],
              )
              .toList(),
        },
      ],
    );
  }

  // ============================================================
  // SALES REPORT
  // ============================================================

  static Future<File> generateSalesReport({
    required double totalSales,
    required int itemsSold,
    required double profit,
    required Map<String, double>
        paymentBreakdown,
    required List<Products> lowStock,
  }) {
    return generateReport(
      title: 'Sales Report',
      sections: [
        {
          'title': 'Daily Overview',
          'headers': [
            'Metric',
            'Value',
          ],
          'rows': [
            [
              'Total Sales',
              '₦${totalSales.toStringAsFixed(2)}',
            ],
            [
              'Items Sold',
              '$itemsSold',
            ],
            [
              'Profit',
              '₦${profit.toStringAsFixed(2)}',
            ],
          ],
        },
        {
          'title': 'Payment Breakdown',
          'headers': [
            'Method',
            'Amount',
          ],
          'rows': paymentBreakdown.entries
              .map(
                (e) => [
                  e.key,
                  '₦${e.value.toStringAsFixed(2)}',
                ],
              )
              .toList(),
        },
        {
          'title': 'Low Stock',
          'headers': [
            'Product',
            'Stock',
          ],
          'rows': lowStock
              .map(
                (p) => [
                  p.name,
                  '${p.stock}',
                ],
              )
              .toList(),
        },
      ],
    );
  }

  // ============================================================
  // CATEGORY REPORT
  // ============================================================

  static Future<File> generateCategoryReport(
    List<Map<String, dynamic>> categories,
  ) {
    return generateReport(
      title: 'Category Report',
      sections: [
        {
          'title': 'Category Performance',
          'headers': [
            'Category',
            'Sales',
            'Profit',
            'Stock Value',
          ],
          'rows': categories
              .map(
                (cat) => [
                  cat['categoryName'],
                  '₦${(cat['totalSales'] as double).toStringAsFixed(2)}',
                  '₦${(cat['profit'] as double).toStringAsFixed(2)}',
                  '₦${(cat['stockValue'] as double).toStringAsFixed(2)}',
                ],
              )
              .toList(),
        },
      ],
    );
  }

  // ============================================================
  // OUT OF STOCK REPORT
  // ============================================================

  static Future<File> generateOutOfStockReport(
    List<Products> outOfStock,
  ) {
    return generateReport(
      title: 'Out of Stock Report',
      sections: [
        {
          'title': 'Out of Stock Products',
          'headers': [
            'Product',
            'Stock',
          ],
          'rows': outOfStock
              .map(
                (p) => [
                  p.name,
                  '${p.stock}',
                ],
              )
              .toList(),
        },
      ],
    );
  }

  // ============================================================
  // STOCK VALUE REPORT
  // ============================================================

  static Future<File> generateStockValueReport(
    double stockValue,
  ) {
    return generateReport(
      title: 'Stock Value Report',
      sections: [
        {
          'title': 'Stock Value Summary',
          'headers': [
            'Metric',
            'Value',
          ],
          'rows': [
            [
              'Total Stock Value',
              '₦${stockValue.toStringAsFixed(2)}',
            ],
          ],
        },
      ],
    );
  }

  // ============================================================
  // PROFIT REPORT
  // ============================================================

  static Future<File> generateProfitReport(
    double profit,
  ) {
    return generateReport(
      title: 'Profit Report',
      sections: [
        {
          'title': 'Profit Summary',
          'headers': [
            'Metric',
            'Value',
          ],
          'rows': [
            [
              'Total Profit',
              '₦${profit.toStringAsFixed(2)}',
            ],
          ],
        },
      ],
    );
  }

  // ============================================================
  // RECONCILIATION REPORT
  // ============================================================

  static Future<File>
      generateReconciliationReport(
    List<ReconciliationRow> rows,
    DateTime date,
  ) {
    return generateReport(
      title:
          'Daily Reconciliation - ${date.toLocal().toIso8601String().substring(0, 10)}',
      sections: [
        {
          'title':
              'Stock Reconciliation',
          'headers': [
            'Product',
            'Opening',
            'Received',
            'Sold',
            'Expected',
            'Physical',
            'Diff',
          ],
          'rows': rows
              .map(
                (r) => [
                  r.productName,
                  '${r.openingStock}',
                  '${r.received}',
                  '${r.sold}',
                  '${r.expectedClosing}',
                  '${r.physicalCount}',
                  '${r.difference}',
                ],
              )
              .toList(),
        },
      ],
    );
  }
}

// ============================================================================
// PDF BUSINESS IDENTITY MODEL
// ============================================================================

class _PdfBusinessIdentity {
  final String name;
  final String tagline;
  final String phone;
  final String email;
  final String address;
  final String? logoPath;

  const _PdfBusinessIdentity({
    required this.name,
    required this.tagline,
    required this.phone,
    required this.email,
    required this.address,
    required this.logoPath,
  });
}