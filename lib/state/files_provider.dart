import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

final filesProvider = NotifierProvider<FilesProviderNotifier, FileTreeNode?>(FilesProviderNotifier.new);
