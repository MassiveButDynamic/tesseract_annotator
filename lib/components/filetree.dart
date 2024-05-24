import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:tesseract_annotator/state/file_provider.dart';
import 'package:tesseract_annotator/state/files_provider.dart';
import 'package:tesseract_annotator/state/only_show_compatible_files_provider.dart';
import 'package:tesseract_annotator/state/selected_directory_provider.dart';
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

  IconData _getFileIcon(String path) {
    final ext = extension(path);
    switch (ext) {
      case ".jpg":
      case ".jpeg":
      case ".png":
        return Icons.image_outlined;

      case ".box":
        return Icons.format_shapes_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(filesProvider);

    if (files != null) {
      final previouslyToggledNodes = treeController?.toggledNodes;

      treeController = TreeController(
          roots: onlyShowCompatibleFiles
              ? files.children
                  .where((c) => c.isDir || c.pathIsCompatibleFile())
                  .toList()
              : files.children,
          childrenProvider: (FileTreeNode node) => onlyShowCompatibleFiles
              ? node.children
                  .where((c) => c.isDir || c.pathIsCompatibleFile())
                  .toList()
              : node.children,
          parentProvider: (node) => node.parent,
          defaultExpansionState: false);
      currentRootPath = files.path;
      onlyShowCompatibleFilesChanged = false;

      if (previouslyToggledNodes != null) {
        for (final pn in previouslyToggledNodes) {
          for (final match in treeController!
              .search((n) => n.path == pn.path)
              .matches
              .keys) {
            treeController!.setExpansionState(match, true);
            match.loadChildrensChildren();
          }
        }
      }
    }

    final selectedFile = ref.watch(fileProvider);

    return Ink(
        color: Colors.white,
        child: Container(
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
                                .read(selectedDirectoryProvider.notifier)
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
                                ref
                                    .read(onlyShowCompatibleFilesProvider
                                        .notifier)
                                    .update((_) => value ?? false);
                                onlyShowCompatibleFilesChanged = true;
                              })),
                      const Text("Nur kompatible Dateien"),
                    ],
                  ),
                  const Divider(),
                  ...(files != null
                      ? [
                          Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                basename(currentRootPath).toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                          Flexible(
                              child: AnimatedTreeView(
                            duration: const Duration(milliseconds: 150),
                            treeController: treeController!,
                            nodeBuilder: (BuildContext context,
                                TreeEntry<FileTreeNode> entry) {
                              return Ink(
                                  color: entry.node.path == selectedFile?.path
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.2)
                                      : null,
                                  child: Container(
                                      margin: const EdgeInsets.only(
                                          top: 3, bottom: 3),
                                      child: InkWell(
                                        onTap: () async {
                                          if (entry.node.isDir) {
                                            treeController!
                                                .toggleExpansion(entry.node);
                                            entry.node.loadChildrensChildren();
                                            ref
                                                .read(filesProvider.notifier)
                                                .listenToFileEvents();
                                          } else if (entry.node
                                              .pathIsCompatibleFile()) {
                                            await ref
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
                                                            : Icons
                                                                .chevron_right)
                                                      ]
                                                    : [
                                                        Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 5),
                                                            child: Icon(
                                                                _getFileIcon(
                                                                    entry.node
                                                                        .path)))
                                                      ]),
                                                Flexible(
                                                    child: Text(
                                                  entry.node.getFilename(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: true,
                                                ))
                                              ]),
                                        ),
                                      )));
                            },
                          ))
                        ]
                      : [const CircularProgressIndicator()])
                ])));
  }
}
