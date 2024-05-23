import 'package:flutter/material.dart';
import 'package:tesseract_annotator/types/box.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';

class FileViewBox extends StatelessWidget {
  final TessBox initialBox;
  final bool selected;
  final void Function() onSelected;
  final void Function(TessBox box) onBoxUpdated;
  final double imageWidth;
  final double imageHeight;
  final double scale;

  const FileViewBox(this.initialBox,
      {super.key,
      required this.selected,
      required this.onSelected,
      required this.onBoxUpdated,
      required this.imageHeight,
      required this.imageWidth,
      required this.scale});

  @override
  Widget build(BuildContext context) {
    return TransformableBox(
        allowContentFlipping: false,
        allowFlippingWhileResizing: false,
        clampingRect: Rect.fromLTWH(0, 0, imageWidth, imageHeight),
        enabledHandles: selected ? {...HandlePosition.values} : {},
        visibleHandles: const {},
        handleTapSize: (1 / scale) * 24,
        onDragStart: (event) => onSelected(),
        onChanged: (result, event) {
          onBoxUpdated(TessBox(
              x: result.rect.left.toInt(),
              y: result.rect.top.toInt(),
              w: result.rect.width.toInt(),
              h: result.rect.height.toInt(),
              letter: initialBox.letter));
        },
        rect: Rect.fromLTWH(initialBox.x.toDouble(), initialBox.y.toDouble(), initialBox.w.toDouble(), initialBox.h.toDouble()),
        contentBuilder: (context, rect, flip) => GestureDetector(
              onTap: () => onSelected(),
              child: Stack(children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: (1 / scale) * 10, vertical: (1 / scale) * 3),
                  decoration: BoxDecoration(
                      color: selected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.primaryFixedDim,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular((1 / scale) * 3))),
                  child: Text(
                    initialBox.letter,
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: (1 / scale) * 14),
                  ),
                ),
                Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: selected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.primaryFixedDim,
                            width: (1 / (scale - (scale - 1.0) / 2)) * 3.0),
                        borderRadius: BorderRadius.circular((1 / scale) * 3)))
              ]),
            ));
  }
}
