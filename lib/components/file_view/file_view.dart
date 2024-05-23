import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesseract_annotator/components/file_view/file_view_box.dart';
import 'package:tesseract_annotator/state/file_provider.dart';
import 'package:collection/collection.dart';
import 'package:tesseract_annotator/state/selected_box_provider.dart';

class _FileViewBoxSelectedInfo {
  final FileViewBox box;
  final bool selected;

  const _FileViewBoxSelectedInfo(this.box, this.selected);
}

class FileView extends ConsumerStatefulWidget {
  const FileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FileViewState();
}

class _FileViewState extends ConsumerState<FileView> {
  String currentImagePath = "";
  ImageInfo? currentImageInfo;
  double zoomScale = 1.0;
  final TransformationController transformationController = TransformationController();

  _setSelectedBoxIndex(int? index) {
    ref.read(selectedBoxProvider.notifier).update(
          (state) => index,
        );
  }

  @override
  Widget build(BuildContext context) {
    final selectedFile = ref.watch(fileProvider);
    final selectedBoxIndex = ref.watch(selectedBoxProvider);
    final image = selectedFile != null ? Image.file(File(selectedFile.path)) : null;

    if (selectedFile?.path != currentImagePath) {
      currentImageInfo = null;
      image?.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((image, synchronousCall) => setState(() {
            currentImageInfo = image;
          })));

      currentImagePath = selectedFile?.path ?? "";
    }

    return GestureDetector(
        onTap: () => _setSelectedBoxIndex(null),
        child: selectedFile == null || image == null || currentImageInfo == null
            ? const Text("-")
            : InteractiveViewer(
                maxScale: 5,
                onInteractionUpdate: (details) => setState(() => zoomScale = transformationController.value.getMaxScaleOnAxis()),
                transformationController: transformationController,
                child: Center(
                    child: Container(
                        margin: const EdgeInsets.all(20),
                        child: Stack(children: [
                          image,
                          ...selectedFile.boxes
                              .mapIndexed((i, b) => _FileViewBoxSelectedInfo(
                                  FileViewBox(
                                    b,
                                    scale: zoomScale,
                                    imageHeight: currentImageInfo!.image.height.toDouble(),
                                    imageWidth: currentImageInfo!.image.width.toDouble(),
                                    selected: i == selectedBoxIndex,
                                    onSelected: () => _setSelectedBoxIndex(i),
                                    onBoxUpdated: (box) => ref.read(fileProvider.notifier).updateBox(i, box),
                                  ),
                                  i == selectedBoxIndex))
                              .sorted((a, b) => a.selected ? 1 : (b.selected ? -1 : 0))
                              .map((i) => i.box)
                        ])))));
  }
}
