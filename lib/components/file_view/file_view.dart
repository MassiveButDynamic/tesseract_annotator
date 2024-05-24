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

  double zoomScale = 1.0;
  TransformationController transformationController =
      TransformationController();
  Key stackKey = UniqueKey();

  _setSelectedBoxIndex(int? index) {
    ref.read(selectedBoxProvider.notifier).update(
          (state) => index,
        );
  }

  @override
  Widget build(BuildContext context) {
    final selectedFile = ref.watch(fileProvider);
    final selectedBoxIndex = ref.watch(selectedBoxProvider);

    stackKey = selectedFile != null ? Key(selectedFile.path) : UniqueKey();
    if (selectedFile?.path != currentImagePath) {
      transformationController = TransformationController();
      currentImagePath = selectedFile?.path ?? "";
    }

    return GestureDetector(
        onTap: () => _setSelectedBoxIndex(null),
        child: selectedFile == null
            ? const Center(child: Text("Keine Datei ausgewählt"))
            : (selectedFile.image != null && selectedFile.imageInfo != null
                ? InteractiveViewer(
                    minScale: 0.002,
                    maxScale: 5,
                    boundaryMargin: const EdgeInsets.all(1000),
                    constrained: false,
                    onInteractionUpdate: (details) => setState(() => zoomScale =
                        transformationController.value.getMaxScaleOnAxis()),
                    transformationController: transformationController,
                    child: Center(
                        child: Container(
                            margin: const EdgeInsets.all(20),
                            child: Stack(key: stackKey, children: [
                              selectedFile.image!,
                              ...selectedFile.boxes
                                  .mapIndexed(
                                      (i, b) => _FileViewBoxSelectedInfo(
                                          FileViewBox(
                                            b,
                                            scale: zoomScale,
                                            imageHeight: selectedFile
                                                .imageInfo!.image.height
                                                .toDouble(),
                                            imageWidth: selectedFile
                                                .imageInfo!.image.width
                                                .toDouble(),
                                            selected: i == selectedBoxIndex,
                                            onSelected: () =>
                                                _setSelectedBoxIndex(i),
                                            onBoxUpdated: (box) => ref
                                                .read(fileProvider.notifier)
                                                .updateBox(i, box),
                                          ),
                                          i == selectedBoxIndex))
                                  .sorted((a, b) =>
                                      a.selected ? 1 : (b.selected ? -1 : 0))
                                  .map((i) => i.box)
                            ]))))
                : const Center(child: CircularProgressIndicator())));
  }
}
