import 'package:edu_verse/features/splash_v8/splash_v8_tokens.dart';
import 'package:flutter/material.dart';

class SplashV8WaveLoader extends StatelessWidget {
  const SplashV8WaveLoader({
    super.key,
    required this.animation,
    required this.reduceMotion,
  });

  final Animation<double> animation;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('splash-v8-loader'),
      height: 24,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List<Widget>.generate(8, (index) {
              final heightFactor = reduceMotion
                  ? 0.55
                  : _barHeightFactor(animation.value, index);

              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: index == 7 ? 0 : 4),
                  child: FractionallySizedBox(
                    alignment: Alignment.bottomCenter,
                    heightFactor: heightFactor,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            SplashV8Tokens.brandGreen,
                            SplashV8Tokens.brandBlue,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  double _barHeightFactor(double progress, int index) {
    final shifted = (progress - (index * 0.1)) % 1.0;
    final wave = 1 - ((shifted * 2 - 1).abs());
    return 0.25 + (0.75 * Curves.easeInOut.transform(wave));
  }
}
