import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesseract_annotator/state/files_provider.dart';
import 'package:tesseract_annotator/types/filetree_node.dart';

class Filetree extends ConsumerWidget {
  const Filetree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(filesProvider);
    final treeController = TreeController(
        roots: files,
        childrenProvider: (FileTreeNode node) => node.children,
        parentProvider: (node) => node.parent,
        defaultExpansionState: false);

    return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(15),
        child: AnimatedTreeView(
          duration: const Duration(milliseconds: 50),
          treeController: treeController,
          nodeBuilder: (BuildContext context, TreeEntry<FileTreeNode> entry) {
            return InkWell(
              onTap: () => treeController.toggleExpansion(entry.node),
              child: TreeIndentation(
                entry: entry,
                child: Row(mainAxisSize: MainAxisSize.max, children: [
                  ...(entry.node.isDir
                      ? [Icon(entry.isExpanded ? Icons.expand_more : Icons.chevron_right)]
                      : [const Icon(Icons.text_snippet)]),
                  Flexible(
                      child: Text(
                    entry.node.getFilename(),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ))
                ]),
              ),
            );
          },
        ));
  }
}
