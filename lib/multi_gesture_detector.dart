import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MultiGestureDetector extends StatefulWidget {
  Widget child;
  Function(int touchCount, List<PointerDetail> touchDetails)? onTouchDown;
  Function(int touchCount, List<PointerDetail> touchDetails)? onTouchMove;
  Function(int touchCount, List<PointerDetail> touchDetails)? onTouchUp;
  Function()? onTap;

  MultiGestureDetector({
    Key? key,
    required this.child,
    this.onTouchDown,
    this.onTouchMove,
    this.onTouchUp,
    this.onTap,
  }) : super(key: key);

  @override
  State<MultiGestureDetector> createState() => _MultiGestureDetectorState();
}

class _MultiGestureDetectorState extends State<MultiGestureDetector> {
  Set<PointerDetail> multiPointers = {};
  bool isMultiTouchOn = false;
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        var x = e.position.dx.round().toDouble();
        var y = (e.position.dy).round().toDouble();
        multiPointers.add(PointerDetail(id: e.pointer, x: x, y: y));
        if (multiPointers.length > 1) {
          isMultiTouchOn = true;
        }
        if (widget.onTouchDown != null) {
          widget.onTouchDown!(multiPointers.length, multiPointers.toList());
        }
      },
      onPointerMove: (e) {
        var x = e.position.dx.round().toDouble();
        var y = (e.position.dy).round().toDouble();
        multiPointers.where((m) => m.id == e.pointer).first.updatePointer(x, y);
        if (widget.onTouchMove != null) {
          widget.onTouchMove!(multiPointers.length, multiPointers.toList());
        }
      },
      onPointerUp: (e) {
        var x = e.position.dx.round().toDouble();
        var y = (e.position.dy).round().toDouble();
        var upPoint = multiPointers.where((m) => m.id == e.pointer).first;
        upPoint.endPointer(x, y);
        var distance = upPoint.movedDistance;
        multiPointers.remove(upPoint);
        if (widget.onTouchUp != null) {
          widget.onTouchUp!(multiPointers.length, multiPointers.toList());
        }
        if (widget.onTap != null &&
            multiPointers.isEmpty &&
            !isMultiTouchOn &&
            distance < 10) {
          widget.onTap!();
        }
        if (multiPointers.isEmpty) {
          isMultiTouchOn = false;
        }
      },
      onPointerCancel: (e) {
        multiPointers.clear();
      },
      child: widget.child,
    );
  }
}

class PointerDetail extends Equatable {
  final int? id;
  Point<double>? startPoint;
  Point<double>? updatePoint;
  Point<double>? endPoint;

  PointerDetail({
    required this.id,
    required double x,
    required double y,
  })  : startPoint = Point<double>(x, y),
        updatePoint = Point<double>(x, y),
        endPoint = Point<double>(x, y);

  updatePointer(double x, double y) {
    updatePoint = Point<double>(x, y);
  }

  endPointer(double x, double y) {
    endPoint = Point<double>(x, y);
  }

  double get movedDistance => startPoint!.distanceTo(endPoint!);

  @override
  List<int> get props => [id!];
}
