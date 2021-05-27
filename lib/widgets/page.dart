import 'package:flutter/material.dart';
import '../util.dart';
import 'intrinsic_limited_box.dart';

class PageContainer extends StatelessWidget {
  const PageContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      color: Colors.grey.shade100,
      child: DefaultTextStyle.merge(
          style: TextStyle(color: Colors.grey[900]), child: child),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.red, width: 2))),
      padding: EdgeInsets.only(bottom: 10),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 20),
        child: child,
      ),
    );
  }
}

class PageSourceLocation extends StatelessWidget {
  const PageSourceLocation({
    Key? key,
    required this.locations,
  }) : super(key: key);

  final List<String> locations;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 13),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'source location: ',
              style: TextStyle(color: Colors.black54),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: locations
                  .map<Widget>((e) => SelectableText(
                        e,
                        autofocus: false,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class PageBlurb extends StatelessWidget {
  const PageBlurb({
    Key? key,
    required this.paragraphs,
  }) : super(key: key);

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: IntrinsicLimitedBox(
        maxWidth: 400,
        child: DefaultTextStyle.merge(
          style: TextStyle(fontSize: 13.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: paragraphs
                .map<Widget>((e) => Text(e))
                .intersperse(SizedBox(
                  height: 8,
                ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
