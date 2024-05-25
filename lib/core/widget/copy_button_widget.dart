import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:sanitary_mart/core/app_util.dart';

class CopyIconButton extends StatelessWidget {
  const CopyIconButton(this.content, {super.key});

  final String content;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          FlutterClipboard.copy(content)
              .then((value) => AppUtil.showToast('Copied'));
        },
        icon: const Icon(Icons.copy));
  }
}
