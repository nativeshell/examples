import 'package:flutter/material.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:nativeshell_examples/pages/other_window.dart';

import 'modal_window.dart';
import '../widgets/veil.dart';
import '../widgets/button.dart';
import '../widgets/page.dart';

class WindowManagementPage extends StatefulWidget {
  const WindowManagementPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WindowManagementPageState();
  }
}

class WindowManagementPageState extends State<WindowManagementPage>
    with WindowMethodCallHandlerMixin<WindowManagementPage> {
  Object? modalWindowResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(child: Text('Window Management Example')),
        PageSourceLocation(locations: [
          'lib/pages/window_management.dart',
          'lib/pages/modal_window.dart'
        ]),
        PageBlurb(paragraphs: [
          'NativeShell lets you create, show, hide, position windows, set their attributes and style. '
              'You can also show windows as modal dialogs (sheets on macOS).',
          'Windows can track content size, or be resizable with automatic minimum size, like this window.'
        ]),
        Table(
            columnWidths: {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              TableRow(children: [
                Button(
                  onPressed: showModalDialog,
                  child: Text('Show Modal Dialog'),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Row(
                    children: [
                      if (modalWindowResult != null) ...[
                        SizedBox(
                          width: 10,
                        ),
                        Text('Received result: '),
                        Text('$modalWindowResult')
                      ]
                    ],
                  ),
                ),
              ]),
              TableRow(children: [SizedBox(height: 10), Container()]),
              TableRow(children: [
                otherWindow == null
                    ? Button(
                        onPressed: showOtherWindow,
                        child: Text('Show Other Window'),
                      )
                    : Button(
                        onPressed: closeOtherWindow,
                        child: Text('Hide Other Window'),
                      ),
                Row(children: [
                  SizedBox(
                    width: 10,
                  ),
                  if (otherWindow != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Button(
                          onPressed: callMethodOnOtherWindow,
                          child: Text('Call Method'),
                        ),
                        if (messageFromOtherWindow != null) ...[
                          SizedBox(height: 10),
                          Text('Other window says: $messageFromOtherWindow'),
                        ]
                      ],
                    )
                ]),
              ]),
            ]),
      ],
    );
  }

  Window? otherWindow;
  String? messageFromOtherWindow;

  void showOtherWindow() async {
    // use veil to prevent double events while waiting for window to initialize
    await Veil.show(context, () async {
      final window = await Window.create(OtherWindowState.toInitData());
      setState(() {
        otherWindow = window;
      });

      // get notification when user closes other window
      window.closeEvent.addListener(() {
        // when hiding window from dispose the close event will be fired, but
        // but at that point we're not mounted anymore
        if (mounted) {
          setState(() {
            otherWindow = null;
            messageFromOtherWindow = null;
          });
        }
      });
    });
  }

  void closeOtherWindow() async {
    await otherWindow?.close();
    setState(() {
      otherWindow = null;
      messageFromOtherWindow = null;
    });
  }

  void callMethodOnOtherWindow() async {
    await otherWindow?.callMethod('showMessage', 'Hello from parent window!');
  }

  // handles method call on this window
  @override
  MethodCallHandler? onMethodCall(String name) {
    if (name == 'showMessage') {
      return showMessage;
    } else {
      return null;
    }
  }

  void showMessage(dynamic arguments) {
    setState(() {
      messageFromOtherWindow = arguments;
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    WindowState.of(context).requestUpdateConstraints();
  }

  @override
  void dispose() {
    otherWindow?.close();
    super.dispose();
  }

  //
  // Modal Window
  //

  void showModalDialog() async {
    final res = await Veil.show(context, () async {
      final win = await Window.create(ModalWindowState.toInitData());
      return await win.showModal();
    });
    setState(() {
      modalWindowResult = res;
    });
  }
}
