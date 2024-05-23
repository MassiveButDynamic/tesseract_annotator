import 'dart:io';

import 'package:path/path.dart';

class FileTreeNode {
  final FileTreeNode? parent;
  final String path;
  final bool isDir;
  List<FileTreeNode>? _children;

  List<FileTreeNode> get children {
    return _children ?? [];
  }

  FileTreeNode({required this.path, required this.isDir, this.parent});

  String getFilename() {
    return basename(path);
  }

  List<FileTreeNode> loadChildren() {
    if (_children != null) {
      return _children!;
    }

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

  void loadChildrensChildren() {
    _children ??= loadChildren();

    for (var n in _children!) {
      n.loadChildren();
    }
  }

  bool pathIsCompatibleFile() {
    return path.endsWith("jpg") || path.endsWith("jpeg") || path.endsWith("png");
  }
}
