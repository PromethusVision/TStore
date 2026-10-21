import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

class MerchantPage extends StatelessWidget {
  const MerchantPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.onRefresh,
  });
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;
  @override
  Widget build(BuildContext context) {
    Widget body = LayoutBuilder(
      builder: (context, constraints) => ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth > 760
              ? (constraints.maxWidth - 720) / 2
              : 20,
          vertical: 20,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          for (final child in children)
            Padding(padding: const EdgeInsets.only(bottom: 16), child: child),
        ],
      ),
    );
    if (onRefresh != null) {
      body = RefreshIndicator(onRefresh: onRefresh!, child: body);
    }
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          errorMaxLines: 8,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: SafeArea(child: body),
      ),
    );
  }
}

/// Large text needs a full-width label instead of a clipped floating caption.
/// Keep the established compact decoration at ordinary text sizes.
class MerchantInput extends StatelessWidget {
  const MerchantInput({
    super.key,
    required this.labelText,
    required this.builder,
    this.hintText,
    this.suffixIcon,
  });
  final String labelText;
  final String? hintText;
  final Widget? suffixIcon;
  final Widget Function(InputDecoration decoration) builder;

  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(16) > 16 * 1.3;
    if (!large) {
      return builder(
        InputDecoration(
          labelText: labelText,
          hintText: hintText,
          suffixIcon: suffixIcon,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(child: Text(labelText)),
        const SizedBox(height: 8),
        Semantics(
          label: labelText,
          child: builder(
            InputDecoration(hintText: hintText, suffixIcon: suffixIcon),
          ),
        ),
      ],
    );
  }
}

/// Validate without sending anything; bring the first invalid field into view
/// after its error has been laid out. This callback never resumes a save.
bool merchantValidateForm(GlobalKey<FormState> key) {
  final form = key.currentState;
  if (form == null) return false;
  final invalid = form.validateGranularly();
  if (invalid.isEmpty) return true;
  FocusScope.of(form.context).unfocus();
  final field = invalid.first;
  final route = ModalRoute.of(field.context);
  BuildContext target = field.context;
  field.context.visitAncestorElements((element) {
    if (element.widget is MerchantInput) {
      target = element;
      return false;
    }
    return element.widget is! Form;
  });
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!field.mounted ||
        !target.mounted ||
        !field.hasError ||
        (route != null && !route.isCurrent)) {
      return;
    }
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 200),
      alignment: 0.1,
    );
  });
  return false;
}

class MerchantNotice extends StatelessWidget {
  const MerchantNotice(
    this.text, {
    super.key,
    this.error = false,
    this.onRetry,
  });
  final String text;
  final bool error;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: error ? EsnaftaVarColors.errorSoft : EsnaftaVarColors.primarySoft,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: error
                ? EsnaftaVarColors.error
                : EsnaftaVarColors.textPrimary,
          ),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Tekrar dene')),
      ],
    ),
  );
}

class MerchantSection extends StatelessWidget {
  const MerchantSection({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

String merchantPrice(double value) =>
    '${value.toStringAsFixed(2).replaceAll('.', ',')} TL';

void merchantSaved(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
