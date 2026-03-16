import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CustomLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final List<Color>? colors;

  const CustomLoader({
    super.key,
    this.size = 50.0,
    this.color,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;
    
    // Using ballSpinFadeLoader which matches the dotted circular animation
    // We can provide a list of colors for a gradient effect or a single color
    final indicatorColors = colors ?? [
      primaryColor,
      primaryColor.withOpacity(0.8),
      primaryColor.withOpacity(0.6),
      primaryColor.withOpacity(0.4),
      primaryColor.withOpacity(0.2),
    ];

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: LoadingIndicator(
          indicatorType: Indicator.ballSpinFadeLoader,
          colors: indicatorColors,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
