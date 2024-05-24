import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:tesseract_annotator/state/selected_box_provider.dart';
import 'package:tesseract_annotator/types/box.dart';

class SelectedFile {
  String path;
  List<TessBox> _boxes = [];
  List<TessBox> get boxes => _boxes;
  final void Function()? onLoaded;

  Image? image;
  ImageInfo? imageInfo;

  SelectedFile({required this.path, this.onLoaded});

  _loadBoxes() async {
    if (!_hasBoxFile()) return;
    if (image == null || imageInfo == null) return;

    _boxes = [];
    final lines = await File("${withoutExtension(path)}.box").readAsLines();

    for (final line in lines) {
      final lineSegs = line.split(" ");
      if (lineSegs.length > 5 &&
          int.tryParse(lineSegs[1]) != null &&
          int.tryParse(lineSegs[2]) != null &&
          int.tryParse(lineSegs[3]) != null &&
          int.tryParse(lineSegs[4]) != null) {
        _boxes.add(TessBox(
            letter: lineSegs[0],
            x: int.parse(lineSegs[1]),
            y: imageInfo!.image.height - int.parse(lineSegs[4]),
            w: int.parse(lineSegs[3]) - int.parse(lineSegs[1]),
            h: int.parse(lineSegs[4]) - int.parse(lineSegs[2])));
      }
    }

    if (onLoaded != null) {
      onLoaded!();
    }
  }

  bool _hasBoxFile() {
    return File("${withoutExtension(path)}.box").existsSync();
  }

  Future<void> updateBox(int index, TessBox box) async {
    _boxes[index] = box;
    await _saveBoxes();
  }

  Future<void> _saveBoxes() async {
    if (image == null || imageInfo == null) return;

    await File("${withoutExtension(path)}.box").writeAsString(_boxes
        .map((b) =>
            "${b.letter} ${b.x} ${imageInfo!.image.height - (b.y + b.h)} ${b.x + b.w} ${imageInfo!.image.height - b.y} 0")
        .join("\n"));
  }

  Future<TessBox> addBox({int? x, int? y}) async {
    final box = TessBox(x: x ?? 0, y: y ?? 0, w: 20, h: 20, letter: "A");
    _boxes.add(box);
    await _saveBoxes();
    return box;
  }

  Future<void> deleteBox(int index) async {
    _boxes.removeAt(index);
    await _saveBoxes();
  }

  bool pathIsCompatibleFile() {
    return path.endsWith("jpg") ||
        path.endsWith("jpeg") ||
        path.endsWith("png");
  }

  Future<void> loadImageInfo() async {
    final newImage = pathIsCompatibleFile() ? Image.file(File(path)) : null;

    final imageInfoCompleter = Completer<ImageInfo>();
    newImage?.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
            (info, synchronousCall) => imageInfoCompleter.complete(info)));

    imageInfo = await imageInfoCompleter.future;
    image = newImage;

    try {
      _loadBoxes();
    } catch (error) {
      print("Error loading boxes: $error");
    }
  }
}

class FileProviderNotifier extends Notifier<SelectedFile?> {
  @override
  SelectedFile? build() {
    return null;
  }

  Future<void> selectFile(String path) async {
    ref.read(selectedBoxProvider.notifier).update((_) => null);
    final newFile =
        SelectedFile(path: path, onLoaded: () => ref.notifyListeners());
    await newFile.loadImageInfo();
    state = newFile;
  }

  void unselectFile() {
    state = null;
  }

  void updateBox(int index, TessBox box) async {
    await state?.updateBox(index, box);
    ref.notifyListeners();
  }

  void addBox({int? x, int? y}) async {
    await state?.addBox(x: x, y: y);
    ref
        .read(selectedBoxProvider.notifier)
        .update((_) => state != null ? state!.boxes.length - 1 : null);
    ref.notifyListeners();
  }

  void deleteBox(int? index) async {
    if (index == null) return;

    await state?.deleteBox(index);
    if (ref.read(selectedBoxProvider) == index) {
      ref.read(selectedBoxProvider.notifier).update((_) => null);
    }
    ref.notifyListeners();
  }
}

final fileProvider = NotifierProvider<FileProviderNotifier, SelectedFile?>(
    FileProviderNotifier.new);
