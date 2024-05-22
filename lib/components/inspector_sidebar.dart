import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InspectorSidebar extends ConsumerStatefulWidget {
  const InspectorSidebar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InspectorSidebarState();
}

class _InspectorSidebarState extends ConsumerState<InspectorSidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: const Column(
        children: [Text("Hey")],
      ),
    );
  }
}
