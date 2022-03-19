import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatelessWidget {
  const MyFloatingActionButton(
      {Key? key,
      required this.showFab,
      required this.showShareIcon,
      this.onFabPress})
      : super(key: key);
  final bool showFab;
  final bool showShareIcon;
  final Function()? onFabPress;
  static const _opacityDuration = Duration(milliseconds: 200);
  static const _crossFadeDuration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
        duration: _opacityDuration,
        offset: showFab ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: _opacityDuration,
          opacity: showFab ? 1 : 0,
          child: FloatingActionButton(
              onPressed: (() {
                final _onFabPress = onFabPress;
                if (_onFabPress != null) {
                  _onFabPress();
                }
              }),
              tooltip: 'Add item',
              child: AnimatedCrossFade(
                duration: _crossFadeDuration,
                firstChild: const Icon(Icons.share),
                secondChild: const Icon(Icons.add),
                crossFadeState: showShareIcon
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              )),
        ));
  }
}
