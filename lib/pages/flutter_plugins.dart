import 'package:flutter/material.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:nativeshell_examples/widgets/button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/page.dart';

class FlutterPluginsPage extends StatefulWidget {
  const FlutterPluginsPage();

  @override
  State<StatefulWidget> createState() {
    return FlutterPluginsPageState();
  }
}

class FlutterPluginsPageState extends State<FlutterPluginsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      PageHeader(child: Text('Flutter Plugins Example')),
      PageSourceLocation(locations: [
        'lib/pages/flutter_plugins.dart',
      ]),
      PageBlurb(paragraphs: [
        'NativeShell support Flutter plugins (packages containing native code).'
      ]),
      Row(
        children: [
          Button(
            onPressed: () async {
              await launch('https://nativeshell.dev');
            },
            child: Text('Open URL'),
          )
        ],
      ),
      if (documentsDirectory != null) ...[
        SizedBox(height: 10),
        Text('Documents Directory: $documentsDirectory'),
      ],
      if (packageName != null) ...[
        SizedBox(height: 10),
        Text('Package: $packageName'),
      ]
    ]);
  }

  @override
  void initState() {
    super.initState();
    doStuff();
  }

  void doStuff() async {
    final docDir = await getApplicationDocumentsDirectory();
    final info = await PackageInfo.fromPlatform();

    setState(() {
      documentsDirectory = docDir.path;
      packageName = info.packageName;
      WindowState.of(context).requestUpdateConstraints();
    });
  }

  String? documentsDirectory;
  String? packageName;
}
