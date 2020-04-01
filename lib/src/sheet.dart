import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

part 'scrolling.dart';
part 'sheet_dialog.dart';
part 'specs.dart';
part 'util.dart';

typedef SheetBuilder = Widget Function(BuildContext context, SheetState state);

typedef SheetListener = void Function(SheetState state);

/// A widget that can be dragged and scrolled in a single gesture and snapped
/// to a list of extents.
///
/// The [builder] parameter must not be null.
class SlidingSheet extends StatefulWidget {
  /// {@template sliding_sheet.builder}
  /// The builder for the main content of the sheet that will be scrolled if
  /// the content is bigger than the height that the sheet can expand to.
  /// {@endtemplate}
  final SheetBuilder builder;

  /// {@template sliding_sheet.headerBuilder}
  /// The builder for a header that will be displayed at the top of the sheet
  /// that wont be scrolled.
  /// {@endtemplate}
  final SheetBuilder headerBuilder;

  /// {@template sliding_sheet.footerBuilder}
  /// The builder for a footer that will be displayed at the bottom of the sheet
  /// that wont be scrolled.
  /// {@endtemplate}
  final SheetBuilder footerBuilder;

  /// {@template sliding_sheet.snapSpec}
  /// The [SnapSpec] that defines how the sheet should snap or if it should at all.
  /// {@endtemplate}
  final SnapSpec snapSpec;

  /// {@template sliding_sheet.duration}
  /// The base animation duration for the sheet. Swipes and flings may have a different duration.
  /// {@endtemplate}
  final Duration duration;

  /// {@template sliding_sheet.color}
  /// The background color of the sheet.
  /// {@endtemplate}
  final Color color;

  /// {@template sliding_sheet.backdropColor}
  /// The color of the shadow that is displayed behind the sheet.
  /// {@endtemplate}
  final Color backdropColor;

  /// {@template sliding_sheet.shadowColor}
  /// The color of the drop shadow of the sheet when [elevation] is > 0.
  /// {@endtemplate}
  final Color shadowColor;

  /// {@template sliding_sheet.elevation}
  /// The elevation of the sheet.
  /// {@endtemplate}
  final double elevation;

  /// {@template sliding_sheet.padding}
  /// The amount to inset the children of the sheet.
  /// {@endtemplate}
  final EdgeInsets padding;

  /// {@template sliding_sheet.addTopViewPaddingWhenAtFullscreen}
  /// If true, adds the top padding returned by
  /// `MediaQuery.of(context).viewPadding.top` to the [padding] when taking
  /// up the full screen.
  ///
  /// This can be used to easily avoid the content of the sheet from being
  /// under the statusbar, which is especially useful when having a header.
  /// {@endtemplate}
  final bool addTopViewPaddingOnFullscreen;

  /// {@template sliding_sheet.margin}
  /// The amount of the empty space surrounding the sheet.
  /// {@endtemplate}
  final EdgeInsets margin;

  /// {@template sliding_sheet.border}
  /// A border that will be drawn around the sheet.
  /// {@endtemplate}
  final Border border;

  /// {@template sliding_sheet.cornerRadius}
  /// The radius of the top corners of this sheet.
  /// {@endtemplate}
  final double cornerRadius;

  /// {@template sliding_sheet.cornerRadiusOnFullscreen}
  /// The radius of the top corners of this sheet when expanded to fullscreen.
  ///
  /// This parameter can be used to easily implement the common Material
  /// behaviour of sheets to go from rounded corners to sharp corners when
  /// taking up the full screen.
  /// {@endtemplate}
  final double cornerRadiusOnFullscreen;

  /// If true, will collapse the sheet when the sheets backdrop was tapped.
  final bool closeOnBackdropTap;

  /// {@template sliding_sheet.listener}
  /// A callback that will be invoked when the sheet gets dragged or scrolled
  /// with current state information.
  /// {@endtemplate}
  final SheetListener listener;

  /// {@template sliding_sheet.controller}
  /// A controller to control the state of the sheet.
  /// {@endtemplate}
  final SheetController controller;

  /// {@template sliding_sheet.scrollSpec}
  /// The [ScrollSpec] of the containing ScrollView.
  /// {@endtemplate}
  final ScrollSpec scrollSpec;

  /// {@template sliding_sheet.maxWidth}
  /// The maximum width of the sheet.
  ///
  /// Usually set for large screens. By default the [SlidingSheet]
  /// expands to the total available width.
  /// {@endtemplate}
  final double maxWidth;

  /// {@template sliding_sheet.maxWidth}
  /// The minimum height of the sheet the child return by the `builder`.
  ///
  /// By default, the sheet sizes itself as big as its child.
  /// {@endtemplate}
  final double minHeight;

  /// {@template sliding_sheet.closeSheetOnBackButtonPressed}
  /// If true, closes the sheet when it is open and prevents the route
  /// from being popped.
  /// {@endtemplate}
  final bool closeSheetOnBackButtonPressed;

  // * BottomSheet fields

  final _SlidingSheetRoute route;

  /// {@template sliding_sheet.isDismissable}
  /// If false, the `SlidingSheetDialog` will not be dismissable.
  ///
  /// That means that the user wont be able to close the sheet using gestures or back button.
  /// {@endtemplate}
  final bool isDismissable;

  /// {@template sliding_sheet.onDismissPrevented}
  /// A callback that gets invoked when a user tried to dismiss the dialog
  /// while [isDimissable] is `true`.
  /// {@endtemplate}
  final VoidCallback onDismissPrevented;

  /// Constructs a new `SlidingSheet` to be placed inside your widget tree.
  SlidingSheet({
    Key key,

    /// {@macro sliding_sheet.builder}
    @required SheetBuilder builder,

    /// {@macro sliding_sheet.headerBuilder}
    SheetBuilder headerBuilder,

    /// {@macro sliding_sheet.footerBuilder}
    SheetBuilder footerBuilder,

    /// {@macro sliding_sheet.snapSpec}
    SnapSpec snapSpec = const SnapSpec(),

    /// {@macro sliding_sheet.duration}
    Duration duration = const Duration(milliseconds: 1000),

    /// {@macro sliding_sheet.color}
    Color color = Colors.white,

    /// {@macro sliding_sheet.backdropColor}
    Color backdropColor,

    /// {@macro sliding_sheet.shadowColor}
    Color shadowColor = Colors.black54,

    /// {@macro sliding_sheet.elevation}
    double elevation = 0.0,

    /// {@macro sliding_sheet.padding}
    EdgeInsets padding,

    /// {@macro sliding_sheet.addTopViewPaddingWhenAtFullscreen}
    bool addTopViewPaddingOnFullscreen = false,

    /// {@macro sliding_sheet.margin}
    EdgeInsets margin,

    /// {@macro sliding_sheet.border}
    Border border,

    /// {@macro sliding_sheet.cornerRadius}
    double cornerRadius = 0.0,

    /// {@macro sliding_sheet.cornerRadiusOnFullscreen}
    double cornerRadiusOnFullscreen,

    /// {@macro sliding_sheet.closeOnBackdropTap}
    bool closeOnBackdropTap = false,

    /// {@macro sliding_sheet.listener}
    SheetListener listener,

    /// {@macro sliding_sheet.controller}
    SheetController controller,

    /// {@macro sliding_sheet.scrollSpec}
    ScrollSpec scrollSpec = const ScrollSpec(overscroll: false),

    /// {@macro sliding_sheet.maxWidth}
    double maxWidth = double.infinity,

    /// {@macro sliding_sheet.minHeight}
    double minHeight,

    /// {@macro sliding_sheet.closeSheetOnBackButtonPressed}
    bool closeSheetOnBackButtonPressed = false,
  }) : this._(
          key: key,
          builder: builder,
          headerBuilder: headerBuilder,
          footerBuilder: footerBuilder,
          snapSpec: snapSpec,
          duration: duration,
          color: color,
          backdropColor: backdropColor,
          shadowColor: shadowColor,
          elevation: elevation,
          padding: padding,
          addTopViewPaddingOnFullscreen: addTopViewPaddingOnFullscreen,
          margin: margin,
          border: border,
          cornerRadius: cornerRadius,
          cornerRadiusOnFullscreen: cornerRadiusOnFullscreen,
          closeOnBackdropTap: closeOnBackdropTap,
          listener: listener,
          controller: controller,
          scrollSpec: scrollSpec,
          maxWidth: maxWidth,
          minHeight: minHeight,
          closeSheetOnBackButtonPressed: closeSheetOnBackButtonPressed,
        );

  SlidingSheet._({
    Key key,
    @required this.builder,
    @required this.headerBuilder,
    @required this.footerBuilder,
    @required this.snapSpec,
    @required this.duration,
    @required this.color,
    @required this.backdropColor,
    @required this.shadowColor,
    @required this.elevation,
    @required this.padding,
    @required this.addTopViewPaddingOnFullscreen,
    @required this.margin,
    @required this.border,
    @required this.cornerRadius,
    @required this.cornerRadiusOnFullscreen,
    @required this.closeOnBackdropTap,
    @required this.listener,
    @required this.controller,
    @required this.scrollSpec,
    @required this.maxWidth,
    @required this.minHeight,
    @required this.closeSheetOnBackButtonPressed,
    this.route,
    this.isDismissable = true,
    this.onDismissPrevented,
  })  : assert(builder != null),
        assert(duration != null),
        assert(snapSpec != null),
        assert(snapSpec.snappings.length >= 2, 'There must be at least two snappings to snap in between.'),
        assert(snapSpec.minSnap != snapSpec.maxSnap || route != null, 'The min and max snaps cannot be equal.'),
        assert(isDismissable != null),
        super(key: key);

  @override
  _SlidingSheetState createState() => _SlidingSheetState();
}

class _SlidingSheetState extends State<SlidingSheet> with TickerProviderStateMixin {
  GlobalKey childKey;
  GlobalKey headerKey;
  GlobalKey footerKey;

  Widget child;
  Widget header;
  Widget footer;

  List<double> snappings;

  double childHeight = 0;
  double headerHeight = 0;
  double footerHeight = 0;
  double availableHeight = 0;

  bool didCompleteInitialRoute = false;
  // Whether a dismiss was already triggered by the sheet itself
  // and thus further route pops can be safely ignored.
  bool dismissUnderway = false;
  // The current sheet extent.
  _SheetExtent extent;
  // The ScrollController for the sheet.
  _DragableScrollableSheetController controller;

  // Whether the sheet has drawn its first frame.
  bool get isLaidOut => availableHeight > 0 && childHeight > 0;
  // The total height of all sheet components.
  double get sheetHeight => childHeight + headerHeight + footerHeight + padding.vertical + borderHeight;
  // The maxiumum height that this sheet will cover.
  double get maxHeight => math.min(sheetHeight, availableHeight);
  bool get isCoveringFullExtent => sheetHeight >= availableHeight;

  double get currentExtent => (extent?.currentExtent ?? minExtent).clamp(0.0, 1.0);
  set currentExtent(double value) => extent?.currentExtent = value;
  double get headerExtent => isLaidOut ? (headerHeight + (borderHeight / 2)) / availableHeight : 0.0;
  double get footerExtent => isLaidOut ? (footerHeight + (borderHeight / 2)) / availableHeight : 0.0;
  double get headerFooterExtent => headerExtent + footerExtent;
  double get minExtent => snappings[fromBottomSheet ? 1 : 0].clamp(0.0, 1.0);
  double get maxExtent => snappings.last.clamp(0.0, 1.0);

  bool get fromBottomSheet => widget.route != null;
  ScrollSpec get scrollSpec => widget.scrollSpec;
  SnapSpec get snapSpec => widget.snapSpec;
  SnapPositioning get snapPositioning => snapSpec.positioning;

  double get borderHeight => (widget.border?.top?.width ?? 0) * 2;
  EdgeInsets get padding {
    final begin = widget.padding ?? const EdgeInsets.all(0);

    if (!widget.addTopViewPaddingOnFullscreen || !isLaidOut) {
      return begin;
    }

    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final end = begin.copyWith(top: begin.top + statusBarHeight);
    return EdgeInsets.lerp(begin, end, lerpFactor);
  }

  double get cornerRadius {
    if (widget.cornerRadiusOnFullscreen == null) return widget.cornerRadius;
    return lerpDouble(widget.cornerRadius, widget.cornerRadiusOnFullscreen, lerpFactor);
  }

  double get lerpFactor {
    if (maxExtent != 1.0 && isLaidOut) return 0.0;

    final snap = snappings[math.max(snappings.length - 2, 0)];
    return Interval(
      snap >= 0.7 ? snap : 0.85,
      1.0,
    ).transform(currentExtent);
  }

  // The current state of this sheet.
  SheetState get state => SheetState(
        extent,
        extent: _reverseSnap(currentExtent),
        minExtent: _reverseSnap(minExtent),
        maxExtent: _reverseSnap(maxExtent),
        isLaidOut: isLaidOut,
      );

  @override
  void initState() {
    super.initState();
    // Assign the keys that will be used to determine the size of
    // the children.
    childKey = GlobalKey();
    headerKey = GlobalKey();
    footerKey = GlobalKey();

    _updateSnappingsAndExtent();

    // Call the listener when the extent or scroll position changes.
    void listener() {
      if (isLaidOut) {
        postFrame(() {
          final state = this.state;
          widget.listener?.call(state);
          widget.controller?._state = state;
        });
      }
    }

    controller = _DragableScrollableSheetController(
      this,
    )..addListener(listener);

    extent = _SheetExtent(
      controller,
      isFromBottomSheet: fromBottomSheet,
      snappings: snappings,
      listener: (extent) => listener(),
    );

    _assignSheetController();

    _measure();

    if (fromBottomSheet) {
      _initBottomSheet();
    } else {
      postFrame(
        () => setState(() => currentExtent = minExtent),
      );
    }
  }

  void _initBottomSheet() {
    postFrame(() {
      // Snap to the initial snap with a one frame delay when the
      // extents have been correctly calculated.
      snapToExtent(minExtent);

      // When the route gets popped we animate fully out - not just
      // to the minExtent.
      widget.route.popped.then(
        (_) {
          if (!dismissUnderway) {
            controller.jumpTo(controller.offset);
            controller.snapToExtent(0.0, this, clamp: false);
          }
        },
      );

      Future.delayed(widget.duration, () => didCompleteInitialRoute = true);
    });
  }

  @override
  void didUpdateWidget(SlidingSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assignSheetController();

    // Animate to the next snap if the SnapSpec changed and the sheet
    // is currently not interacted with.
    if (oldWidget.snapSpec != snapSpec) {
      _updateSnappingsAndExtent();
      _nudgeToNextSnap();
    }
  }

  // Measure the height of all sheet components.
  void _measure() {
    postFrame(() {
      final RenderBox child = childKey?.currentContext?.findRenderObject();
      final RenderBox header = headerKey?.currentContext?.findRenderObject();
      final RenderBox footer = footerKey?.currentContext?.findRenderObject();

      final isChildLaidOut = child?.hasSize == true;
      childHeight = isChildLaidOut ? child.size.height : 0;

      final isHeaderLaidOut = header?.hasSize == true;
      headerHeight = isHeaderLaidOut ? header.size.height : 0;

      final isFooterLaidOut = footer?.hasSize == true;
      footerHeight = isFooterLaidOut ? footer.size.height : 0;

      _updateSnappingsAndExtent();
    });
  }

  // A snap is defined relative to its availableHeight.
  // Here we handle all available snap positions and normalize them
  // to the availableHeight.
  double _normalizeSnap(double snap) {
    void isValidRelativeSnap([String message]) {
      assert(
        SnapSpec._isSnap(snap) || (snap >= 0.0 && snap <= 1.0),
        message ?? 'Relative snap $snap is not between 0 and 1.',
      );
    }

    if (availableHeight > 0) {
      final maxPossibleExtent = isLaidOut ? (sheetHeight / availableHeight).clamp(0.0, 1.0) : 1.0;
      double extent = snap;
      switch (snapPositioning) {
        case SnapPositioning.relativeToAvailableSpace:
          isValidRelativeSnap();
          break;
        case SnapPositioning.relativeToSheetHeight:
          isValidRelativeSnap();
          extent = (snap * maxHeight) / availableHeight;
          break;
        case SnapPositioning.pixelOffset:
          extent = snap / availableHeight;
          break;
        default:
          return snap.clamp(0.0, 1.0);
      }

      if (snap == SnapSpec.headerSnap) {
        assert(header != null, 'There is no available header to snap to!');
        extent = headerExtent;
      } else if (snap == SnapSpec.footerSnap) {
        assert(footer != null, 'There is no available footer to snap to!');
        extent = footerExtent;
      } else if (snap == SnapSpec.headerFooterSnap) {
        assert(header != null || footer != null, 'There is neither a header nor a footer to snap to!');
        extent = headerFooterExtent;
      } else if (snap == double.infinity) {
        extent = maxPossibleExtent;
      }

      return math.min(extent, maxPossibleExtent).clamp(0.0, 1.0);
    } else {
      return snap.clamp(0.0, 1.0);
    }
  }

  // Reverse a normalized snap.
  double _reverseSnap(double snap) {
    if (isLaidOut && childHeight > 0) {
      switch (snapPositioning) {
        case SnapPositioning.relativeToAvailableSpace:
          return snap;
        case SnapPositioning.relativeToSheetHeight:
          return snap * (availableHeight / sheetHeight);
        case SnapPositioning.pixelOffset:
          return snap * availableHeight;
        default:
          return snap.clamp(0.0, 1.0);
      }
    } else {
      return snap.clamp(0.0, 1.0);
    }
  }

  void _updateSnappingsAndExtent() {
    snappings = snapSpec.snappings.map(_normalizeSnap).toList()..sort();

    if (extent != null) {
      extent
        ..snappings = snappings
        ..targetHeight = maxHeight
        ..childHeight = childHeight
        ..headerHeight = headerHeight
        ..footerHeight = footerHeight
        ..availableHeight = availableHeight
        ..maxExtent = maxExtent
        ..minExtent = minExtent;
    }
  }

  // Assign the controller functions to actual methods.
  void _assignSheetController() {
    final controller = widget.controller;
    if (controller != null) {
      // Assign the controller functions to the state functions.
      if (!fromBottomSheet) controller._rebuild = rebuild;
      controller._scrollTo = scrollTo;
      controller._snapToExtent = (snap, {duration}) => snapToExtent(_normalizeSnap(snap), duration: duration);
      controller._expand = () => snapToExtent(maxExtent);
      controller._collapse = () => snapToExtent(minExtent);
      controller._show = () async {
        if (state.isHidden) return snapToExtent(minExtent, clamp: false);
      };
      controller._hide = () async {
        if (state.isShown) return snapToExtent(0.0, clamp: false);
      };
    }
  }

  Future snapToExtent(double snap, {Duration duration, double velocity = 0, bool clamp}) async {
    if (!isLaidOut) return null;

    duration ??= widget.duration;
    if (!state.isAtTop) {
      duration *= 0.5;
      await controller.animateTo(
        0,
        duration: duration,
        curve: Curves.easeInCubic,
      );
    }

    return controller.snapToExtent(
      snap,
      this,
      duration: duration,
      velocity: velocity,
      clamp: clamp ?? (!fromBottomSheet || (fromBottomSheet && snap != 0.0)),
    );
  }

  Future scrollTo(double offset, {Duration duration, Curve curve}) async {
    if (!isLaidOut) return null;

    duration ??= widget.duration;
    if (!extent.isAtMax) {
      duration *= 0.5;
      await snapToExtent(
        maxExtent,
        duration: duration,
      );
    }

    return controller.animateTo(
      offset,
      duration: duration ?? widget.duration,
      curve: curve ?? (!extent.isAtMax ? Curves.easeOutCirc : Curves.ease),
    );
  }

  void _nudgeToNextSnap() {
    if (!controller.inInteraction) {
      controller.imitateFling();
    }
  }

  void _pop(double velocity) {
    if (fromBottomSheet && !dismissUnderway && Navigator.canPop(context)) {
      dismissUnderway = true;
      Navigator.pop(context);
    }

    snapToExtent(fromBottomSheet ? 0.0 : minExtent, velocity: velocity);
  }

  void rebuild() {
    _callBuilders();
    _measure();
  }

  void _callBuilders() {
    if (context != null) {
      header = _delegateInteractions(widget.headerBuilder?.call(context, state));
      footer = _delegateInteractions(widget.footerBuilder?.call(context, state));
      child = widget.builder?.call(context, state);
    }
  }

  // Ensure that the sheet sizes itself correctly when the
  // constraints change.
  void _detectChangesInAvailableHeight(double previousHeight) {
    if (previousHeight > 0 && previousHeight != availableHeight) {
      _updateSnappingsAndExtent();

      final changeAdjustedExtent = ((currentExtent * previousHeight) / availableHeight).clamp(minExtent, maxExtent);

      bool isAroundFixedSnap = false;
      for (final snap in snappings) {
        isAroundFixedSnap = (snap - changeAdjustedExtent).abs() < 0.01;
        if (isAroundFixedSnap) {
          break;
        }
      }

      // Only update the currentExtent when its sitting at an extent that
      // is depenent on a fixed height, such as SnapSpec.headerSnap or absolute
      // snap values.
      if (isAroundFixedSnap) {
        currentExtent = changeAdjustedExtent;
      }
    }
  }

  void _handleChangesInChildSize() {
    _measure();
    postFrame(() {
      currentExtent = currentExtent.clamp(minExtent, maxExtent);
      _nudgeToNextSnap();
    });
  }

  @override
  Widget build(BuildContext context) {
    rebuild();

    final sheet = LayoutBuilder(
      builder: (context, constrainst) {
        final previousHeight = availableHeight;
        availableHeight = constrainst.biggest.height;
        _detectChangesInAvailableHeight(previousHeight);

        return NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (notification) {
            _handleChangesInChildSize();
            return true;
          },
          // ValueListenableBuilder is used to update the sheet irrespective of its children.
          child: ValueListenableBuilder(
            valueListenable: extent._currentExtent,
            builder: (context, value, _) {
              // Hide the sheet for the first frame until the extents are
              // correctly measured.
              return Visibility(
                visible: isLaidOut,
                maintainInteractivity: false,
                maintainSemantics: true,
                maintainSize: true,
                maintainState: true,
                maintainAnimation: true,
                child: Stack(
                  children: <Widget>[
                    _buildBackdrop(),
                    _buildSheet(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (!widget.closeSheetOnBackButtonPressed && !fromBottomSheet) {
      return sheet;
    }

    return WillPopScope(
      onWillPop: () async {
        if (fromBottomSheet) {
          if (!widget.isDismissable) {
            widget.onDismissPrevented?.call();
            return false;
          }
        } else {
          if (!state.isCollapsed) {
            snapToExtent(minExtent);
            return false;
          }
        }

        return true;
      },
      child: sheet,
    );
  }

  Widget _buildSheet() {
    final theme = Theme.of(context);

    // Wrap the scrollView in a ScrollConfiguration to
    // remove the default overscroll effect.
    Widget scrollView = Listener(
      onPointerUp: (_) {
        // didEndScroll doesn't work reliably in ScrollPosition. There
        // should be a better solution to this problem.
        if (currentExtent < minExtent && fromBottomSheet && !widget.isDismissable) {
          snapToExtent(minExtent);
          widget.onDismissPrevented?.call();
        }
      },
      child: ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: SingleChildScrollView(
          controller: controller,
          physics: scrollSpec.physics ?? const ScrollPhysics(),
          padding: EdgeInsets.only(
            top: header == null ? padding.top : 0.0,
            bottom: footer == null ? padding.bottom : 0.0,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: widget.minHeight ?? 0.0),
            child: SizeChangedLayoutNotifier(
              key: childKey,
              child: child,
            ),
          ),
        ),
      ),
    );

    // Add the overscroll if required again if required
    if (scrollSpec.overscroll) {
      scrollView = GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: scrollSpec.overscrollColor ?? theme.accentColor,
        child: scrollView,
      );
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth ?? double.infinity,
        ),
        child: SizedBox.expand(
          child: FractionallySizedBox(
            heightFactor: isLaidOut ? currentExtent.clamp(headerFooterExtent, 1.0) : 1.0,
            alignment: Alignment.bottomCenter,
            child: FractionalTranslation(
              translation: Offset(
                0,
                headerFooterExtent > 0.0
                    ? (1 - (currentExtent.clamp(0.0, headerFooterExtent) / headerFooterExtent))
                    : 0.0,
              ),
              child: _SheetContainer(
                color: widget.color ?? Colors.white,
                border: widget.border,
                margin: widget.margin,
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  header != null ? padding.top : 0.0,
                  padding.right,
                  footer != null ? padding.bottom : 0.0,
                ),
                elevation: widget.elevation,
                shadowColor: widget.shadowColor,
                customBorders: BorderRadius.vertical(
                  top: Radius.circular(cornerRadius),
                ),
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(height: headerHeight),
                        Expanded(child: scrollView),
                        SizedBox(height: footerHeight),
                      ],
                    ),
                    if (header != null)
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizeChangedLayoutNotifier(
                          key: headerKey,
                          child: header,
                        ),
                      ),
                    if (footer != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizeChangedLayoutNotifier(
                          key: footerKey,
                          child: footer,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackdrop() {
    double opacity = 0.0;
    if (!widget.isDismissable && didCompleteInitialRoute) {
      opacity = 1.0;
    } else if (currentExtent != 0.0) {
      opacity = (currentExtent / minExtent).clamp(0.0, 1.0);
    }

    return Visibility(
      visible: widget.closeOnBackdropTap,
      child: GestureDetector(
        onTap: widget.closeOnBackdropTap
            ? () {
                if (widget.isDismissable) {
                  _pop(0.0);
                } else {
                  widget.onDismissPrevented?.call();
                }
              }
            : null,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: widget.backdropColor,
          ),
        ),
      ),
    );
  }

  Widget _delegateInteractions(Widget child) {
    if (child == null) return child;

    double start = 0;
    double end = 0;

    void onDragEnd([double velocity = 0.0]) {
      controller.imitateFling(velocity);

      // If a header was dragged, but the scroll view is not at the top
      // animate to the top when the drag has ended.
      if (!state.isAtTop && (start - end).abs() > 5) {
        controller.animateTo(0.0, duration: widget.duration * .5, curve: Curves.ease);
      }
    }

    return GestureDetector(
      onVerticalDragStart: (details) {
        start = details.localPosition.dy;
        end = start;
      },
      onVerticalDragUpdate: (details) {
        end = details.localPosition.dy;
        final delta = details.delta.dy;
        controller.imitiateDrag(delta);
        print('update');
      },
      onVerticalDragEnd: (details) {
        final velocity = swapSign(details.velocity.pixelsPerSecond.dy);
        onDragEnd(velocity);
        print('end');
      },
      onVerticalDragCancel: onDragEnd,
      child: child,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// A data class containing state information about the [_SlidingSheetState].
class SheetState {
  /// The current extent the sheet covers.
  final double extent;

  /// The minimum extent that the sheet will cover.
  final double minExtent;

  /// The maximum extent that the sheet will cover
  /// until it begins scrolling.
  final double maxExtent;

  /// Whether the sheet has finished measuring its children and computed
  /// the correct extents. This takes until the first frame was drawn.
  final bool isLaidOut;

  /// The progress between [minExtent] and [maxExtent] of the current [extent].
  /// A progress of 1 means the sheet is fully expanded, while
  /// a progress of 0 means the sheet is fully collapsed.
  final double progress;

  /// The scroll offset when the content is bigger than the available space.
  final double scrollOffset;

  /// Whether the [SlidingSheet] has reached its maximum extent.
  final bool isExpanded;

  /// Whether the [SlidingSheet] has reached its minimum extent.
  final bool isCollapsed;

  /// Whether the [SlidingSheet] has a [scrollOffset] of zero.
  final bool isAtTop;

  /// Whether the [SlidingSheet] has reached its maximum scroll extent.
  final bool isAtBottom;

  /// Whether the sheet is hidden to the user.
  final bool isHidden;

  /// Whether the sheet is visible to the user.
  final bool isShown;
  SheetState(
    _SheetExtent _extent, {
    @required this.extent,
    @required this.isLaidOut,
    @required this.maxExtent,
    @required double minExtent,
    // On Bottomsheets it is possible for min and maxExtents to be the same (when you only set one snap).
    // Thus we have to account for this and set the minExtent to be zero.
  })  : minExtent = minExtent != maxExtent ? minExtent : 0.0,
        progress = isLaidOut ? ((extent - minExtent) / (maxExtent - minExtent)).clamp(0.0, 1.0) : 0.0,
        scrollOffset = _extent?.scrollOffset ?? 0,
        isExpanded = _toPrecision(extent) >= _toPrecision(maxExtent),
        isCollapsed = _toPrecision(extent) <= _toPrecision(minExtent),
        isAtTop = _extent?.isAtTop ?? true,
        isAtBottom = _extent?.isAtBottom ?? false,
        isHidden = extent <= 0.0,
        isShown = extent > 0.0;

  // Allow for a slight deviation.
  static double _toPrecision(double value, [int precision = 3]) {
    return double.parse(value.toStringAsFixed(precision));
  }

  factory SheetState.inital() => SheetState(null, extent: 0.0, minExtent: 0.0, maxExtent: 1.0, isLaidOut: false);

  @override
  String toString() {
    return 'SheetState(extent: $extent, minExtent: $minExtent, maxExtent: $maxExtent, isLaidOut: $isLaidOut, progress: $progress, scrollOffset: $scrollOffset, isExpanded: $isExpanded, isCollapsed: $isCollapsed, isAtTop: $isAtTop, isAtBottom: $isAtBottom, isHidden: $isHidden, isShown: $isShown)';
  }
}

/// A controller for a [SlidingSheet].
class SheetController {
  /// Animates the sheet to the [extent].
  ///
  /// The [extent] will be clamped to the minimum and maximum extent.
  /// If the scrolling child is not at the top, it will scroll to the top
  /// first and then animate to the specified extent.
  Future snapToExtent(double extent, {Duration duration}) => _snapToExtent?.call(extent, duration: duration);
  Future Function(double extent, {Duration duration}) _snapToExtent;

  /// Animates the scrolling child to a specified offset.
  ///
  /// If the sheet is not fully expanded it will expand first and then
  /// animate to the given [offset].
  Future scrollTo(double offset, {Duration duration, Curve curve}) =>
      _scrollTo?.call(offset, duration: duration, curve: curve);
  Future Function(double offset, {Duration duration, Curve curve}) _scrollTo;

  /// Calls every builder function of the sheet to rebuild the widgets with
  /// the current [SheetState].
  ///
  /// This function can be used to reflect changes on the [SlidingSheet]
  /// without calling `setState(() {})` on the parent widget if that would be
  /// too expensive.
  void rebuild() => _rebuild?.call();
  VoidCallback _rebuild;

  /// Fully collapses the sheet.
  ///
  /// Short-hand for calling `snapToExtent(minExtent)`.
  Future collapse() => _collapse?.call();
  Future Function() _collapse;

  /// Fully expands the sheet.
  ///
  /// Short-hand for calling `snapToExtent(maxExtent)`.
  Future expand() => _expand?.call();
  Future Function() _expand;

  /// Reveals the [SlidingSheet] if it is currently hidden.
  Future show() => _show?.call();
  Future Function() _show;

  /// Slides the sheet off to the bottom and hides it.
  Future hide() => _hide?.call();
  Future Function() _hide;

  SheetState _state;
  SheetState get state => _state;
}

/// A custom [Container] for a [SlidingSheet].
class _SheetContainer extends StatelessWidget {
  final double borderRadius;
  final double elevation;
  final Border border;
  final BorderRadius customBorders;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget child;
  final Color color;
  final Color shadowColor;
  final List<BoxShadow> boxShadows;
  final AlignmentGeometry alignment;
  final BoxConstraints constraints;
  _SheetContainer({
    Key key,
    this.borderRadius = 0.0,
    this.elevation = 0.0,
    this.border,
    this.customBorders,
    this.margin,
    this.padding = const EdgeInsets.all(0),
    this.child,
    this.color = Colors.transparent,
    this.shadowColor = Colors.black12,
    this.boxShadows,
    this.alignment,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final br = customBorders ?? BorderRadius.circular(borderRadius);

    final List<BoxShadow> boxShadow = boxShadows ?? elevation != 0
        ? [
            BoxShadow(
              color: shadowColor ?? Colors.black12,
              blurRadius: elevation,
              spreadRadius: 0,
            ),
          ]
        : const [];

    return Container(
      margin: margin,
      padding: padding,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        color: color,
        borderRadius: br,
        boxShadow: boxShadow,
        border: border,
        shape: BoxShape.rectangle,
      ),
      child: ClipRRect(
        borderRadius: br,
        child: child,
      ),
    );
  }
}
