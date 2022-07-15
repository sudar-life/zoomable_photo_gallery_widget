import 'package:flutter/material.dart';

class IndecatorWidget extends StatelessWidget {
  final int length;
  final int activeIndex;
  final Color? activeColor;
  final Color? normalColor;
  final double? size;
  const IndecatorWidget({
    Key? key,
    required this.length,
    required this.activeIndex,
    this.activeColor,
    this.size = 5,
    this.normalColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: index == activeIndex
                  ? activeColor ?? Colors.blue
                  : normalColor ?? Colors.grey,
            ),
          ),
        ).toList(),
      ),
    );
  }
}
