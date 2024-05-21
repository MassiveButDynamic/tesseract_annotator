import 'dart:io';

import 'package:path/path.dart';

class FileTreeNode {
  final FileTreeNode? parent;
  final String path;
  final bool isDir;
  List<FileTreeNode> children = [];

  FileTreeNode({required this.path, required this.isDir, this.parent}) {
    children = _loadChildren();
  }

  String getFilename() {
    return basename(path);
  }

  List<FileTreeNode> _loadChildren() {
    if (File(path).statSync().type == FileSystemEntityType.directory) {
      final children = Directory(path)
          .listSync()
          .map((e) => FileTreeNode(path: e.path, isDir: File(e.path).statSync().type == FileSystemEntityType.directory, parent: this))
          .toList();
      children.sort((a, b) {
        if (a.isDir && !b.isDir) return -1;
        if (!a.isDir && b.isDir) return 1;
        return a.getFilename().compareTo(b.getFilename());
      });
      return children;
    } else {
      return [];
    }
  }
}
