import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesseract_annotator/state/file_provider.dart';
import 'package:tesseract_annotator/state/only_show_compatible_files_provider.dart';
import 'package:tesseract_annotator/state/selected_directory_provider.dart';
import 'package:tesseract_annotator/types/filetree_node.dart';

class FilesProviderNotifier extends Notifier<FileTreeNode?> {
  @override
  FileTreeNode? build() {
    final path = ref.watch(selectedDirectoryProvider);

    if (!path.hasValue) {
      return null;
    }

    final rootNode = FileTreeNode(path: path.value!, isDir: File(path.value!).statSync().type == FileSystemEntityType.directory);
    rootNode.loadChildren();
    rootNode.loadChildrensChildren();
    return rootNode;
  }

  List<FileTreeNode> _getSelectableChildren() {
    return state == null ? [] : state!.children.where((c) => c.pathIsCompatibleFile()).toList();
  }

  int? _findCurrentIndex(List<FileTreeNode> selectableChildren) {
    final selectedFile = ref.read(fileProvider);
    if (selectedFile == null) return null;

    return selectableChildren.indexWhere((n) => n.path == selectedFile.path);
  }

  void next() {
    final selectableChildren = _getSelectableChildren();
    final currentIndex = _findCurrentIndex(selectableChildren);
    if (currentIndex == null) return;

    if (currentIndex >= selectableChildren.length) return;
    ref.read(fileProvider.notifier).selectFile(selectableChildren[currentIndex + 1].path);
  }

  void back() {
    final selectableChildren = _getSelectableChildren();
    final currentIndex = _findCurrentIndex(selectableChildren);
    if (currentIndex == null) return;

    if (currentIndex <= 0) return;
    ref.read(fileProvider.notifier).selectFile(selectableChildren[currentIndex - 1].path);
  }
}

final filesProvider = NotifierProvider<FilesProviderNotifier, FileTreeNode?>(FilesProviderNotifier.new);
