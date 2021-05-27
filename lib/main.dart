import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nativeshell/nativeshell.dart';

import 'pages/platform_channels.dart';
import 'main_window.dart';
import 'pages/modal_window.dart';
import 'widgets/veil.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Veil(
        child: DefaultTextStyle(
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          child: Container(
            color: Color.fromARGB(255, 30, 30, 35),
            child: WindowWidget(
              builder: (initData) {
                WindowBuilder? builder;

                builder ??=
                    PlatformChannelsWindowBuilder.fromInitData(initData);
                builder ??= ModalWindowBuilder.fromInitData(initData);
                builder ??= MainWindowBuilder();

                return builder;
              },
            ),
          ),
        ),
      ),
    );
  }
}
