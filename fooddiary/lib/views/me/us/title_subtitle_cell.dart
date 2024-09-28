import 'package:fit_track/main/themes/app_theme.dart';
import 'package:flutter/material.dart';

class TitleSubtitleCell extends StatelessWidget {
  final String title;
  final String subtitle;
  const TitleSubtitleCell({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
      child: Column(
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                  colors: AppTheme.primaryG,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight)
                  .createShader(
                  Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            child: Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
          ),
          Text(
            subtitle,
            style:  TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
