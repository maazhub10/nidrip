import 'package:flutter/material.dart';

import 'flashy_loader.dart';

void showLoadingDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return const Center(
        child: FlashyLoader(size: 60),
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  final nav = Navigator.of(context, rootNavigator: true);
  if (nav.canPop()) {
    nav.pop();
  }
}
