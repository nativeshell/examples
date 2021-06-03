import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:nativeshell_examples/widgets/button.dart';

class OtherWindowContext extends WindowContext {
  @override
  Widget build(BuildContext context) {
    return OtherWindow();
  }

  @override
  Future<void> initializeWindow(Size intrinsicContentSize) async {
    // If possible, show the window to the right of parent window
    Offset? origin;
    final parentGeometry = await window.parentWindow?.getGeometry();
    if (parentGeometry?.frameOrigin != null &&
        parentGeometry?.frameSize != null) {
      origin = parentGeometry!.frameOrigin!
          .translate(parentGeometry.frameSize!.width + 20, 0);
    }
    await window.setGeometry(Geometry(
      frameOrigin: origin,
      contentSize: intrinsicContentSize,
    ));
    await window.setStyle(WindowStyle(canResize: false));
    await window.show();
  }

  @override
  bool get autoSizeWindow => true;

  static dynamic toInitData() => {
        'class': 'otherWindow',
      };

  static OtherWindowContext? fromInitData(dynamic initData) {
    if (initData is Map && initData['class'] == 'otherWindow') {
      return OtherWindowContext();
    }
    return null;
  }
}

class OtherWindow extends StatefulWidget {
  const OtherWindow();

  @override
  State<StatefulWidget> createState() {
    return _OtherWindowState();
  }
}

class _OtherWindowState extends State<OtherWindow>
    with WindowMethodCallHandlerMixin<OtherWindow> {
  @override
  Widget build(BuildContext context) {
    // can't call Window.of(context) in initState
    if (firstBuild) {
      firstBuild = false;

      // Disable the button when parent window gets closed
      Window.of(context).parentWindow?.closeEvent.addListener(() {
        setState(() {});
      });
    }

    return Container(
      color: Colors.blueGrey.shade50,
      padding: EdgeInsets.all(20),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: Colors.black),
        child: Column(
          children: [
            Button(
              onPressed: Window.of(context).parentWindow != null
                  ? callMethodOnParentWindow
                  : null,
              child: Text(
                'Call method on parent window',
              ),
            ),
            if (messageFromParentWindow != null) ...[
              SizedBox(height: 15),
              Text('Parent window says:'),
              SizedBox(height: 5),
              Text('$messageFromParentWindow'),
            ]
          ],
        ),
      ),
    );
  }

  void callMethodOnParentWindow() async {
    await Window.of(context).parentWindow?.callMethod('showMessage', 'Hello');
  }

  bool firstBuild = true;

  String? messageFromParentWindow;

  @override
  MethodCallHandler? onMethodCall(String method) {
    if (method == 'showMessage') {
      return showMessage;
    } else {
      return null;
    }
  }

  void showMessage(dynamic message) {
    setState(() {
      messageFromParentWindow = message;
    });
  }
}
