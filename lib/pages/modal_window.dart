import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nativeshell/nativeshell.dart';

import '../main.dart';
import '../widgets/animated_visibility.dart';
import '../widgets/button.dart';
import '../widgets/page.dart';

class ModalWindowState extends WindowState {
  @override
  Widget build(BuildContext context) {
    return ExamplesWindow(child: ModalWindow());
  }

  static ModalWindowState? fromInitData(dynamic initData) {
    if (initData is Map && initData['class'] == 'modalWindow') {
      return ModalWindowState();
    }
    return null;
  }

  static dynamic toInitData() => {
        'class': 'modalWindow',
      };

  @override
  WindowSizingMode get windowSizingMode => WindowSizingMode.sizeToContents;

  @override
  Future<void> initializeWindow(Size intrinsicContentSize) async {
    await window.setStyle(WindowStyle(canResize: false));
    await window.setGeometry(await centerInParent(intrinsicContentSize));
    await window.show();
  }
}

class ModalWindow extends StatelessWidget {
  const ModalWindow();

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(color: Colors.grey.shade900),
      child: Container(
        padding: EdgeInsets.all(24),
        color: Colors.white,
        child: Column(
          // This is necessary when using autoSizeWindow, as there are no
          // incoming constraints from the window itself
          mainAxisSize: MainAxisSize.min,
          children: [
            PageBlurb(paragraphs: [
              'This is a Modal Dialog. It is sized to fit.',
              'Pick the result:'
            ]),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Button(
                  onPressed: () {
                    // Result can be anything serializable with StandardMethodCodec
                    Window.of(context).closeWithResult(true);
                  },
                  child: Text('Yes'),
                ),
                SizedBox(
                  width: 10,
                ),
                Button(
                  onPressed: () {
                    Window.of(context).closeWithResult(false);
                  },
                  child: Text('No'),
                ),
              ],
            ),
            SizedBox(height: 10),
            ExtraOptions(),
          ],
        ),
      ),
    );
  }
}

class ExtraOptions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ExtraOptionsState();
  }
}

class ExtraOptionsState extends State<ExtraOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
            onPressed: () {
              setState(() {
                extraOptionsVisible = !extraOptionsVisible;
              });
            },
            child: !extraOptionsVisible
                ? Text('Show more options...')
                : Text('Hide more options')),
        AnimatedVisibility(
            visible: extraOptionsVisible,
            alignment: Alignment.topCenter,
            duration: Duration(milliseconds: 200),
            direction: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Button(
                onPressed: () {
                  Window.of(context).closeWithResult('Maybe');
                },
                child: Text('Maybe'),
              ),
            )),
      ],
    );
  }

  bool extraOptionsVisible = false;
}
