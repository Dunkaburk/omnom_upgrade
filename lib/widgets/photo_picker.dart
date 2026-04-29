import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/colors.dart';
import 'dashed_border.dart';

/// 78×78 photo tile shared by the diary and recipe forms. Decodes a base64
/// data URL when set; otherwise renders a dashed-border camera placeholder.
/// On tap, opens the gallery and emits the new base64 data URL via [onChange].
class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    required this.photo,
    required this.onChange,
  });

  final String? photo;
  final ValueChanged<String?> onChange;

  Future<void> _pick() async {
    try {
      final picker = ImagePicker();
      final f = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (f == null) return;
      final bytes = await f.readAsBytes();
      onChange('data:image/jpeg;base64,${base64Encode(bytes)}');
    } catch (_) {
      // Permission denied or unsupported on this platform — ignore silently.
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photo != null && photo!.isNotEmpty;
    Uint8List? bytes;
    if (hasPhoto) {
      try {
        final s = photo!;
        final comma = s.indexOf(',');
        bytes = base64Decode(comma >= 0 ? s.substring(comma + 1) : s);
      } catch (_) {/* ignore */}
    }
    return SizedBox(
      width: 78,
      height: 78,
      child: Material(
        color: hasPhoto ? Colors.transparent : AppColors.creamDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _pick,
          child: bytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    bytes,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                  ),
                )
              : CustomPaint(
                  painter: DashedBorderPainter(
                    color: AppColors.border,
                    radius: 14,
                    strokeWidth: 2,
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('📷', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 2),
                        Text(
                          'Add\nphoto',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.3,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
