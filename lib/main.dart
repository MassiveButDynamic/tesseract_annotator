import 'package:flutter/material.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesseract_annotator/components/file_view/file_view.dart';
import 'package:tesseract_annotator/components/filetree.dart';
import 'package:tesseract_annotator/components/inspector_sidebar.dart';

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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: ResizableContainer(
          divider: const ResizableDivider(
              color: Colors.white, size: 10, thickness: 10),
          controller: ResizableController(data: const [
            ResizableChildData(minSize: 100, startingRatio: 0.2),
            ResizableChildData(),
            ResizableChildData(startingRatio: 0.2)
          ]),
          direction: Axis.horizontal,
          children: [
            const Filetree(),
            const FileView(),
            Ink(color: Colors.white, child: const InspectorSidebar())
          ]),
    );
  }
}
