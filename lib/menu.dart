import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nativeshell/accelerators.dart';
import 'package:nativeshell/nativeshell.dart';

import 'page.dart';

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
        PageSourceLocation(locations: ['lib/menu.dart']),
        PageBlurb(paragraphs: [
          'Nativeshell supports native context menus and menu bars.',
          'MenuBar is a flutter component that opens into native submenus.'
        ]),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple, width: 1),
                  color: Colors.purple.withOpacity(0.15)),
              child: Column(
                children: [
                  MenuBar(
                    menu: menu,
                    itemBuilder: _buildMenuItem,
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
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(
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
          MenuItem(title: 'New', accelerator: cmdOrCtrl + 'N', action: () {}),
          MenuItem(title: 'Open', accelerator: cmdOrCtrl + 'O', action: () {}),
          MenuItem(title: 'Save', accelerator: cmdOrCtrl + 'S', action: () {}),
          MenuItem(title: 'Save As', action: () {}),
          MenuItem(title: 'Close', action: () {}),
        ]),
        if (Platform.isMacOS)
          MenuItem.children(title: 'Window', role: MenuRole.window, children: [
            MenuItem.withRole(role: MenuItemRole.minimizeWindow),
            MenuItem.withRole(role: MenuItemRole.zoomWindow),
          ]),
      ];
}
