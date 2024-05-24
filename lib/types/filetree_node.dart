import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
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
          .sorted((a, b) => a.path.compareTo(b.path))
          .map((e) => FileTreeNode(
              path: e.path,
              isDir: File(e.path).statSync().type ==
                  FileSystemEntityType.directory,
              parent: this))
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
    return path.endsWith("jpg") ||
        path.endsWith("jpeg") ||
        path.endsWith("png");
  }

  RecursiveSubscription listenToFileEvents(void Function() callback) {
    final rootSubscription =
        Directory(path).watch(recursive: true).listen((_) => callback());
    List<RecursiveSubscription> childSubscriptions = [];

    if (isDir) {
      for (final child in children) {
        childSubscriptions.add(child.listenToFileEvents(callback));
      }
    }

    return RecursiveSubscription(
        rootSubscription: rootSubscription,
        childSubscriptions: childSubscriptions);
  }
}

class RecursiveSubscription {
  final StreamSubscription rootSubscription;
  final List<RecursiveSubscription> childSubscriptions;

  const RecursiveSubscription(
      {required this.rootSubscription, required this.childSubscriptions});

  void cancel() {
    rootSubscription.cancel();
    for (final child in childSubscriptions) {
      child.cancel();
    }
  }
}
