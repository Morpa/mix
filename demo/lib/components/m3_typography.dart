import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mix/mix.dart';

class M3TokensTypographyExampleTile extends HookWidget {
  const M3TokensTypographyExampleTile({super.key});
  @override
  Widget build(BuildContext context) {
    final onSurfaceMix = StyleMix(
      textStyle(color: Colors.black),
      onDark(
        textStyle(color: Colors.white),
      ),
    );

    final headingMix = StyleMix.fromAttributes([
      textStyle(fontSize: 22),
      ...onSurfaceMix.toAttributes(),
    ]);

    return ExpansionTile(
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.topLeft,
      title: StyledText(
        "Material 3 Typography",
        style: headingMix,
      ),
      tilePadding: const EdgeInsets.all(0),
      children: [
        ...$M3Text.tokens
            .map(
              (token, style) => MapEntry(
                token,
                StyledText(
                  "This is ${token.name}.",
                  style: onSurfaceMix.merge(
                    StyleMix(
                      textStyle(as: token),
                    ),
                  ),
                ),
              ),
            )
            .values
            .toList(),
      ],
    );
  }
}
