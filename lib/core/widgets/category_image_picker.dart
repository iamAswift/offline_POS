import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class CategoryImagePicker extends StatefulWidget {
  final Function(String path) onImageSelected;
  const CategoryImagePicker({super.key, required this.onImageSelected});

  @override
  State<CategoryImagePicker> createState() => _CategoryImagePickerState();
}

class _CategoryImagePickerState extends State<CategoryImagePicker> {
  String? _imagePath;

  Future<void> _pickImage() async {
    if (Platform.isIOS || Platform.isAndroid) {
      // ✅ Mobile: use image_picker
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (bytes.lengthInBytes > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File too large (max 2MB)")),
          );
          return;
        }

        final dir = await getApplicationDocumentsDirectory();
        final newPath = '${dir.path}/${picked.name}';
        await picked.saveTo(newPath);

        setState(() => _imagePath = newPath);
        widget.onImageSelected(newPath);
      }
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux || kIsWeb) {
      debugPrint("Opening file picker...");
      // ✅ Desktop/Web: use file_picker
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      debugPrint("Picker result: $result");

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.size > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File too large (max 2MB)")),
          );
          return;
        }

        final dir = await getApplicationDocumentsDirectory();
        final newPath = '${dir.path}/${file.name}';
        await File(file.path!).copy(newPath);

        setState(() => _imagePath = newPath);
        widget.onImageSelected(newPath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _imagePath != null
            ? Image.file(File(_imagePath!), height: 100)
            : const Icon(Icons.image, size: 80),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.upload),
          label: const Text("Upload Image"),
        ),
      ],
    );
  }
}
