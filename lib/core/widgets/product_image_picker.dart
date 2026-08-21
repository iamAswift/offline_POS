//lib/core/widgets/product_image_picker.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

class ProductImagePicker extends StatefulWidget {
  final Function(String path) onImageSelected;

  const ProductImagePicker({
    super.key,
    required this.onImageSelected,
  });

  @override
  State<ProductImagePicker> createState() =>
      _ProductImagePickerState();
}

class _ProductImagePickerState
    extends State<ProductImagePicker> {
  String? _imagePath;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'png',
          'jpg',
          'jpeg',
          'svg',
        ],
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      // Restrict file size to 2 MB.
      if (file.size > 2 * 1024 * 1024) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File too large (max 2MB)',
            ),
          ),
        );

        return;
      }

      final sourcePath = file.path;

      if (sourcePath == null ||
          sourcePath.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not access the selected file',
            ),
          ),
        );

        return;
      }

      final dir =
          await getApplicationDocumentsDirectory();

      final extension =
          file.extension?.toLowerCase() ?? '';

      final timestamp =
          DateTime.now().millisecondsSinceEpoch;

      final safeExtension =
          extension.isNotEmpty ? '.$extension' : '';

      final newPath =
          '${dir.path}/product_$timestamp$safeExtension';

      final sourceFile = File(sourcePath);

      await sourceFile.copy(newPath);

      if (!mounted) return;

      setState(() {
        _imagePath = newPath;
      });

      widget.onImageSelected(newPath);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not upload image: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildImagePreview() {
    if (_imagePath == null) {
      return const Icon(
        Icons.image,
        size: 80,
        color: Colors.grey,
      );
    }

    final path = _imagePath!;

    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(
        File(path),
        height: 100,
        width: 100,
        fit: BoxFit.contain,
      );
    }

    return Image.file(
      File(path),
      height: 100,
      width: 100,
      fit: BoxFit.contain,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return const Icon(
          Icons.broken_image,
          size: 80,
          color: Colors.grey,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildImagePreview(),

        const SizedBox(height: 8),

        TextButton.icon(
          onPressed: _isLoading
              ? null
              : _pickImage,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.upload),
          label: Text(
            _isLoading
                ? 'Uploading...'
                : 'Upload Product Image',
          ),
        ),
      ],
    );
  }
}