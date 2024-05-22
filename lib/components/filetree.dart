import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:tesseract_annotator/state/file_provider.dart';
import 'package:tesseract_annotator/state/files_provider.dart';
import 'package:tesseract_annotator/types/filetree_node.dart';

class Filetree extends ConsumerStatefulWidget {
  const Filetree({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FiletreeState();
}

class _FiletreeState extends ConsumerState<Filetree> {
  bool onlyShowCompatibleFiles = true;
  bool onlyShowCompatibleFilesChanged = false;
  TreeController<FileTreeNode>? treeController;
  String currentRootPath = "";

  bool _pathIsCompatibleFile(String path) {
    return path.endsWith("jpg") ||
        path.endsWith("jpeg") ||
        path.endsWith("png") ||
        path.endsWith("tif");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(filesProvider);

    if (treeController == null ||
        files.path != currentRootPath ||
        onlyShowCompatibleFilesChanged) {
      treeController = TreeController(
          roots: onlyShowCompatibleFiles
              ? files.children
                  .where((c) => c.isDir || _pathIsCompatibleFile(c.path))
                  .toList()
              : files.children,
          childrenProvider: (FileTreeNode node) => onlyShowCompatibleFiles
              ? node.children
                  .where((c) => c.isDir || _pathIsCompatibleFile(c.path))
                  .toList()
              : node.children,
          parentProvider: (node) => node.parent,
          defaultExpansionState: false);
      currentRootPath = files.path;
      onlyShowCompatibleFilesChanged = false;
    }

    final selectedFile = ref.watch(fileProvider);

    return Ink(
        color: Colors.white,
        child: Container(
            // color: Colors.white,
            padding: const EdgeInsets.all(15),
            child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final newFilePath = await FilePicker.platform
                              .getDirectoryPath(
                                  dialogTitle: "Ordner auswählen",
                                  initialDirectory: currentRootPath);
                          if (newFilePath != null) {
                            ref
                                .read(filesProvider.notifier)
                                .selectDirectory(newFilePath);
                            ref.read(fileProvider.notifier).unselectFile();
                          }
                        },
                        icon: const Icon(Icons.folder_outlined),
                        label: const Text("Ordner wechseln"),
                      )),
                  Row(
                    children: [
                      Checkbox(
                          value: onlyShowCompatibleFiles,
                          onChanged: (value) => setState(() {
                                onlyShowCompatibleFiles = value ?? false;
                                onlyShowCompatibleFilesChanged = true;
                              })),
                      const Text("Nur kompatible Dateien"),
                    ],
                  ),
                  const Divider(),
                  Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        basename(currentRootPath).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Flexible(
                      child: AnimatedTreeView(
                    duration: const Duration(milliseconds: 150),
                    treeController: treeController!,
                    nodeBuilder:
                        (BuildContext context, TreeEntry<FileTreeNode> entry) {
                      return Ink(
                          color: entry.node.path == selectedFile?.path
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : null,
                          child: Container(
                              margin: const EdgeInsets.only(top: 3, bottom: 3),
                              child: InkWell(
                                onTap: () {
                                  if (entry.node.isDir) {
                                    treeController!.toggleExpansion(entry.node);
                                    entry.node.loadChildrensChildren();
                                  } else if (_pathIsCompatibleFile(
                                      entry.node.path)) {
                                    ref
                                        .read(fileProvider.notifier)
                                        .selectFile(entry.node.path);
                                  }
                                },
                                child: TreeIndentation(
                                  entry: entry,
                                  child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        ...(entry.node.isDir
                                            ? [
                                                Icon(entry.isExpanded
                                                    ? Icons.expand_more
                                                    : Icons.chevron_right)
                                              ]
                                            : [
                                                Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 5),
                                                    child: const Icon(Icons
                                                        .description_outlined))
                                              ]),
                                        Flexible(
                                            child: Text(
                                          entry.node.getFilename(),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ))
                                      ]),
                                ),
                              )));
                    },
                  ))
                ])));
  }
}
