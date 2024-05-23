import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesseract_annotator/types/filetree_node.dart';

class FilesProviderNotifier extends Notifier<FileTreeNode> {
  @override
  FileTreeNode build() {
    const path = "/home/moritz/Entwicklung/bodi/fahrzeugscheine/boxes";
    final rootNode = FileTreeNode(
        path: path,
        isDir: File(path).statSync().type == FileSystemEntityType.directory);
    rootNode.loadChildren();
    rootNode.loadChildrensChildren();
    return rootNode;
  }

  void selectDirectory(String path) {
    final rootNode = FileTreeNode(
        path: path,
        isDir: File(path).statSync().type == FileSystemEntityType.directory);
    rootNode.loadChildren();
    rootNode.loadChildrensChildren();
    state = rootNode;
  }
}

final filesProvider = NotifierProvider<FilesProviderNotifier, FileTreeNode>(
    FilesProviderNotifier.new);
