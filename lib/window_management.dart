import 'package:flutter/material.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:nativeshell_examples/button.dart';
import 'package:nativeshell_examples/page.dart';

import 'modal.dart';
import 'veil.dart';

class WindowManagementPage extends StatefulWidget {
  const WindowManagementPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WindowManagementPageState();
  }
}

class WindowManagementPageState extends State<WindowManagementPage> {
  Object? modalWindowResult;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(child: Text('Window Management Example')),
        PageSourceLocation(
            locations: ['lib/window_management.dart', 'lib/modal_window.dart']),
        PageBlurb(paragraphs: [
          'Nativeshell lets you create, show, hide, position windows, set their attributes and style. '
              'You can also show windows as modal dialogs (sheets on macOS).',
          'Windows can track content size, or be resizable with automatic minimum size, like this window.'
        ]),
        Table(
            columnWidths: {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: [
                Button(
                  onPressed: showModalDialog,
                  child: Text('Show Modal Dialog'),
                ),
                Row(
                  children: [
                    if (modalWindowResult != null) ...[
                      SizedBox(
                        width: 20,
                      ),
                      Text('Received result: '),
                      Text('$modalWindowResult')
                    ]
                  ],
                ),
              ])
            ]),
      ],
    );
  }

  void showModalDialog() async {
    final res = await Veil.show(context, () async {
      final win = await Window.create(ModalWindowBuilder.toInitData());
      return await win.showModal();
    });
    setState(() {
      modalWindowResult = res;
    });
  }
}
