import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nativeshell/nativeshell.dart';

import '../widgets/button.dart';
import '../widgets/page.dart';

final _channel = MethodChannel('example_channel');

class PlatformChannelsPage extends StatefulWidget {
  const PlatformChannelsPage();

  @override
  State<PlatformChannelsPage> createState() => _PlatformChannelsPageState();
}

class _PlatformChannelsPageState extends State<PlatformChannelsPage> {
  Object? helloReply;
  Object? backgroundTaskReply;
  bool backgroundTaskInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(child: Text('Platform Channels Example')),
        PageSourceLocation(locations: [
          'lib/pages/platform_channels.dart',
          'src/platform_channels.rs'
        ]),
        PageBlurb(paragraphs: [
          'Nativeshell provides consistent platform agnostic API to register platform channel handlers.',
          'You only need to register handler once and it can be called from any isolate (window).'
        ]),
        Table(
          columnWidths: {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                Button(
                  onPressed: onHello,
                  child: Text('Echo: Send \'Hello\''),
                ),
                Row(
                  children: [
                    if (helloReply != null) ...[
                      SizedBox(
                        width: 20,
                      ),
                      Text('Received reply: '),
                      Text('$helloReply')
                    ]
                  ],
                )
              ],
            ),
            TableRow(children: [SizedBox(height: 10), Container()]),
            TableRow(children: [
              Button(
                onPressed: backgroundTaskInProgress ? null : onBackgroundTask,
                child: Text('Long Running Task'),
              ),
              Row(
                children: [
                  SizedBox(width: 20),
                  if (backgroundTaskInProgress) CupertinoActivityIndicator(),
                  if (backgroundTaskReply != null) ...[
                    Text('Received reply: '),
                    Text('$backgroundTaskReply')
                  ],
                ],
              )
            ]),
            TableRow(children: [SizedBox(height: 10), Container()]),
            TableRow(children: [
              Button(
                onPressed: onOpenWindow,
                child: Text('Open in New Window'),
              ),
              Container(),
            ])
          ],
        ),
      ],
    );
  }

  void onHello() async {
    final reply = await _channel.invokeMethod('echo', 'Hello');
    setState(() {
      WindowContext.of(context).requestUpdateConstraints();
      helloReply = reply;
    });
  }

  void onBackgroundTask() async {
    setState(() {
      backgroundTaskReply = null;
      backgroundTaskInProgress = true;
    });
    final reply = await _channel.invokeMethod('backgroundTask');
    setState(() {
      backgroundTaskInProgress = false;
      backgroundTaskReply = reply;
      WindowContext.of(context).requestUpdateConstraints();
    });
  }

  void onOpenWindow() async {
    await Window.create(PlatformChannelsWindowBuilder.toInitData());
  }
}

class PlatformChannelsWindowBuilder extends WindowBuilder {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: IntrinsicWidth(child: PlatformChannelsPage()),
    );
  }

  @override
  Future<void> initializeWindow(
      LocalWindow win, Size intrinsicContentSize) async {
    await win.setStyle(WindowStyle(canResize: false));
    final geometry = await centerInParent(win, intrinsicContentSize);
    // translate the window slightly. it may have same size as parent window
    // so centering it looks weird
    await win.setGeometry(geometry.translate(20, 20));
    await win.show();
  }

  @override
  bool get autoSizeWindow => true;

  static dynamic toInitData() => {
        'class': 'platformChannelsWindow',
      };

  static PlatformChannelsWindowBuilder? fromInitData(dynamic initData) {
    if (initData is Map && initData['class'] == 'platformChannelsWindow') {
      return PlatformChannelsWindowBuilder();
    }
    return null;
  }
}
