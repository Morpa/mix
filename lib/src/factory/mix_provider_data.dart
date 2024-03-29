import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../attributes/variant_attribute.dart';
import '../core/attribute.dart';
import '../core/attributes_map.dart';
import '../helpers/compare_mixin.dart';
import '../theme/token_resolver.dart';
import 'style_mix.dart';

/// This class is used for encapsulating all [MixData] related operations.
/// It contains a mixture of properties and methods useful for handling different attributes,
/// decorators and token resolvers.
@immutable
class MixData with Comparable {
  final AnimatedData? animation;

  // Instance variables for widget attributes, widget decorators and token resolver.
  final AttributeMap _attributes;

  final MixTokenResolver _tokenResolver;

  /// A Private constructor for the [MixData] class that initializes its main variables.
  ///
  /// It takes in [attributes] and [resolver] as required parameters.
  MixData._({
    required MixTokenResolver resolver,
    required AttributeMap attributes,
    required this.animation,
  })  : _attributes = attributes,
        _tokenResolver = resolver;

  factory MixData.create(BuildContext context, Style style) {
    final attributeList = applyContextToVisualAttributes(context, style);

    final resolver = MixTokenResolver(context);

    return MixData._(
      resolver: resolver,
      attributes: AttributeMap(attributeList),
      animation: style is AnimatedStyle ? style.animatedData : null,
    );
  }

  /// Alias for animation.isAnimated
  bool get isAnimated => animation != null;

  /// Getter for [MixTokenResolver].
  ///
  /// Returns [_tokenResolver].
  MixTokenResolver get tokens => _tokenResolver;

  /// Getter for [_attributes].
  ///
  /// Returns [_attributes].
  @visibleForTesting
  AttributeMap get attributes => _attributes;

  @internal
  MixData toInheritable() {
    final inheritableAttributes = _attributes.values.where(
      (attr) => attr.isInheritable,
    );

    return copyWith(attributes: AttributeMap(inheritableAttributes));
  }

  /// Finds and returns an [VisualAttribute] of type [A], or null if not found.
  A? attributeOf<A extends StyleAttribute>() {
    final attributes = _attributes.whereType<A>();
    if (attributes.isEmpty) return null;

    return _mergeAttributes(attributes) ?? attributes.last;
  }

  Iterable<A> whereType<A extends StyleAttribute>() {
    return _attributes.whereType();
  }

  bool contains<T>() {
    return _attributes.values.any((attr) => attr is T);
  }

  Value? resolvableOf<Value, A extends SpecAttribute<A, Value>>() {
    final attribute = _attributes.attributeOfType<A>();

    return attribute?.resolve(this);
  }

  // /// Merges this [MixData] with another, prioritizing this instance's properties.
  MixData merge(MixData other) {
    return MixData._(
      resolver: _tokenResolver,
      attributes: _attributes.merge(other._attributes),
      animation: other.animation ?? animation,
    );
  }

  MixData copyWith({
    AttributeMap? attributes,
    AnimatedData? animation,
    MixTokenResolver? resolver,
  }) {
    return MixData._(
      resolver: resolver ?? _tokenResolver,
      attributes: attributes ?? _attributes,
      animation: animation ?? this.animation,
    );
  }

  /// Used for Comparable mixin.
  @override
  get props => [_attributes, animation];
}

@visibleForTesting
List<StyleAttribute> applyContextToVisualAttributes(
  BuildContext context,
  Style mix,
) {
  final builtAttributes = _applyStyleBuilder(context, mix.styles.values);

  Style style = Style.create(builtAttributes);

  final variantAttributes = mix.variants.whereType<StyleVariantAttribute>();

  // Once there are no more context variants to apply, return the mix
  if (variantAttributes.isEmpty) {
    return style.styles.values;
  }

  for (final variant in variantAttributes) {
    style = _applyVariants(context, style, variant);
  }

  return applyContextToVisualAttributes(context, style);
}

Style _applyVariants(
  BuildContext context,
  Style style,
  StyleVariantAttribute variantAttribute,
) {
  return variantAttribute.variant.when(context)
      ? style.merge(variantAttribute.value)
      : style;
}

M? _mergeAttributes<M extends StyleAttribute>(Iterable<M> mergeables) {
  if (mergeables.isEmpty) return null;

  return mergeables.reduce((a, b) {
    return a is Mergeable ? (a as Mergeable).merge(b) : b;
  });
}

class AnimatedData with Comparable {
  final Duration duration;
  final Curve curve;
  const AnimatedData({required this.duration, required this.curve});

  factory AnimatedData.withDefaults({Duration? duration, Curve? curve}) {
    return AnimatedData(
      duration: duration ?? const Duration(milliseconds: 150),
      curve: curve ?? Curves.linear,
    );
  }

  @override
  get props => [duration, curve];
}

Iterable<Attribute> _applyStyleBuilder(
  BuildContext context,
  List<Attribute> attributes,
) {
  return attributes.map((attr) {
    if (attr is StyleAttributeBuilder) {
      return attr.builder(context);
    }

    return attr;
    // ignore: avoid-inferrable-type-arguments
  }).whereType<Attribute>();
}
