import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nativeshell/accelerators.dart';
import 'package:nativeshell/nativeshell.dart';

import '../widgets/page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage();

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  _MenuPageState() {
    _lazyMenu = Menu(_buildLazyMenuItems, onOpen: _onLazyMenuOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(child: Text('Menu & MenuBar Example')),
        PageSourceLocation(locations: ['lib/pages/menu.dart']),
        PageBlurb(paragraphs: [
          'NativeShell provides support for native context menus and a MenuBar widget, '
              'which is a Flutter component that opens into native submenus.'
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple, width: 1),
                  color: Colors.purple.withOpacity(0.15)),
              child: Column(
                children: [
                  MenuBar(
                    menu: menu,
                    itemBuilder: _buildMenuBarItem,
                  ),
                  if (Platform.isMacOS)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Text(
                          'Look up! On macOS the MenuBar is at the top of screen.'),
                    )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onSecondaryTapDown: _showContextMenu,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade300),
                  color: Colors.blue.shade100,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(38.0),
                  child: Text('Right-click here for context menu'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _counter = 0;

  void _showContextMenu(TapDownDetails e) async {
    final menu = Menu(_buildContextMenu);

    _lazyMenuLoaded = false;

    // Menu can be updated while visible
    final timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      ++_counter;
      menu.update();
    });

    await Window.of(context).showPopupMenu(menu, e.globalPosition);

    timer.cancel();
  }

  List<MenuItem> _buildContextMenu() => [
        MenuItem(title: 'Context menu Item', action: () {}),
        MenuItem(title: 'Menu Update Counter $_counter', action: null),
        MenuItem.separator(),
        ..._buildCheckAndRadioItems(),
        MenuItem.separator(),
        MenuItem.menu(title: 'Lazy Submenu', submenu: _lazyMenu),
        MenuItem.separator(),
        MenuItem.children(title: 'Submenu', children: [
          MenuItem(title: 'Submenu Item 1', action: () {}),
          MenuItem(title: 'Submenu Item 2', action: () {}),
          MenuItem(title: 'Submenu Update Counter $_counter', action: null),
        ]),
      ];

  Widget _buildMenuBarItem(
      BuildContext context, Widget child, MenuItemState itemState) {
    Color background;
    Color foreground;
    switch (itemState) {
      case MenuItemState.regular:
        background = Colors.transparent;
        foreground = Colors.grey.shade800;
        break;
      case MenuItemState.hovered:
        background = Colors.purple.withOpacity(0.2);
        foreground = Colors.grey.shade800;
        break;
      case MenuItemState.selected:
        background = Colors.purple.withOpacity(0.8);
        foreground = Colors.white;
        break;
      case MenuItemState.disabled:
        background = Colors.transparent;
        foreground = Colors.grey.shade800.withOpacity(0.5);
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: background,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: child,
      ),
    );
  }

  late Menu menu;
  @override
  void initState() {
    super.initState();
    menu = Menu(_buildMenu);
  }

  bool check1 = true;
  bool check2 = false;
  int radioValue = 0;

  late Menu _lazyMenu;
  bool _lazyMenuLoaded = false;

  List<MenuItem> _buildLazyMenuItems() => _lazyMenuLoaded
      ? [
          MenuItem(title: 'Lazy Item 1', action: () {}),
          MenuItem(title: 'Lazy Item 2', action: () {}),
          MenuItem(title: 'Lazy Item 3', action: () {}),
          MenuItem(title: 'Lazy Item 4', action: () {}),
          MenuItem(title: 'Lazy Counter $_counter', action: null),
        ]
      : [
          MenuItem(title: 'Loading...', action: null),
        ];

  void _onLazyMenuOpen() async {
    await Future.delayed(Duration(seconds: 1));
    _lazyMenuLoaded = true;
    _lazyMenu.update();
  }

  // This will be the default "fallback" app menu used for any window that doesn't
  // have other menu
  List<MenuItem> _buildMenu() => [
        if (Platform.isMacOS)
          MenuItem.children(title: 'App', children: [
            MenuItem.withRole(role: MenuItemRole.hide),
            MenuItem.withRole(role: MenuItemRole.hideOtherApplications),
            MenuItem.withRole(role: MenuItemRole.showAll),
            MenuItem.separator(),
            MenuItem.withRole(role: MenuItemRole.quitApplication),
          ]),
        MenuItem.children(title: '&File', children: [
          MenuItem(title: 'New', accelerator: cmdOrCtrl + 'n', action: () {}),
          MenuItem(title: 'Open', accelerator: cmdOrCtrl + 'o', action: () {}),
          MenuItem.separator(),
          MenuItem(title: 'Save', accelerator: cmdOrCtrl + 's', action: null),
          MenuItem(title: 'Save As', action: null),
          MenuItem.separator(),
          MenuItem(title: 'Close', action: () {}),
        ]),
        MenuItem.children(title: '&Edit', children: [
          MenuItem(title: 'Cut', accelerator: cmdOrCtrl + 'x', action: () {}),
          MenuItem(title: 'Copy', accelerator: cmdOrCtrl + 'c', action: () {}),
          MenuItem(title: 'Paste', accelerator: cmdOrCtrl + 'v', action: () {}),
          MenuItem.separator(),
          MenuItem(title: 'Find', accelerator: cmdOrCtrl + 'f', action: () {}),
          MenuItem(title: 'Replace', action: () {}),
        ]),
        MenuItem.children(title: 'Another Menu', children: [
          ..._buildCheckAndRadioItems(),
          MenuItem.separator(),
          MenuItem.children(title: 'Submenu', children: [
            MenuItem(title: 'More of the same, I guess?', action: null),
            MenuItem.separator(),
            ..._buildCheckAndRadioItems(),
          ]),
        ]),
        if (Platform.isMacOS)
          MenuItem.children(title: 'Window', role: MenuRole.window, children: [
            MenuItem.withRole(role: MenuItemRole.minimizeWindow),
            MenuItem.withRole(role: MenuItemRole.zoomWindow),
          ]),
        MenuItem.children(title: '&Help', children: [
          MenuItem(title: 'About', action: () {}),
        ]),
      ];

  List<MenuItem> _buildCheckAndRadioItems() => [
        MenuItem(
            title: 'Checkable Item 1',
            checkStatus: check1 ? CheckStatus.checkOn : CheckStatus.checkOff,
            action: () {
              check1 = !check1;
              menu.update();
            }),
        MenuItem(
            title: 'Checkable Item 2',
            checkStatus: check2 ? CheckStatus.checkOn : CheckStatus.checkOff,
            action: () {
              check2 = !check2;
              menu.update();
            }),
        MenuItem.separator(),
        MenuItem(
            title: 'Radio Item 1',
            checkStatus:
                radioValue == 0 ? CheckStatus.radioOn : CheckStatus.radioOff,
            action: () {
              radioValue = 0;
              menu.update();
            }),
        MenuItem(
            title: 'Radio Item 2',
            checkStatus:
                radioValue == 1 ? CheckStatus.radioOn : CheckStatus.radioOff,
            action: () {
              radioValue = 1;
              menu.update();
            }),
        MenuItem(
            title: 'Radio Item 3',
            checkStatus:
                radioValue == 2 ? CheckStatus.radioOn : CheckStatus.radioOff,
            action: () {
              radioValue = 2;
              menu.update();
            }),
      ];
}
