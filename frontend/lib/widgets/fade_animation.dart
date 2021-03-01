import 'package:flutter/widgets.dart';
import 'package:simple_animations/simple_animations.dart';

enum AniProps { opacity, translateY }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation({this.delay, this.child});

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AniProps>()
      ..add(AniProps.opacity, Tween(begin: 0.0, end: 1.0),
          Duration(milliseconds: 500), Curves.easeInOut)
      ..add(AniProps.translateY, Tween(begin: 20.0, end: 0.0),
          Duration(milliseconds: 500), Curves.easeInOut);

    // final tween = MultiTrackTween([
    //   Track("opacity")
    //       .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),
    //   Track("translateY").add(
    //       Duration(milliseconds: 500), Tween(begin: -15.0, end: 0.0),
    //       curve: Curves.easeOut)
    // ]);

    return CustomAnimation(
      delay: Duration(
        milliseconds: (150 * delay).round(),
      ),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, child, animation) => Opacity(
        opacity: animation.get(AniProps.opacity),
        child: Transform.translate(
            offset: Offset(
              0,
              animation.get(AniProps.translateY),
            ),
            child: child),
      ),
    );
  }
}
