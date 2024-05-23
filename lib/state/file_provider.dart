import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:tesseract_annotator/state/selected_box_provider.dart';
import 'package:tesseract_annotator/types/box.dart';

class SelectedFile {
  String path;
  List<TessBox> _boxes = [];
  List<TessBox> get boxes => _boxes;

  SelectedFile({required this.path}) {
    _loadBoxes();
  }

  _loadBoxes() async {
    if (!_hasBoxFile()) return;

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
            y: int.parse(lineSegs[2]),
            w: int.parse(lineSegs[3]),
            h: int.parse(lineSegs[4])));
      }
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
    await File("${withoutExtension(path)}.box").writeAsString(_boxes
        .map((b) => "${b.letter} ${b.x} ${b.y} ${b.w} ${b.h} 0")
        .join("\n"));
  }

  Future<TessBox> addBox({int? x, int? y}) async {
    final box = TessBox(x: x ?? 0, y: y ?? 0, w: 50, h: 50, letter: "A");
    _boxes.add(box);
    await _saveBoxes();
    return box;
  }

  Future<void> deleteBox(int index) async {
    _boxes.removeAt(index);
    await _saveBoxes();
  }
}

class FileProviderNotifier extends Notifier<SelectedFile?> {
  @override
  SelectedFile? build() {
    return null;
  }

  void selectFile(String path) {
    state = SelectedFile(path: path);
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
