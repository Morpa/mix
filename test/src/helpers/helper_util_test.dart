import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';
import 'package:mix/src/helpers/helper_util.dart';

import '../../helpers/testing_utils.dart';

void main() {
  group('shouldApplyModifiers', () {
    test('returns child when no ModifierAttribute is present', () {
      final style = Style();

      final mix = style.of(MockBuildContext());
      final child = Container();

      final result = shouldApplyModifiers(mix: mix, child: child);

      expect(result, equals(child));
    });

    test('returns RenderModifiers when ModifierAttribute is present', () {
      final style = Style(
        $with.opacity(0.5),
      );

      final mix = style.of(MockBuildContext());
      final child = Container();

      final result = shouldApplyModifiers(mix: mix, child: child);

      expect(result, isA<RenderModifiers>());
      expect((result as RenderModifiers).mix, equals(mix));
      expect((result).child, equals(child));
    });
  });

  group('SpreadFunctionParams', () {
    test('calls the function with provided parameters', () {
      fn(List<int> params) => params.reduce((a, b) => a + b);
      final spreadFn = SpreadFunctionParams<int, int>(fn);

      final result = spreadFn(1, 2, 3, 4, 5);

      expect(result, equals(15));
    });

    test('calls the function with only non-null parameters', () {
      fn(List<String> params) => params.join(', ');
      final spreadFn = SpreadFunctionParams<String, String>(fn);

      final result = spreadFn('a', null, 'b', null, 'c');

      expect(result, equals('a, b, c'));
    });

    test(
        'calls the function with an empty list when no parameters are provided',
        () {
      bool called = false;
      fn(List<double> params) {
        called = true;
        return params.length;
      }

      final spreadFn = SpreadFunctionParams<double, int>(fn);

      final result = spreadFn();

      expect(called, isTrue);
      expect(result, equals(0));
    });

    test('supports up to 20 optional parameters', () {
      fn(List<int> params) => params.length;
      final spreadFn = SpreadFunctionParams<int, int>(fn);

      final result = spreadFn(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
          16, 17, 18, 19, 20);

      expect(result, equals(20));
    });
  });
}
