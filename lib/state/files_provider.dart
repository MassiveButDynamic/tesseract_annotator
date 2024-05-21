import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesseract_annotator/types/filetree_node.dart';

class FilesProviderNotifier extends Notifier<List<FileTreeNode>> {
  @override
  List<FileTreeNode> build() {
    const path = "/media/moritz/Shared/Entwicklung/bodi-fahrzeugscheine/tesseract";
    return FileTreeNode(path: path, isDir: File(path).statSync().type == FileSystemEntityType.directory).children;
  }
}

final filesProvider = NotifierProvider<FilesProviderNotifier, List<FileTreeNode>>(FilesProviderNotifier.new);
