import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nativeshell/nativeshell.dart';

import 'pages/other_window.dart';
import 'pages/platform_channels.dart';
import 'main_window.dart';
import 'pages/modal_window.dart';
import 'widgets/veil.dart';

void main() async {
  // Disable shader warmup - it delays producing first frame, which we want to
  // produce as soon as possible to reduce time to open new windows.
  disableShaderWarmUp();
  runApp(Main());
}

// Common scaffold code used by each window
class ExamplesWindow extends StatelessWidget {
  const ExamplesWindow({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        child: WindowLayoutProbe(child: child),
      ),
    );
  }
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Veil(
      child: Container(
        color: Color.fromARGB(255, 30, 30, 35),
        child: WindowWidget(
          onCreateState: (initData) {
            WindowState? state;

            state ??= PlatformChannelsWindowState.fromInitData(initData);
            state ??= ModalWindowState.fromInitData(initData);
            state ??= OtherWindowState.fromInitData(initData);
            state ??= MainWindowState();

            return state;
          },
        ),
      ),
    );
  }
}
