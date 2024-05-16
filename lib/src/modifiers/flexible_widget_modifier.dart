// ignore_for_file: prefer-named-boolean-parameters

import 'package:flutter/material.dart';

import '../attributes/scalars/scalar_util.dart';
import '../core/attribute.dart';
import '../core/modifier.dart';
import '../factory/mix_provider_data.dart';
import '../helpers/lerp_helpers.dart';

class FlexibleModifierSpec extends ModifierSpec<FlexibleModifierSpec> {
  final int? flex;
  final FlexFit? fit;
  const FlexibleModifierSpec({this.flex, this.fit});

  @override
  FlexibleModifierSpec lerp(FlexibleModifierSpec? other, double t) {
    return FlexibleModifierSpec(
      flex: lerpInt(flex, other?.flex, t),
      fit: lerpSnap(fit, other?.fit, t),
    );
  }

  @override
  FlexibleModifierSpec copyWith({int? flex, FlexFit? fit}) {
    return FlexibleModifierSpec(flex: flex ?? this.flex, fit: fit ?? this.fit);
  }

  @override
  get props => [flex, fit];

  @override
  Widget build(Widget child) {
    return Flexible(
      flex: flex ?? 1,
      fit: fit ?? FlexFit.loose,
      child: child,
    );
  }
}

/// A modifier that wraps a widget with the [Flexible] widget.
///
/// The [Flexible] widget is used to create a flexible space in a [Row], [Column], or [Flex] widget.
class FlexibleModifierAttribute
    extends ModifierAttribute<FlexibleModifierAttribute, FlexibleModifierSpec> {
  final int? flex;
  final FlexFit? fit;
  const FlexibleModifierAttribute({this.flex, this.fit});

  @override
  FlexibleModifierAttribute merge(FlexibleModifierAttribute? other) {
    return FlexibleModifierAttribute(
      flex: other?.flex ?? flex,
      fit: other?.fit ?? fit,
    );
  }

  @override
  FlexibleModifierSpec resolve(MixData mix) {
    return FlexibleModifierSpec(flex: flex, fit: fit);
  }

  @override
  get props => [flex, fit];
}

class FlexibleModifierUtility<T extends Attribute>
    extends MixUtility<T, FlexibleModifierAttribute> {
  const FlexibleModifierUtility(super.builder);
  FlexFitUtility<T> get fit => FlexFitUtility((fit) => call(fit: fit));
  IntUtility<T> get flex => IntUtility((flex) => call(flex: flex));
  T tight({int? flex}) =>
      builder(FlexibleModifierAttribute(flex: flex, fit: FlexFit.tight));
  T loose({int? flex}) =>
      builder(FlexibleModifierAttribute(flex: flex, fit: FlexFit.loose));
  T expanded({int? flex}) => tight(flex: flex);

  T call({int? flex, FlexFit? fit}) {
    return builder(FlexibleModifierAttribute(flex: flex, fit: fit));
  }
}
