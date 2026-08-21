import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class BusinessLogoPicker extends StatefulWidget {
  final String? initialPath;
  final Function(String path) onImageSelected;

  const BusinessLogoPicker({
    super.key,
    this.initialPath,
    required this.onImageSelected,
  });

  @override
  State<BusinessLogoPicker> createState() =>
      _BusinessLogoPickerState();
}

class _BusinessLogoPickerState
    extends State<BusinessLogoPicker> {
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _imagePath = widget.initialPath;
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (!kIsWeb &&
          (Platform.isAndroid || Platform.isIOS)) {
        await _pickFromMobile();
      } else {
        await _pickFromDesktop();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not select business logo: $e',
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

  // ============================================================
  // MOBILE
  // ============================================================

  Future<void> _pickFromMobile() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();

    if (bytes.lengthInBytes > 2 * 1024 * 1024) {
      _showMessage(
        'File too large (max 2MB).',
      );

      return;
    }

    final dir =
        await getApplicationDocumentsDirectory();

    final extension =
        picked.name.contains('.')
            ? picked.name.split('.').last.toLowerCase()
            : 'jpg';

    final timestamp =
        DateTime.now().millisecondsSinceEpoch;

    final newPath =
        '${dir.path}/business_logo_$timestamp.$extension';

    await picked.saveTo(newPath);

    await _setSelectedImage(newPath);
  }

  // ============================================================
  // DESKTOP / WEB
  // ============================================================

  Future<void> _pickFromDesktop() async {
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

    if (file.size > 2 * 1024 * 1024) {
      _showMessage(
        'File too large (max 2MB).',
      );

      return;
    }

    // ----------------------------------------------------------
    // WEB
    // ----------------------------------------------------------

    if (kIsWeb) {
      _showMessage(
        'Business logo upload on Web requires a web storage path.',
      );

      return;
    }

    // ----------------------------------------------------------
    // DESKTOP
    // ----------------------------------------------------------

    final sourcePath = file.path;

    if (sourcePath == null ||
        sourcePath.isEmpty) {
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
        '${dir.path}/business_logo_$timestamp$safeExtension';

    await File(sourcePath).copy(newPath);

    await _setSelectedImage(newPath);
  }

  // ============================================================
  // SET IMAGE
  // ============================================================

  Future<void> _setSelectedImage(
    String path,
  ) async {
    if (!mounted) return;

    setState(() {
      _imagePath = path;
    });

    widget.onImageSelected(path);
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  Widget _buildPreview() {
    if (_imagePath == null ||
        _imagePath!.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: const Icon(
          Icons.business,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    final path = _imagePath!;

    final isSvg =
        path.toLowerCase().endsWith('.svg');

    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: isSvg
          ? SvgPicture.file(
              File(path),
              fit: BoxFit.contain,
            )
          : Image.file(
              File(path),
              fit: BoxFit.contain,
              errorBuilder:
                  (
                    context,
                    error,
                    stackTrace,
                  ) {
                return const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                );
              },
            ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
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
        _buildPreview(),

        const SizedBox(height: 12),

        TextButton.icon(
          onPressed:
              _isLoading ? null : _pickImage,
          icon: _isLoading
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.upload,
                ),
          label: Text(
            _isLoading
                ? 'Uploading...'
                : _imagePath == null
                    ? 'Upload Business Logo'
                    : 'Change Business Logo',
          ),
        ),

        if (_imagePath != null)
          Text(
            'Maximum size: 2MB',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }
}