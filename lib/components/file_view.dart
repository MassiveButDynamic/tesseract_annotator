import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesseract_annotator/state/file_provider.dart';

class FileView extends ConsumerWidget {
  const FileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilePath = ref.watch(fileProvider);
    return selectedFilePath == null
        ? const Text("-")
        : InteractiveViewer(
            maxScale: 5, child: Image.file(File(selectedFilePath.path)));
  }
}
