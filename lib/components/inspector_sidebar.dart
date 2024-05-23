import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesseract_annotator/state/file_provider.dart';
import 'package:tesseract_annotator/state/files_provider.dart';
import 'package:tesseract_annotator/state/selected_box_provider.dart';

class InspectorSidebar extends ConsumerStatefulWidget {
  const InspectorSidebar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InspectorSidebarState();
}

class _InspectorSidebarState extends ConsumerState<InspectorSidebar> {
  int? x, y, h, w;
  String? letter;

  _setSelectedBoxIndex(int? index) {
    ref.read(selectedBoxProvider.notifier).update(
          (state) => index,
        );
  }

  _updateBox(int selectedBoxIndex, SelectedFile selectedFile, {int? x, y, w, h, String? letter}) {
    ref
        .read(fileProvider.notifier)
        .updateBox(selectedBoxIndex, selectedFile.boxes[selectedBoxIndex].copyWith(x: x, y: y, w: w, h: h, letter: letter));
  }

  _addBox() {
    ref.read(fileProvider.notifier).addBox();
  }

  _deleteBox() {
    ref.read(fileProvider.notifier).deleteBox(ref.read(selectedBoxProvider));
  }

  _back() {
    ref.read(filesProvider.notifier).back();
  }

  _next() {
    ref.read(filesProvider.notifier).next();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFile = ref.watch(fileProvider);
    final selectedBoxIndex = ref.watch(selectedBoxProvider);

    x = selectedFile != null && selectedBoxIndex != null ? selectedFile.boxes[selectedBoxIndex].x : null;
    y = selectedFile != null && selectedBoxIndex != null ? selectedFile.boxes[selectedBoxIndex].y : null;
    w = selectedFile != null && selectedBoxIndex != null ? selectedFile.boxes[selectedBoxIndex].w : null;
    h = selectedFile != null && selectedBoxIndex != null ? selectedFile.boxes[selectedBoxIndex].h : null;
    letter = selectedFile != null && selectedBoxIndex != null ? selectedFile.boxes[selectedBoxIndex].letter : null;

    return SingleChildScrollView(
        child: Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton.icon(
                  onPressed: () => _back(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Zurück"),
                ),
                TextButton.icon(
                  onPressed: () => _next(),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Weiter"),
                  iconAlignment: IconAlignment.end,
                )
              ])),
          Row(children: [
            Expanded(
                child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: FilledButton.icon(
                        onPressed: selectedFile == null ? null : () => _addBox(),
                        icon: const Icon(Icons.add),
                        label: const Text("Neue Box"))))
          ]),
          const Divider(),
          ...(selectedBoxIndex != null && selectedFile != null
              ? [
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(children: [
                        Row(
                          children: [
                            Expanded(
                                child: TextField(
                              controller: TextEditingController(text: selectedFile.boxes[selectedBoxIndex].letter),
                              decoration: const InputDecoration(label: Text("Zeichen"), border: OutlineInputBorder()),
                              onChanged: (value) => letter = value,
                              onEditingComplete: () => _updateBox(selectedBoxIndex, selectedFile, letter: letter),
                              onTapOutside: (event) => _updateBox(selectedBoxIndex, selectedFile, letter: letter),
                            ))
                          ],
                        ),
                        Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(children: [
                              Expanded(
                                  child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      child: TextField(
                                        controller: TextEditingController(text: selectedFile.boxes[selectedBoxIndex].x.toString()),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        keyboardType: const TextInputType.numberWithOptions(),
                                        decoration: const InputDecoration(label: Text("X"), border: OutlineInputBorder()),
                                        onChanged: (value) => x = int.tryParse(value) ?? x,
                                        onEditingComplete: () => _updateBox(selectedBoxIndex, selectedFile, x: x),
                                        onTapOutside: (event) => _updateBox(selectedBoxIndex, selectedFile, x: x),
                                      ))),
                              Expanded(
                                  child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      child: TextField(
                                        controller: TextEditingController(text: selectedFile.boxes[selectedBoxIndex].y.toString()),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        keyboardType: const TextInputType.numberWithOptions(),
                                        decoration: const InputDecoration(label: Text("Y"), border: OutlineInputBorder()),
                                        onChanged: (value) => y = int.tryParse(value) ?? y,
                                        onEditingComplete: () => _updateBox(selectedBoxIndex, selectedFile, y: y),
                                        onTapOutside: (event) => _updateBox(selectedBoxIndex, selectedFile, y: y),
                                      ))),
                            ])),
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: TextField(
                                      controller: TextEditingController(text: selectedFile.boxes[selectedBoxIndex].w.toString()),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      keyboardType: const TextInputType.numberWithOptions(),
                                      decoration: const InputDecoration(label: Text("Breite"), border: OutlineInputBorder()),
                                      onChanged: (value) => w = int.tryParse(value) ?? w,
                                      onEditingComplete: () => _updateBox(selectedBoxIndex, selectedFile, w: w),
                                      onTapOutside: (event) => _updateBox(selectedBoxIndex, selectedFile, w: w),
                                    ))),
                            Expanded(
                                child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: TextField(
                                      controller: TextEditingController(text: selectedFile.boxes[selectedBoxIndex].h.toString()),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      keyboardType: const TextInputType.numberWithOptions(),
                                      decoration: const InputDecoration(label: Text("Höhe"), border: OutlineInputBorder()),
                                      onChanged: (value) => h = int.tryParse(value) ?? h,
                                      onEditingComplete: () => _updateBox(selectedBoxIndex, selectedFile, h: h),
                                      onTapOutside: (event) => _updateBox(selectedBoxIndex, selectedFile, h: h),
                                    )))
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: OutlinedButton.icon(
                                      onPressed: () => _deleteBox(),
                                      label: const Text("Box löschen"),
                                      icon: const Icon(Icons.delete),
                                      style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.error)),
                                    )))
                          ],
                        )
                      ])),
                  const Divider()
                ]
              : []),
          ...(selectedFile?.boxes
                  .mapIndexed((i, b) => ListTile(
                        onTap: () => _setSelectedBoxIndex(i),
                        selected: selectedBoxIndex == i,
                        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                        isThreeLine: true,
                        title: Row(
                          children: [const Text("Zeichen: "), Text(b.letter)],
                        ),
                        subtitle: Column(
                          children: [
                            Row(children: [
                              const Text("X: "),
                              Text(b.x.toString()),
                              const Text(", Y: "),
                              Text(b.y.toString()),
                            ]),
                            Row(
                              children: [const Text("Breite: "), Text(b.w.toString()), const Text(", Höhe: "), Text(b.h.toString())],
                            )
                          ],
                        ),
                      ))
                  .toList() ??
              [])
        ],
      ),
    ));
  }
}
