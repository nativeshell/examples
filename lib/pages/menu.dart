import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nativeshell/accelerators.dart';
import 'package:nativeshell/nativeshell.dart' as nshell;

import '../widgets/page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage();

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
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
                  nshell.MenuBar(
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
    final menu = nshell.Menu(_buildContextMenu);

    // Show the Loading... item every time context menu is displayed
    _lazyMenuLoaded = false;

    // Menu can be updated while visible
    final timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      ++_counter;
      menu.update();
    });

    await nshell.Window.of(context).showPopupMenu(menu, e.globalPosition);

    timer.cancel();
  }

  //
  // Context Menu
  //

  late nshell.Menu _lazyMenu; // created in initState, used in _buildContextMenu
  bool _lazyMenuLoaded = false;

  List<nshell.MenuItem> _buildLazyMenuItems() => !_lazyMenuLoaded
      ? [
          nshell.MenuItem(title: 'Loading...', action: null),
        ]
      : [
          nshell.MenuItem(title: 'Menu items can be', action: () {}),
          nshell.MenuItem(title: 'loaded on demand.', action: () {}),
          nshell.MenuItem.separator(),
          nshell.MenuItem(title: 'Counter $_counter', action: null),
        ];

  void _onLazyMenuOpen() async {
    await Future.delayed(Duration(seconds: 1));
    _lazyMenuLoaded = true;
    _lazyMenu.update();
  }

  List<nshell.MenuItem> _buildContextMenu() => [
        nshell.MenuItem(title: 'A Context Menu Item', action: () {}),
        nshell.MenuItem(title: 'Update Counter $_counter', action: null),
        nshell.MenuItem.separator(),
        ..._buildCheckAndRadioItems(),
        nshell.MenuItem.separator(),
        nshell.MenuItem.children(title: 'Submenu', children: [
          nshell.MenuItem(title: 'Submenu Item 1', action: () {}),
          nshell.MenuItem(title: 'Submenu Item 2', action: () {}),
        ]),
        nshell.MenuItem.separator(),
        nshell.MenuItem.menu(title: 'Lazy Loaded Submenu', submenu: _lazyMenu),
      ];

  //
  // MenuBar
  //

  Widget _buildMenuBarItem(
      BuildContext context, Widget child, nshell.MenuItemState itemState) {
    Color background;
    Color foreground;
    switch (itemState) {
      case nshell.MenuItemState.regular:
        background = Colors.transparent;
        foreground = Colors.grey.shade800;
        break;
      case nshell.MenuItemState.hovered:
        background = Colors.purple.withOpacity(0.2);
        foreground = Colors.grey.shade800;
        break;
      case nshell.MenuItemState.selected:
        background = Colors.purple.withOpacity(0.8);
        foreground = Colors.white;
        break;
      case nshell.MenuItemState.disabled:
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

  late nshell.Menu menu;

  @override
  void initState() {
    super.initState();

    // MenuBar menu
    menu = nshell.Menu(_buildMenu);

    // Lazily loaded sub-menu used in context menu
    _lazyMenu = nshell.Menu(_buildLazyMenuItems, onOpen: _onLazyMenuOpen);
  }

  bool check1 = true;
  bool check2 = false;
  int radioValue = 0;

  // MenuBar items
  List<nshell.MenuItem> _buildMenu() => [
        if (Platform.isMacOS)
          nshell.MenuItem.children(title: 'App', children: [
            nshell.MenuItem.withRole(role: nshell.MenuItemRole.hide),
            nshell.MenuItem.withRole(
                role: nshell.MenuItemRole.hideOtherApplications),
            nshell.MenuItem.withRole(role: nshell.MenuItemRole.showAll),
            nshell.MenuItem.separator(),
            nshell.MenuItem.withRole(role: nshell.MenuItemRole.quitApplication),
          ]),
        nshell.MenuItem.children(title: '&File', children: [
          nshell.MenuItem(
              title: 'New', accelerator: cmdOrCtrl + 'n', action: () {}),
          nshell.MenuItem(
              title: 'Open', accelerator: cmdOrCtrl + 'o', action: () {}),
          nshell.MenuItem.separator(),
          nshell.MenuItem(
              title: 'Save', accelerator: cmdOrCtrl + 's', action: null),
          nshell.MenuItem(title: 'Save As', action: null),
          nshell.MenuItem.separator(),
          nshell.MenuItem(title: 'Close', action: () {}),
        ]),
        nshell.MenuItem.children(title: '&Edit', children: [
          nshell.MenuItem(
              title: 'Cut', accelerator: cmdOrCtrl + 'x', action: () {}),
          nshell.MenuItem(
              title: 'Copy', accelerator: cmdOrCtrl + 'c', action: () {}),
          nshell.MenuItem(
              title: 'Paste', accelerator: cmdOrCtrl + 'v', action: () {}),
          nshell.MenuItem.separator(),
          nshell.MenuItem(
              title: 'Find', accelerator: cmdOrCtrl + 'f', action: () {}),
          nshell.MenuItem(title: 'Replace', action: () {}),
        ]),
        nshell.MenuItem.children(title: 'Another Menu', children: [
          ..._buildCheckAndRadioItems(),
          nshell.MenuItem.separator(),
          nshell.MenuItem.children(title: 'Submenu', children: [
            nshell.MenuItem(title: 'More of the same, I guess?', action: null),
            nshell.MenuItem.separator(),
            ..._buildCheckAndRadioItems(),
          ]),
        ]),
        if (Platform.isMacOS)
          nshell.MenuItem.children(
              title: 'Window',
              role: nshell.MenuRole.window,
              children: [
                nshell.MenuItem.withRole(
                    role: nshell.MenuItemRole.minimizeWindow),
                nshell.MenuItem.withRole(role: nshell.MenuItemRole.zoomWindow),
              ]),
        nshell.MenuItem.children(title: '&Help', children: [
          nshell.MenuItem(title: 'About', action: () {}),
        ]),
      ];

  // Used in both MenuBar and ContextMenu
  List<nshell.MenuItem> _buildCheckAndRadioItems() => [
        nshell.MenuItem(
            title: 'Checkable Item 1',
            checkStatus: check1
                ? nshell.CheckStatus.checkOn
                : nshell.CheckStatus.checkOff,
            action: () {
              check1 = !check1;
              menu.update();
            }),
        nshell.MenuItem(
            title: 'Checkable Item 2',
            checkStatus: check2
                ? nshell.CheckStatus.checkOn
                : nshell.CheckStatus.checkOff,
            action: () {
              check2 = !check2;
              menu.update();
            }),
        nshell.MenuItem.separator(),
        nshell.MenuItem(
            title: 'Radio Item 1',
            checkStatus: radioValue == 0
                ? nshell.CheckStatus.radioOn
                : nshell.CheckStatus.radioOff,
            action: () {
              radioValue = 0;
              menu.update();
            }),
        nshell.MenuItem(
            title: 'Radio Item 2',
            checkStatus: radioValue == 1
                ? nshell.CheckStatus.radioOn
                : nshell.CheckStatus.radioOff,
            action: () {
              radioValue = 1;
              menu.update();
            }),
        nshell.MenuItem(
            title: 'Radio Item 3',
            checkStatus: radioValue == 2
                ? nshell.CheckStatus.radioOn
                : nshell.CheckStatus.radioOff,
            action: () {
              radioValue = 2;
              menu.update();
            }),
      ];
}
