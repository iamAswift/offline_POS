// lib/core/widgets/product_image_picker.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
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

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    if (_isLoading) return;

    // ----------------------------------------------------------
    // MOBILE
    // ----------------------------------------------------------

    if (!kIsWeb &&
        (Platform.isAndroid || Platform.isIOS)) {
      await _showMobileImageSource();
      return;
    }

    // ----------------------------------------------------------
    // DESKTOP / WEB
    // ----------------------------------------------------------

    await _pickFromFilePicker();
  }

  // ============================================================
  // MOBILE IMAGE SOURCE
  // ============================================================

  Future<void> _showMobileImageSource() async {
    if (!mounted) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  12,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Product Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------
              // CAMERA
              // ------------------------------------------------

              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.camera_alt),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text(
                  'Use the device camera',
                ),
                onTap: () {
                  Navigator.of(context).pop(
                    ImageSource.camera,
                  );
                },
              ),

              // ------------------------------------------------
              // PHOTOS / GALLERY
              // ------------------------------------------------

              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.photo_library),
                ),
                title: const Text('Choose from Photos'),
                subtitle: const Text(
                  'Select an existing product image',
                ),
                onTap: () {
                  Navigator.of(context).pop(
                    ImageSource.gallery,
                  );
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    await _pickFromMobile(source);
  }

  // ============================================================
  // MOBILE CAMERA / GALLERY
  // ============================================================

  Future<void> _pickFromMobile(
    ImageSource source,
  ) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final picker = ImagePicker();

      final picked = await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (picked == null) {
        return;
      }

      // --------------------------------------------------------
      // READ IMAGE
      // --------------------------------------------------------

      final bytes = await picked.readAsBytes();

      // --------------------------------------------------------
      // 2 MB LIMIT
      // --------------------------------------------------------

      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        if (!mounted) return;

        _showMessage(
          'File too large (max 2MB).',
        );

        return;
      }

      // --------------------------------------------------------
      // APP DOCUMENTS DIRECTORY
      // --------------------------------------------------------

      final dir =
          await getApplicationDocumentsDirectory();

      // --------------------------------------------------------
      // SAFE EXTENSION
      // --------------------------------------------------------

      final extension =
          picked.name.contains('.')
              ? picked.name
                  .split('.')
                  .last
                  .toLowerCase()
              : 'jpg';

      final timestamp =
          DateTime.now().millisecondsSinceEpoch;

      final newPath =
          '${dir.path}/product_$timestamp.$extension';

      // --------------------------------------------------------
      // SAVE IMAGE
      // --------------------------------------------------------

      await picked.saveTo(newPath);

      if (!mounted) return;

      setState(() {
        _imagePath = newPath;
      });

      widget.onImageSelected(newPath);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Could not select product image: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // DESKTOP / WEB FILE PICKER
  // ============================================================

  Future<void> _pickFromFilePicker() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'png',
          'jpg',
          'jpeg',
          'svg',
        ],
        withData: kIsWeb,
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      // --------------------------------------------------------
      // 2 MB LIMIT
      // --------------------------------------------------------

      if (file.size > 2 * 1024 * 1024) {
        if (!mounted) return;

        _showMessage(
          'File too large (max 2MB).',
        );

        return;
      }

      // --------------------------------------------------------
      // WEB
      // --------------------------------------------------------

      if (kIsWeb) {
        if (!mounted) return;

        _showMessage(
          'Product image upload on Web requires '
          'a web storage path.',
        );

        return;
      }

      // --------------------------------------------------------
      // DESKTOP FILE PATH
      // --------------------------------------------------------

      final sourcePath = file.path;

      if (sourcePath == null ||
          sourcePath.isEmpty) {
        if (!mounted) return;

        _showMessage(
          'Could not access the selected file.',
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
          extension.isNotEmpty
              ? '.$extension'
              : '';

      final newPath =
          '${dir.path}/product_$timestamp$safeExtension';

      // --------------------------------------------------------
      // COPY FILE
      // --------------------------------------------------------

      await File(sourcePath).copy(newPath);

      if (!mounted) return;

      setState(() {
        _imagePath = newPath;
      });

      widget.onImageSelected(newPath);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Could not upload product image: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  Widget _buildImagePreview() {
    if (_imagePath == null ||
        _imagePath!.isEmpty) {
      return const Icon(
        Icons.image,
        size: 80,
        color: Colors.grey,
      );
    }

    final path = _imagePath!;

    // ----------------------------------------------------------
    // SVG
    // ----------------------------------------------------------

    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.file(
        File(path),
        height: 100,
        width: 100,
        fit: BoxFit.contain,
      );
    }

    // ----------------------------------------------------------
    // NORMAL IMAGE
    // ----------------------------------------------------------

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

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildImagePreview(),

        const SizedBox(height: 8),

        TextButton.icon(
          onPressed:
              _isLoading ? null : _pickImage,

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
                : _imagePath == null
                    ? 'Upload Product Image'
                    : 'Change Product Image',
          ),
        ),
      ],
    );
  }
}
