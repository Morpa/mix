import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:mix_lint/src/utils/type_checker.dart';
import 'package:mix_lint/src/utils/visitors.dart';

class AvoidVariantInsideContextvariant extends DartLintRule {
  AvoidVariantInsideContextvariant() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_variant_inside_contextvariant',
    problemMessage:
        'Ensure that variants are not applied inside the contextVariant scope but rather combined using the & operator.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addSimpleIdentifier((identifier) {
      if (identifier.staticType == null) return;
      if (!contextVariantChecker.isAssignableFromType(identifier.staticType!)) {
        return;
      }

      final parent = identifier.parent?.parent?.parent
          ?.thisOrAncestorOfType<FunctionExpressionInvocation>();

      if (parent == null) return;

      final simpleIdentifiers = <SimpleIdentifier>[];
      final visitor = RecursiveSimpleIdentifierVisitor(
        onVisitSimpleIdentifier: simpleIdentifiers.add,
      );

      parent.argumentList.accept(visitor);

      final types = simpleIdentifiers.where((i) {
        if (i.staticType == null) return false;
        return variantChecker.isAssignableFromType(i.staticType!);
      }).toList();

      if (types.isEmpty) return;

      for (final type in types) {
        reporter.reportErrorForOffset(
          _code,
          type.offset,
          type.length,
        );
      }
    });
  }
}
