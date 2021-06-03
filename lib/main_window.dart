import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nativeshell/nativeshell.dart';

import 'widgets/button.dart';
import 'pages/window_management.dart';
import 'pages/drag_drop.dart';
import 'pages/file_open_dialog.dart';
import 'pages/menu.dart';
import 'widgets/page.dart';
import 'pages/platform_channels.dart';

class MainWindowState extends WindowState {
  @override
  Widget build(BuildContext context) {
    return MainWindow();
  }

  @override
  Future<void> initializeWindow(Size intrinsicContentSize) async {
    if (Platform.isMacOS) {
      await Menu(_buildMenu).setAsAppMenu();
    }
    await window.setTitle('NativeShell Examples');
    return super.initializeWindow(intrinsicContentSize);
  }
}

// This will be the default "fallback" app menu used for any window that doesn't
// have other menu
List<MenuItem> _buildMenu() => [
      MenuItem.children(title: 'App', children: [
        MenuItem.withRole(role: MenuItemRole.hide),
        MenuItem.withRole(role: MenuItemRole.hideOtherApplications),
        MenuItem.withRole(role: MenuItemRole.showAll),
        MenuItem.separator(),
        MenuItem.withRole(role: MenuItemRole.quitApplication),
      ]),
      MenuItem.children(title: 'Window', role: MenuRole.window, children: [
        MenuItem.withRole(role: MenuItemRole.minimizeWindow),
        MenuItem.withRole(role: MenuItemRole.zoomWindow),
      ]),
    ];

class Page {
  Page({
    required this.title,
    required this.builder,
  });

  final String title;
  final WidgetBuilder builder;
}

final pages = <Page>[
  Page(
    title: 'Platform Channels',
    builder: (BuildContext c) {
      return PlatformChannelsPage();
    },
  ),
  Page(
    title: 'Window Management',
    builder: (BuildContext c) {
      return WindowManagementPage();
    },
  ),
  Page(
    title: 'Drag & Drop',
    builder: (BuildContext c) {
      return DragDropPage();
    },
  ),
  Page(
    title: 'Menu & MenuBar',
    builder: (BuildContext c) {
      return MenuPage();
    },
  ),
  Page(
    title: 'File Open Dialog',
    builder: (BuildContext c) {
      return FileOpenDialogPage();
    },
  ),
];

class MainWindow extends StatefulWidget {
  const MainWindow();

  @override
  State<StatefulWidget> createState() {
    return _MainWindowState();
  }
}

class _MainWindowState extends State<MainWindow> {
  @override
  void initState() {
    super.initState();
    selectedPage = pages[0];
  }

  late Page selectedPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade600,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Header(),
                SizedBox(height: 15),
                PageSelector(
                  pages: pages,
                  selectedPage: selectedPage,
                  onSelected: (Page page) {
                    setState(() {
                      // update window min size and resize window if necessary
                      WindowState.of(context).requestUpdateConstraints();
                      selectedPage = page;
                    });
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Expanded(
          child: PageContainer(
            child: selectedPage.builder(context),
          ),
        )
      ],
    );
  }
}

class Header extends StatelessWidget {
  const Header();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black.withAlpha(120),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.7),
                        blurRadius: 25,
                      )
                    ],
                  ),
                  children: [
                    TextSpan(
                        text: 'native',
                        style: TextStyle(
                          color: Colors.lightBlue.shade300,
                        )),
                    TextSpan(
                        text: 'shell',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue.shade100,
                          // color: Colors.lightBlue.shade100
                        )),
                  ]),
            ),
            SizedBox(height: 8),
            Text(
              'EXAMPLES',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            )
          ],
        ));
  }
}

class PageSelectorButton extends AbstractButton {
  const PageSelectorButton({
    Key? key,
    required this.title,
    VoidCallback? onPressed,
    this.selected = false,
  }) : super(key: key, onPressed: onPressed);

  @override
  Widget buildContents(BuildContext context, ButtonState state) {
    var border = Border.all(color: Colors.white.withOpacity(0), width: 1);
    if (state.focused) {
      border = Border.all(color: Colors.white.withOpacity(0.4), width: 1);
    }

    var color = Colors.white.withOpacity(0);
    if (selected) {
      color = Colors.white.withOpacity(0.4);
    } else if (state.active) {
      color = Colors.white.withOpacity(0.6);
    } else if (state.hovered) {
      color = Colors.white.withOpacity(0.2);
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        border: border,
      ),
      child: Text(title),
    );
  }

  final String title;
  final bool selected;
}

class PageSelector extends StatelessWidget {
  const PageSelector({
    Key? key,
    required this.pages,
    required this.selectedPage,
    required this.onSelected,
  }) : super(key: key);

  final List<Page> pages;
  final Page selectedPage;
  final void Function(Page) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: pages.map<Widget>((page) {
        return PageSelectorButton(
          title: page.title,
          selected: selectedPage == page,
          onPressed: () {
            onSelected(page);
          },
        );
      }).toList(),
    );
  }
}
