// lib/features/inventory/inventory_dashboard_screen.dart

import 'package:flutter/material.dart';

import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';

class InventoryDashboardScreen extends StatelessWidget {
  final ProductDao productDao;

  const InventoryDashboardScreen({
    super.key,
    required this.productDao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Dashboard'),
      ),
      body: FutureBuilder<List<Product>>(
        future: productDao.getAllProducts(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading products:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No products found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              final isLowStock = product.stock < 10;

              return ListTile(
                title: Text(product.name),
                subtitle: Text(
                  'Stock: ${product.stock} | '
                  'Cost: ₦${product.costPrice} | '
                  'Price: ₦${product.sellingPrice}',
                ),
                trailing: isLowStock
                    ? const Icon(
                        Icons.warning,
                        color: Colors.red,
                      )
                    : const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

