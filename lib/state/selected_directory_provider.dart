import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedDirectoryNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();

    final storedSelectedDirectory = prefs.getString("selectedDirectory");
    if (storedSelectedDirectory != null) return storedSelectedDirectory;
    prefs.setString("selectedDirectory", _getHomeDirectory());

    return _getHomeDirectory();
  }

  String _getHomeDirectory() {
    String? home = "";
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'];
    } else if (Platform.isLinux) {
      home = envVars['HOME'];
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    }
    return home ?? "";
  }

  Future<void> selectDirectory(String dir) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("selectedDirectory", dir);

    state = AsyncData(dir);
  }
}

final selectedDirectoryProvider = AsyncNotifierProvider<SelectedDirectoryNotifier, String>(SelectedDirectoryNotifier.new);
