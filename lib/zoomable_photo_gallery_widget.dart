import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:zoomable_photo_gallery/indecator_widget.dart';
import 'package:zoomable_photo_gallery/multi_gesture_detector.dart';

class ZoomablePhotoController extends PageController {}

enum IndicatorLocation {
  BOTTOM_CENTER(Alignment.bottomCenter),
  BOTTOM_LEFT(Alignment.bottomLeft),
  BOTTOM_RIGHT(Alignment.bottomRight),
  TOP_CENTER(Alignment.topCenter),
  TOP_LEFT(Alignment.topLeft),
  TOP_RIGHT(Alignment.topRight);

  const IndicatorLocation(this.alignment);
  final Alignment alignment;
}

class ZoomablePhotoGallery extends StatefulWidget {
  final List<Widget> imageList;
  final ZoomablePhotoController? controller;
  final IndicatorLocation location;
  final int initIndex;
  final double? height;
  final Color? backColor;
  final double maxZoom;
  final double minZoom;
  final List<Widget>? indicator;
  final Function(int)? changePage;
  final Function()? onTap;

  ZoomablePhotoGallery({
    Key? key,
    required this.imageList,
    this.initIndex = 0,
    this.location = IndicatorLocation.BOTTOM_CENTER,
    this.controller,
    this.backColor = Colors.black,
    this.height,
    this.maxZoom = 2.5,
    this.minZoom = 0.5,
    this.changePage,
    this.indicator,
    this.onTap,
  }) : super(key: key);

  @override
  State<ZoomablePhotoGallery> createState() => _ZoomablePhotoGalleryState();
}

class _ZoomablePhotoGalleryState extends State<ZoomablePhotoGallery>
    with TickerProviderStateMixin {
  late int activeIndex;
  List<Widget>? fishinggramImageWidget;
  late PageController _pageController;

  final TransformationController _transformationController =
      TransformationController();
  Animation<Matrix4>? _animationReset;
  late AnimationController _controllerReset;

  @override
  void initState() {
    super.initState();
    _pageController = widget.controller ?? PageController();
    makcFishinggramImageWidget();
    _controllerReset = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    activeIndex = widget.initIndex;
    if (widget.initIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _pageController.jumpToPage(widget.initIndex));
    }

    _pageController.addListener(() {
      if (_pageController.page == _pageController.page?.floor()) {
        activeIndex = _pageController.page!.toInt() % widget.imageList.length;
        if (widget.changePage != null) {
          widget.changePage!(activeIndex);
        }
        update();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ZoomablePhotoGallery oldWidget) {
    makcFishinggramImageWidget();
    super.didUpdateWidget(oldWidget);
  }

  void update() => setState(() {});

  void _onAnimateReset() {
    _transformationController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset!.removeListener(_onAnimateReset);
      _animationReset = null;
      _controllerReset.reset();
    }
  }

  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    if (_controllerReset.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }

  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(_controllerReset);
    _animationReset!.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    Future.delayed(const Duration(milliseconds: 200), () {
      _animateResetInitialize();
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void makcFishinggramImageWidget() {
    fishinggramImageWidget = List.generate(
      widget.imageList.length,
      (index) => InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(double.infinity),
          transformationController: _transformationController,
          minScale: widget.minZoom,
          maxScale: widget.maxZoom,
          onInteractionStart: _onInteractionStart,
          onInteractionEnd: _onInteractionEnd,
          alignPanAxis: true,
          panEnabled: false,
          child: widget.imageList[index]),
    );
  }

  @override
  void dispose() {
    _controllerReset.dispose();
    super.dispose();
  }

  bool _pagingEnabled = true;
  double startX = 0;

  void _onTouchDown(int touchCount, List<PointerDetail> touchDetails) {
    if (touchCount > 1) {
      _pagingEnabled = false;
      update();
    }
  }

  void _onTouchUp(int touchCount, List<PointerDetail> touchDetails) {
    if (touchCount == 0) {
      _pagingEnabled = true;
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    var bottom = 0.0;
    var top = 0.0;
    switch (widget.location) {
      case IndicatorLocation.BOTTOM_CENTER:
      case IndicatorLocation.BOTTOM_LEFT:
      case IndicatorLocation.BOTTOM_RIGHT:
        bottom = 20 +
            (widget.height == null ? MediaQuery.of(context).padding.bottom : 0);
        break;
      case IndicatorLocation.TOP_CENTER:
      case IndicatorLocation.TOP_LEFT:
      case IndicatorLocation.TOP_RIGHT:
        top = 20;
        break;
    }
    return MultiGestureDetector(
      onTouchDown: _onTouchDown,
      onTouchUp: _onTouchUp,
      onTap: () {
        if (widget.onTap != null) widget.onTap!();
      },
      child: Container(
        height: widget.height ?? MediaQuery.of(context).size.height,
        color: widget.backColor,
        child: Stack(
          children: [
            PageView.builder(
              physics: _pagingEnabled
                  ? const CustomPageViewScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              controller: _pageController,
              itemBuilder: (_, index) {
                return fishinggramImageWidget![index % widget.imageList.length];
              },
            ),
            const SizedBox(height: 10),
            Positioned(
              left: 20,
              right: 20,
              bottom: bottom,
              top: top,
              child: Align(
                alignment: widget.location.alignment,
                child: widget.indicator == null
                    ? IndecatorWidget(
                        size: 7,
                        length: widget.imageList.length,
                        activeIndex: activeIndex,
                        activeColor: Colors.blue,
                        normalColor: Colors.grey,
                      )
                    : Wrap(children: widget.indicator!),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 50,
        stiffness: 100,
        damping: 1,
      );
}
