// lib/core/widgets/category_image_picker.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../responsive/responsive.dart';

import '../theme/styles.dart';

class CategoryImagePicker extends StatefulWidget {
  final Function(String path) onImageSelected;

  const CategoryImagePicker({
    super.key,
    required this.onImageSelected,
  });

  @override
  State<CategoryImagePicker> createState() =>
      _CategoryImagePickerState();
}

class _CategoryImagePickerState
    extends State<CategoryImagePicker> {
  String? _imagePath;

  bool _isPicking = false;

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    if (_isPicking) {
      return;
    }

    setState(() {
      _isPicking = true;
    });

    try {
      if (Platform.isIOS || Platform.isAndroid) {
        await _pickMobileImage();
      } else if (
          Platform.isMacOS ||
          Platform.isWindows ||
          Platform.isLinux ||
          kIsWeb) {
        await _pickDesktopImage();
      }
    } catch (e, stackTrace) {
      debugPrint(
        'CategoryImagePicker error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to select the image.',
          ),
        ),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPicking = false;
      });
    }
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Future<void> _pickMobileImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();

    if (bytes.lengthInBytes > 2 * 1024 * 1024) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'File too large (max 2MB).',
          ),
        ),
      );

      return;
    }

    final dir =
        await getApplicationDocumentsDirectory();

    final newPath =
        '${dir.path}/${picked.name}';

    await picked.saveTo(newPath);

    if (!mounted) {
      return;
    }

    setState(() {
      _imagePath = newPath;
    });

    widget.onImageSelected(newPath);
  }

  // ============================================================
  // DESKTOP / WEB
  // ============================================================

  Future<void> _pickDesktopImage() async {
    debugPrint(
      'Opening file picker...',
    );

    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    debugPrint(
      'Picker result: $result',
    );

    if (result == null ||
        result.files.isEmpty) {
      return;
    }

    final file = result.files.first;

    if (file.size > 2 * 1024 * 1024) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'File too large (max 2MB).',
          ),
        ),
      );

      return;
    }

    if (file.path == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to access the selected image.',
          ),
        ),
      );

      return;
    }

    final dir =
        await getApplicationDocumentsDirectory();

    final newPath =
        '${dir.path}/${file.name}';

    await File(file.path!).copy(newPath);

    if (!mounted) {
      return;
    }

    setState(() {
      _imagePath = newPath;
    });

    widget.onImageSelected(newPath);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final imageSize = responsive.isCompact
        ? 80.0
        : responsive.isTablet
            ? 100.0
            : 110.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ======================================================
        // IMAGE PREVIEW
        // ======================================================

        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(
              AppRadius.lg,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: _imagePath != null
              ? Image.file(
                  File(_imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 32,
                        color: AppColors.textMuted,
                      ),
                    );
                  },
                )
              : const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        // ======================================================
        // UPLOAD BUTTON
        // ======================================================

        OutlinedButton.icon(
          onPressed:
              _isPicking ? null : _pickImage,
          icon: _isPicking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.upload_outlined,
                ),
          label: Text(
            _isPicking
                ? 'Selecting...'
                : 'Upload Image',
          ),
        ),
      ],
    );
  }
}
