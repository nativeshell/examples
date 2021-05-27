import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class ButtonState {
  bool get active;
  bool get disabled;
  bool get enabled;
  bool get hovered;
  bool get focused;
}

// Abstract Button class that handles hovered, active, enabled and focused
// states.
abstract class AbstractButton extends StatefulWidget {
  const AbstractButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final VoidCallback? onPressed;

  Widget buildContents(BuildContext context, ButtonState state);

  @override
  State<StatefulWidget> createState() {
    return AbstractButtonState();
  }
}

class AbstractButtonState<T extends AbstractButton> extends State<T>
    implements ButtonState {
  // Button is pressed, either by holding space key or mouse button
  @override
  bool get active => _active;

  // Button is disabled
  @override
  bool get disabled => widget.onPressed == null;

  // Button is enabled
  @override
  bool get enabled => !disabled;

  // Mouse cursor is over button
  @override
  bool get hovered => _hovered;

  // Button has keyboard focus
  @override
  bool get focused => _focused;

  late FocusNode _node;
  late FocusAttachment _nodeAttachment;
  bool _focused = false;
  bool _active = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _node = FocusNode(debugLabel: 'Button');
    _node.addListener(_onFocusChange);
    _nodeAttachment = _node.attach(context, onKey: _handleKeyPress);
  }

  void _onFocusChange() {
    if (_node.hasFocus != _focused) {
      setState(() {
        _focused = _node.hasFocus;
      });
    }
  }

  KeyEventResult _handleKeyPress(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      if (widget.onPressed != null) {
        widget.onPressed!();
      }
      return KeyEventResult.handled;
    }
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.space) {
      if (_canBecomeActive() && !_active) {
        setState(() {
          _active = true;
        });
      }
      return KeyEventResult.handled;
    }
    if (event is RawKeyUpEvent &&
        event.logicalKey == LogicalKeyboardKey.space &&
        _active) {
      setState(() {
        _active = false;
      });
      widget.onPressed!();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
    _node.dispose();
    super.dispose();
  }

  void _dragUpdate(BuildContext context, Offset globalPosition) {
    final active = _isInside(globalPosition);
    if (active != _active) {
      setState(() {
        _hovered = active;
        _active = active;
      });
    }
  }

  bool _isInside(Offset globalPosition) {
    final b = context.findRenderObject() as RenderBox?;
    if (b != null) {
      final pos = b.globalToLocal(globalPosition);
      return pos.dx >= 0 &&
          pos.dy >= 0 &&
          pos.dx < b.size.width &&
          pos.dy < b.size.height;
    } else {
      return false;
    }
  }

  bool _canBecomeActive() {
    return !disabled;
  }

  @override
  Widget build(BuildContext context) {
    _nodeAttachment.reparent();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (DragDownDetails d) {
        if (!_canBecomeActive()) return;
        _dragUpdate(context, d.globalPosition);
      },
      onPanUpdate: (DragUpdateDetails d) {
        if (!_canBecomeActive()) return;
        _dragUpdate(context, d.globalPosition);
      },
      onPanCancel: () {
        if (_active) {
          setState(() {
            _active = false;
          });
        }
      },
      onPanEnd: (DragEndDetails d) {
        if (_active) {
          widget.onPressed!();
          setState(() {
            _active = false;
          });
        }
      },
      onTapUp: (TapUpDetails d) {
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      child: MouseRegion(
        onEnter: (PointerEnterEvent e) {
          if (!_hovered && e.buttons == 0) {
            setState(() {
              _hovered = true;
            });
          }
        },
        onExit: (PointerExitEvent e) {
          if (_hovered) {
            setState(() {
              _hovered = false;
            });
          }
        },
        child: widget.buildContents(context, this),
      ),
    );
  }
}

class Button extends AbstractButton {
  const Button({
    Key? key,
    required this.child,
    VoidCallback? onPressed,
  }) : super(key: key, onPressed: onPressed);

  final Widget child;

  @override
  Widget buildContents(BuildContext context, ButtonState state) {
    final radius = BorderRadius.circular(6);

    Decoration decoration;
    if (state.active) {
      decoration = BoxDecoration(
          borderRadius: radius,
          color: Colors.blue.shade100,
          border: Border.all(color: Colors.blue.shade400, width: 1),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 2,
                spreadRadius: 1)
          ]);
    } else if (state.hovered && state.enabled) {
      decoration = BoxDecoration(
          color: Colors.blue.shade100,
          border: Border.all(color: Colors.blue.shade300, width: 1),
          borderRadius: radius,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                spreadRadius: 4)
          ]);
    } else {
      decoration = BoxDecoration(
        borderRadius: radius,
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blueGrey.shade200, width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              spreadRadius: 1)
        ],
        // border: Border.all(color: Colors.transparent),
      );
    }

    return AnimatedContainer(
      // Focus decoration
      duration: Duration(milliseconds: state.focused ? 300 : 0),
      decoration: state.focused && state.enabled
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 0,
                      spreadRadius: 3)
                ])
          : BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.0),
                      blurRadius: 0,
                      spreadRadius: 12)
                ]),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        decoration: decoration,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 13,
            color: state.enabled ? Colors.black87 : Colors.black45,
            fontWeight: FontWeight.w500,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 50),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
