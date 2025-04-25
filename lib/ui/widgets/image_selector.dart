import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/../themes/theme.dart';

class ImageSelector extends StatefulWidget {
  final String label;
  final Function(File?) onImageSelected;

  const ImageSelector({Key? key, required this.label, required this.onImageSelected}) : super(key: key);

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      widget.onImageSelected(_image); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final borderRadius = screenWidth * 0.05; // Bordes redondeados
    final fontSize = screenHeight * 0.018; // Tamaño de fuente

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.tertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Galería'),
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Cámara'),
                        onTap: () {
                          _pickImage(ImageSource.camera);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            height: screenHeight * 0.06,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, color: AppColors.tertiary, size: fontSize * 1.5),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  _image == null ? 'Seleccionar imagen' : 'Imagen seleccionada',
                  style: TextStyle(color: AppColors.tertiary, fontSize: fontSize),
                ),
              ],
            ),
          ),
        ),
        if (_image != null)
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.01),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius / 2),
              child: Image.file(
                _image!,
                height: screenHeight * 0.1,
                width: screenWidth * 0.2,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }
}
