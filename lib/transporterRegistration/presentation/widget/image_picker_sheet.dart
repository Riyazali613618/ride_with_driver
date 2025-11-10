// lib/features/transporter_registration/presentation/widgets/image_picker_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerSheet extends StatelessWidget {
  final Function(File) onImagePicked;
  final VoidCallback? onRemove;

  const ImagePickerSheet({super.key, required this.onImagePicked, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();

    Future<void> pickImage(ImageSource source) async {
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80);
      if (image != null) onImagePicked(File(image.path));
    }

    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.gallery);
            },
          ),
          if (onRemove != null)
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Remove Photo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onRemove!();
              },
            ),
        ],
      ),
    );
  }
}
