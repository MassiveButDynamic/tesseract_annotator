import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedFile {
  String path;

  SelectedFile({required this.path});
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
}

final fileProvider = NotifierProvider<FileProviderNotifier, SelectedFile?>(
    FileProviderNotifier.new);
