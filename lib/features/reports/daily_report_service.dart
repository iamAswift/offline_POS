// lib/features/reports/daily_report_service.dart

import 'dart:convert';
import 'dart:io';
import '../../database/daos/sales_dao.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/attendance_dao.dart';
import '../../database/daos/settings_dao.dart';
import '../../core/business/business_identity.dart';

class DailyReportService {
  final SalesDao salesDao;
  final ProductDao productDao;
  final AttendanceDao attendanceDao;
  final SettingsDao settingsDao;

  DailyReportService({
    required this.salesDao,
    required this.productDao,
    required this.attendanceDao,
    required this.settingsDao,
  });

  Future<File> exportDailyReport() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Dashboard metrics
    final totalSales = await salesDao.getTotalSales(startOfDay, endOfDay);
    final itemsSold = await salesDao.getItemsSold(startOfDay, endOfDay);
    final profit = await salesDao.getProfit(startOfDay, endOfDay);
    final paymentBreakdown = await salesDao.getPaymentBreakdown(startOfDay, endOfDay);
    final categorySummary = await salesDao.getCategorySummary(startOfDay, endOfDay);
    final salesTrend = await salesDao.getSalesTrend(startOfDay, endOfDay);
    final stockValue = await salesDao.getTotalStockValue();

    // Products snapshot
    final products = await productDao.getAllProducts();

    // Attendance snapshot (use DAO helper for today's records)
    final todayAttendance = await attendanceDao.getAllTodayAttendance();

    // Business identity
    final businessName = await BusinessIdentity.getBusinessName(settingsDao);
    final businessTagline = await BusinessIdentity.getBusinessTagline(settingsDao);
    final businessPhone = await BusinessIdentity.getBusinessPhone(settingsDao);
    final businessEmail = await BusinessIdentity.getBusinessEmail(settingsDao);
    final businessAddress = await BusinessIdentity.getBusinessAddress(settingsDao);
    final businessLogo = await BusinessIdentity.getBusinessLogo(settingsDao);

    final report = {
      "date": today.toIso8601String(),
      "business": {
        "name": businessName,
        "tagline": businessTagline,
        "phone": businessPhone,
        "email": businessEmail,
        "address": businessAddress,
        "logo": businessLogo,
      },
      "metrics": {
        "sales_total": totalSales,
        "items_sold": itemsSold,
        "profit": profit,
        "payment_breakdown": paymentBreakdown,
        "category_summary": categorySummary,
        "sales_trend": salesTrend,
        "stock_value": stockValue,
        "products_in_stock": products.length,
        "attendance_count": todayAttendance.length,
      }
    };

    final fileName = "daily_report_${today.toIso8601String().split('T').first}.json";
    final dir = Directory(
      "/Users/okohaustineo/Library/Containers/com.example.supermarketInventory/Data/Documents",
    );
    final file = File("${dir.path}/$fileName");

    await file.writeAsString(jsonEncode(report));
    return file;
  }
}
