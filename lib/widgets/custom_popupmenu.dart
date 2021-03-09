import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

const Duration _kMenuDuration = Duration(milliseconds: 300);
const double _kMenuCloseIntervalEnd = 2.0 / 3.0;
const double _kMenuMaxWidth = 5.0 * _kMenuWidthStep;
const double _kMenuMinWidth = 2.0 * _kMenuWidthStep;
const double _kMenuVerticalPadding = 8.0;
const double _kMenuWidthStep = 56.0;
const double _kMenuScreenPadding = 8.0;

class _MenuItem extends SingleChildRenderObjectWidget {
  const _MenuItem({
    Key key,
    @required this.onLayout,
    Widget child,
  })  : assert(onLayout != null),
        super(key: key, child: child);

  final ValueChanged<Size> onLayout;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMenuItem(onLayout);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderMenuItem renderObject) {
    renderObject.onLayout = onLayout;
  }
}

class _RenderMenuItem extends RenderShiftedBox {
  _RenderMenuItem(this.onLayout, [RenderBox child])
      : assert(onLayout != null),
        super(child);

  ValueChanged<Size> onLayout;

  @override
  void performLayout() {
    if (child == null) {
      size = Size.zero;
    } else {
      child.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child.size);
    }
    final childParentData = child.parentData as BoxParentData;
    childParentData.offset = Offset.zero;
    onLayout(size);
  }
}

class _PopupMenu<T> extends StatelessWidget {
  const _PopupMenu({
    Key key,
    this.route,
    this.semanticLabel,
  }) : super(key: key);

  final _PopupMenuRoute<T> route;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final unit = 1.0 /
        (route.items.length +
            1.5); // 1.0 for the width and 0.5 for the last item's fade.
    final children = <Widget>[];
    final popupMenuTheme = PopupMenuTheme.of(context);

    for (var i = 0; i < route.items.length; i += 1) {
      final start = (i + 1) * unit;
      final end = (start + 1.5 * unit).clamp(0.0, 1.0) as double;
      final opacity = CurvedAnimation(
        parent: route.animation,
        curve: Interval(start, end),
      );
      Widget item = route.items[i];
      if (route.initialValue != null &&
          route.items[i].represents(route.initialValue)) {
        item = Container(
          color: Theme.of(context).highlightColor,
          child: item,
        );
      }
      children.add(
        _MenuItem(
          onLayout: (size) {
            route.itemSizes[i] = size;
          },
          child: FadeTransition(
            opacity: opacity,
            child: item,
          ),
        ),
      );
    }

    final opacity = CurveTween(curve: const Interval(0.0, 1.0 / 3.0));
    final width = CurveTween(curve: Interval(0.0, unit));
    final height = CurveTween(curve: Interval(0.0, unit * route.items.length));

    final Widget child = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: _kMenuMinWidth,
        maxWidth: _kMenuMaxWidth,
      ),
      child: IntrinsicWidth(
        stepWidth: _kMenuWidthStep,
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: semanticLabel,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: _kMenuVerticalPadding),
            child: ListBody(children: children),
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: route.animation,
      builder: (context, child) {
        return Opacity(
          opacity: opacity.evaluate(route.animation),
          child: Material(
            shape: route.shape ?? popupMenuTheme.shape,
            color: route.color ?? popupMenuTheme.color,
            type: MaterialType.card,
            elevation: route.elevation ?? popupMenuTheme.elevation ?? 8.0,
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              widthFactor: width.evaluate(route.animation),
              heightFactor: height.evaluate(route.animation),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(this.position, this.itemSizes, this.selectedItemIndex,
      this.textDirection);

  final RelativeRect position;

  List<Size> itemSizes;

  final int selectedItemIndex;

  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      constraints.biggest -
              const Offset(_kMenuScreenPadding * 2.0, _kMenuScreenPadding * 2.0)
          as Size,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var y = position.top;
    if (selectedItemIndex != null && itemSizes != null) {
      var selectedItemOffset = _kMenuVerticalPadding;
      for (var index = 0; index < selectedItemIndex; index += 1) {
        selectedItemOffset += itemSizes[index].height;
      }
      selectedItemOffset += itemSizes[selectedItemIndex].height / 2;
      y = position.top +
          (size.height - position.top - position.bottom) / 2.0 -
          selectedItemOffset;
    }

    double x;
    if (position.left > position.right) {
      x = size.width - position.right - childSize.width;
    } else if (position.left < position.right) {
      // Menu button is closer to the left edge, so grow to the right, aligned to the left edge.
      x = position.left;
    } else {
      // Menu button is equidistant from both edges, so grow in reading direction.
      assert(textDirection != null);
      switch (textDirection) {
        case TextDirection.rtl:
          x = size.width - position.right - childSize.width;
          break;
        case TextDirection.ltr:
          x = position.left;
          break;
      }
    }

    if (x < _kMenuScreenPadding) {
      x = _kMenuScreenPadding;
    } else if (x + childSize.width > size.width - _kMenuScreenPadding) {
      x = size.width - childSize.width - _kMenuScreenPadding;
    }
    if (y < _kMenuScreenPadding) {
      y = _kMenuScreenPadding;
    } else if (y + childSize.height > size.height - _kMenuScreenPadding) {
      y = size.height - childSize.height - _kMenuScreenPadding;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    assert(itemSizes.length == oldDelegate.itemSizes.length);

    return position != oldDelegate.position ||
        selectedItemIndex != oldDelegate.selectedItemIndex ||
        textDirection != oldDelegate.textDirection ||
        !listEquals(itemSizes, oldDelegate.itemSizes);
  }
}

class _PopupMenuRoute<T> extends PopupRoute<T> {
  _PopupMenuRoute({
    this.position,
    this.items,
    this.initialValue,
    this.elevation,
    this.theme,
    this.popupMenuTheme,
    this.barrierLabel,
    this.semanticLabel,
    this.shape,
    this.color,
    this.showMenuContext,
    this.captureInheritedThemes,
  }) : itemSizes = List<Size>(items.length);

  final RelativeRect position;
  final List<PopupMenuEntry<T>> items;
  final List<Size> itemSizes;
  final T initialValue;
  final double elevation;
  final ThemeData theme;
  final String semanticLabel;
  final ShapeBorder shape;
  final Color color;
  final PopupMenuThemeData popupMenuTheme;
  final BuildContext showMenuContext;
  final bool captureInheritedThemes;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
      reverseCurve: const Interval(0.0, _kMenuCloseIntervalEnd),
    );
  }

  @override
  Duration get transitionDuration => _kMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => null;

  @override
  final String barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    int selectedItemIndex;
    if (initialValue != null) {
      for (var index = 0;
          selectedItemIndex == null && index < items.length;
          index += 1) {
        if (items[index].represents(initialValue)) selectedItemIndex = index;
      }
    }

    Widget menu = _PopupMenu<T>(route: this, semanticLabel: semanticLabel);
    if (captureInheritedThemes) {
      menu = InheritedTheme.captureAll(showMenuContext, menu);
    } else {
      if (theme != null) menu = Theme(data: theme, child: menu);
    }

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (context) {
          return CustomSingleChildLayout(
            delegate: _PopupMenuRouteLayout(
              position,
              itemSizes,
              selectedItemIndex,
              Directionality.of(context),
            ),
            child: menu,
          );
        },
      ),
    );
  }
}

Future<T> _showMenu<T>({
  @required BuildContext context,
  @required RelativeRect position,
  @required List<PopupMenuEntry<T>> items,
  T initialValue,
  double elevation,
  String semanticLabel,
  ShapeBorder shape,
  Color color,
  bool captureInheritedThemes = true,
  bool useRootNavigator = false,
}) {
  assert(context != null);
  assert(position != null);
  assert(useRootNavigator != null);
  assert(items != null && items.isNotEmpty);
  assert(captureInheritedThemes != null);
  assert(debugCheckHasMaterialLocalizations(context));

  var label = semanticLabel;
  switch (Theme.of(context).platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      label = semanticLabel;
      break;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      label =
          semanticLabel ?? MaterialLocalizations.of(context)?.popupMenuLabel;
  }

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push(_PopupMenuRoute<T>(
    position: position,
    items: items,
    initialValue: initialValue,
    elevation: elevation,
    semanticLabel: label,
    theme: Theme.of(context),
    popupMenuTheme: PopupMenuTheme.of(context),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    shape: shape,
    color: color,
    showMenuContext: context,
    captureInheritedThemes: captureInheritedThemes,
  ));
}

class MyPopupMenuButton<T> extends StatefulWidget {
  /// Creates a button that shows a popup menu.
  ///
  /// The [itemBuilder] argument must not be null.
  const MyPopupMenuButton({
    Key key,
    @required this.itemBuilder,
    this.initialValue,
    this.onSelected,
    this.onCanceled,
    this.tooltip,
    this.elevation,
    this.padding = const EdgeInsets.all(8.0),
    this.child,
    this.icon,
    this.offset = Offset.zero,
    this.enabled = true,
    this.shape,
    this.color,
    this.captureInheritedThemes = true,
  })  : assert(itemBuilder != null),
        assert(offset != null),
        assert(enabled != null),
        assert(captureInheritedThemes != null),
        assert(!(child != null && icon != null),
            'You can only pass [child] or [icon], not both.'),
        super(key: key);

  final PopupMenuItemBuilder<T> itemBuilder;

  final T initialValue;
  final PopupMenuItemSelected<T> onSelected;

  final PopupMenuCanceled onCanceled;

  final String tooltip;

  final double elevation;

  final EdgeInsetsGeometry padding;

  final Widget child;

  final Widget icon;

  final Offset offset;
  final bool enabled;
  final ShapeBorder shape;

  final Color color;

  final bool captureInheritedThemes;

  @override
  MyPopupMenuButtonState<T> createState() => MyPopupMenuButtonState<T>();
}

class MyPopupMenuButtonState<T> extends State<MyPopupMenuButton<T>> {
  void showButtonMenu() {
    final popupMenuTheme = PopupMenuTheme.of(context);
    final button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(widget.offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final items = widget.itemBuilder(context);
    // Only show the menu if there is something to show
    if (items.isNotEmpty) {
      _showMenu<T>(
        context: context,
        elevation: widget.elevation ?? popupMenuTheme.elevation,
        items: items,
        initialValue: widget.initialValue,
        position: position,
        shape: widget.shape ?? popupMenuTheme.shape,
        color: widget.color ?? popupMenuTheme.color,
        captureInheritedThemes: widget.captureInheritedThemes,
      ).then<void>((newValue) {
        if (!mounted) return null;
        if (newValue == null) {
          if (widget.onCanceled != null) widget.onCanceled();
          return null;
        }
        if (widget.onSelected != null) widget.onSelected(newValue);
      });
    }
  }

  Icon _getIcon(TargetPlatform platform) {
    assert(platform != null);
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const Icon(Icons.more_vert);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const Icon(Icons.more_horiz);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));

    if (widget.child != null) {
      return Tooltip(
        message:
            widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
        child: InkWell(
          onTap: widget.enabled ? showButtonMenu : null,
          canRequestFocus: widget.enabled,
          child: widget.child,
        ),
      );
    }

    return IconButton(
      icon: widget.icon ?? _getIcon(Theme.of(context).platform),
      padding: widget.padding,
      tooltip:
          widget.tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: widget.enabled ? showButtonMenu : null,
    );
  }
}

class MyPopupMenuItem<int> extends PopupMenuEntry<int> {
  const MyPopupMenuItem({
    Key key,
    this.value,
    this.enabled = true,
    this.height = kMinInteractiveDimension,
    this.textStyle,
    @required this.child,
  })  : assert(enabled != null),
        assert(height != null),
        super(key: key);

  final int value;

  final bool enabled;

  @override
  final double height;
  final TextStyle textStyle;

  final Widget child;

  @override
  bool represents(int value) => value == this.value;

  @override
  MyPopupMenuItemState<int, MyPopupMenuItem<int>> createState() =>
      MyPopupMenuItemState<int, MyPopupMenuItem<int>>();
}

class MyPopupMenuItemState<int, W extends MyPopupMenuItem<int>>
    extends State<W> {
  @protected
  Widget buildChild() => widget.child;

  @protected
  void handleTap() {
    Navigator.pop<int>(context, widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final popupMenuTheme = PopupMenuTheme.of(context);
    var style = widget.textStyle ??
        popupMenuTheme.textStyle ??
        theme.textTheme.subtitle1;

    Widget item = AnimatedDefaultTextStyle(
      style: style,
      duration: kThemeChangeDuration,
      child: Container(
        // alignment: AlignmentDirectional.centerStart,
        //  constraints: BoxConstraints(minHeight: widget.height),
        padding: const EdgeInsets.all(0),
        child: buildChild(),
      ),
    );
    return item;
    //   return InkWell(
    //     onTap: widget.enabled ? handleTap : null,
    //     canRequestFocus: widget.enabled,
    //     child: item,
    //   );
  }
}
