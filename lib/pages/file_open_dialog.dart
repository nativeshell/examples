import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:path/path.dart';
import '../widgets/button.dart';
import '../widgets/page.dart';

final _channel = MethodChannel('file_open_dialog_channel');

class FileOpenRequest {
  FileOpenRequest({
    required this.parentWindow,
  });

  final WindowHandle parentWindow;

  Map serialize() => {
        'parentWindow': parentWindow.value,
      };
}

Future<String?> showFileOpenDialog(FileOpenRequest request) async {
  return await _channel.invokeMethod('showFileOpenDialog', request.serialize());
}

class FileOpenDialogPage extends StatefulWidget {
  const FileOpenDialogPage();

  @override
  State<StatefulWidget> createState() {
    return FileOpenDialogPageState();
  }
}

class FileOpenDialogPageState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      PageHeader(child: Text('File Open Dialog Example')),
      PageSourceLocation(locations: [
        'lib/pages/file_open_dialog.dart',
        'src/file_open_dialog.rs',
      ]),
      PageBlurb(paragraphs: [
        'This is an example of showing native platform dialog to select files. In '
            'future this should be provided directly by nativeshell itself'
      ]),
      Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Button(
                onPressed: () {
                  _selectFile(context);
                },
                child: Text('Select File...'),
              ),
              if (_selectedFileName != null) ...[
                SizedBox(height: 10),
                Text(_selectedFileName!),
              ],
            ],
          ),
        ],
      ),
    ]);
  }

  void _selectFile(BuildContext context) async {
    final request = FileOpenRequest(parentWindow: Window.of(context).handle);
    final file = await showFileOpenDialog(request);
    setState(() {
      _selectedFileName = file != null ? basename(file) : null;
      WindowState.of(context).requestUpdateConstraints();
    });
  }

  String? _selectedFileName;
}
