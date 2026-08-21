import 'package:flutter/material.dart';
import 'package:supermarket_inventory/core/widgets/back_button.dart';
import '../../core/theme/styles.dart';
import '../../database/app_database.dart';
import '../../database/daos/supplier_dao.dart';
import 'package:drift/drift.dart' show Value;

class SupplierFormScreen extends StatefulWidget {
  final Supplier? existingSupplier;

  const SupplierFormScreen({super.key, this.existingSupplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SupplierDao _supplierDao;

  String? _name;
  String? _contact;
  String? _address;
  String? _notes;

  @override
  void initState() {
    super.initState();
    _supplierDao = getSupplierDao();
    if (widget.existingSupplier != null) {
      _name = widget.existingSupplier!.name;
      _contact = widget.existingSupplier!.contact;
      _address = widget.existingSupplier!.address;
      _notes = widget.existingSupplier!.notes;
    }
  }

  Future<void> _saveSupplier() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final companion = SuppliersCompanion(
        name: Value(_name!),
        contact: Value(_contact),
        address: Value(_address),
        notes: Value(_notes),
      );

      if (widget.existingSupplier == null) {

        // If adding a new supplier, insert it into the database
        await _supplierDao.insertSupplier(companion);
      } else {

        // If editing an existing supplier, update it in the database
        await _supplierDao.updateSupplier(
          widget.existingSupplier!.copyWithCompanion(companion),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const CentralBackButton(),
        title: Text(widget.existingSupplier == null ? "Add Supplier" : "Edit Supplier",
            style: AppTextStyles.heading),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: AppTextStyles.screenPadding,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (val) => val == null || val.isEmpty ? "Enter name" : null,
                onSaved: (val) => _name = val,
              ),
              TextFormField(
                initialValue: _contact,
                decoration: const InputDecoration(labelText: "Contact"),
                onSaved: (val) => _contact = val,
              ),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: "Address"),
                onSaved: (val) => _address = val,
              ),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: "Notes"),
                onSaved: (val) => _notes = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                onPressed: _saveSupplier,
                child: const Text("Save", style: AppTextStyles.body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
