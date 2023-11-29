import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_quill/extensions.dart' as base;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/presentation/models/config/toolbar/buttons/formula.dart';
import 'package:go_router/go_router.dart';
import 'package:math_keyboard/math_keyboard.dart';

class QuillToolbarFormulaButton extends StatelessWidget {
  const QuillToolbarFormulaButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarFormulaButtonOptions options;

  double _iconSize(BuildContext context) {
    final baseFontSize = baseButtonExtraOptions(context).globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  double _iconButtonFactor(BuildContext context) {
    final baseIconFactor =
        baseButtonExtraOptions(context).globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed ??
        baseButtonExtraOptions(context).afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme ?? baseButtonExtraOptions(context).iconTheme;
  }

  QuillToolbarBaseButtonOptions baseButtonExtraOptions(BuildContext context) {
    return context.requireQuillToolbarBaseButtonOptions;
  }

  IconData _iconData(BuildContext context) {
    return options.iconData ??
        baseButtonExtraOptions(context).iconData ??
        Icons.functions;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ??
        baseButtonExtraOptions(context).tooltip ??
        'Insert formula';
    // ('Insert formula'.i18n);
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(context);
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconTheme = _iconTheme(context);

    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconButtonFactor = _iconButtonFactor(context);
    final iconData = _iconData(context);
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions(context).childBuilder;

    final iconColor = iconTheme?.iconUnselectedColor ?? theme.iconTheme.color;
    final iconFillColor = iconTheme?.iconUnselectedFillColor ??
        (options.fillColor ?? theme.canvasColor);

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarFormulaButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          fillColor: iconFillColor,
          iconData: iconData,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          iconTheme: iconTheme,
          tooltip: tooltip,
        ),
        QuillToolbarFormulaButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: Icon(iconData, size: iconSize, color: iconColor),
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: iconFillColor,
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: () => _sharedOnPressed(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    var text = "";
    var temp = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "New Equation",
          style: TextStyle(fontSize: 20),
        ),
        content: Material(
          child: Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                // If the MathField is tapped, hides the built in keyboard
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              }
            },
            child: MathField(
                onChanged: (val) {
                  temp = val;
                },
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          text = temp;
                          context.pop();
                        },
                        icon: const Icon(Icons.check)))),
          ),
        ),
      ),
    );

    if (text == "") return;

    controller.replaceText(index, length, BlockEmbed.formula(text), null);
  }
}

class QuillEditorFormulaEmbedBuilder extends EmbedBuilder {
  const QuillEditorFormulaEmbedBuilder();
  @override
  String get key => BlockEmbed.formulaType;

  @override
  bool get expanded => false;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    base.Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    var text = "";
    var temp = '';

    var value = node.value.data;

    return GestureDetector(
      onTap: () {
        // If the MathField is tapped, hides the built in keyboard
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              "Modify Equation",
              style: TextStyle(fontSize: 20),
            ),
            content: Material(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    // If the MathField is tapped, hides the built in keyboard
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  }
                },
                child: MathField(
                    onChanged: (val) {
                      temp = val;
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () {
                              text = temp;
                              final index = controller.selection.baseOffset;

                              if (text == "") {
                                context.pop();
                                return;
                              }

                              controller.replaceText(
                                  index - 1, 1, BlockEmbed.formula(text), null);

                              context.pop();
                            },
                            icon: const Icon(Icons.check)))),
              ),
            ),
          ),
        );
      },
      child: Math.tex(
        value,
        textStyle: textStyle,
      ),
    );
  }
}
