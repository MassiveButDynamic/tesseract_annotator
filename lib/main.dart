import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesseract_annotator/components/file_view/file_view.dart';
import 'package:tesseract_annotator/components/filetree.dart';
import 'package:tesseract_annotator/components/inspector_sidebar.dart';
import 'package:tesseract_annotator/state/file_provider.dart';
import 'package:tesseract_annotator/state/files_provider.dart';
import 'package:tesseract_annotator/state/selected_box_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    ));
  }
}

class MyHomePage extends ConsumerWidget {
  _addBox(WidgetRef ref) {
    ref.read(fileProvider.notifier).addBox();
  }

  _deleteBox(WidgetRef ref) {
    ref.read(fileProvider.notifier).deleteBox(ref.read(selectedBoxProvider));
  }

  _back(WidgetRef ref) {
    ref.read(filesProvider.notifier).back();
  }

  _next(WidgetRef ref) {
    ref.read(filesProvider.notifier).next();
  }

  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: CallbackShortcuts(
            bindings: {
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA): () => _addBox(ref),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyD): () => _deleteBox(ref),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyQ): () => _back(ref),
              LogicalKeySet(LogicalKeyboardKey.arrowLeft): () => _back(ref),
              LogicalKeySet(LogicalKeyboardKey.arrowUp): () => _back(ref),
              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE): () => _next(ref),
              LogicalKeySet(LogicalKeyboardKey.arrowRight): () => _next(ref),
              LogicalKeySet(LogicalKeyboardKey.arrowDown): () => _next(ref),
            },
            child: FocusScope(
              autofocus: true,
              child: ResizableContainer(
                  divider: const ResizableDivider(color: Colors.white, size: 10, thickness: 10),
                  controller: ResizableController(data: const [
                    ResizableChildData(minSize: 100, startingRatio: 0.2),
                    ResizableChildData(),
                    ResizableChildData(startingRatio: 0.2)
                  ]),
                  direction: Axis.horizontal,
                  children: [const Filetree(), const FileView(), Ink(color: Colors.white, child: const InspectorSidebar())]),
            )));
  }
}
