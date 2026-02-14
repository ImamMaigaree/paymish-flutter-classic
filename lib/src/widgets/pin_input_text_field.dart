import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PinEntryType { underline, boxTight, boxLoose }

abstract class PinDecoration {
  /// The style of painting text.
  final TextStyle? textStyle;

  /// The style of obscure text.
  final ObscureStyle obscureStyle;

  /// The error text that will be displayed if any.
  final String errorText;

  /// The style of error text.
  final TextStyle? errorTextStyle;

  final String hintText;

  final TextStyle? hintTextStyle;

  PinEntryType get pinEntryType;

  const PinDecoration({
    this.textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    this.errorTextStyle,
    String? hintText,
    this.hintTextStyle,
  })  : obscureStyle = obscureStyle ?? const ObscureStyle(),
        errorText = errorText ?? '',
        hintText = hintText ?? '';

  /// Creates a copy of this pin decoration with the given fields replaced
  /// by the new values.
  PinDecoration copyWith({
    TextStyle? textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    TextStyle? errorTextStyle,
    String? hintText,
    TextStyle? hintTextStyle,
  });
}

/// The object determine the obscure display
class ObscureStyle {
  /// The wrap line string.
  static const _wrapLine = '\n';

  /// Determine whether replace [obscureText] with number.
  final bool isTextObscure;

  /// The display text when [isTextObscure] is true, default is '*'
  /// Do Not pass multiline string, it's not a good idea.
  final String obscureText;

  const ObscureStyle({
    this.isTextObscure = false,
    this.obscureText = '*',
  });
}

/// The object determine the underline color etc.
class UnderlineDecoration extends PinDecoration {
  /// The space between text and underline.
  final double gapSpace;

  /// The gaps between every two adjacent box, higher priority than [gapSpace].
  final List<double>? gapSpaces;

  /// The color of the underline.
  final Color color;

  /// The height of the underline.
  final double lineHeight;

  /// The underline changed color when user enter pin.
  final Color enteredColor;

  const UnderlineDecoration({
    super.textStyle,
    super.obscureStyle,
    super.errorText,
    super.errorTextStyle,
    super.hintText,
    super.hintTextStyle,
    Color? enteredColor,
    this.gapSpace = 16.0,
    this.gapSpaces,
    this.color = Colors.grey,
    this.lineHeight = 2.0,
  }) : enteredColor = enteredColor ?? Colors.grey;

  @override
  PinEntryType get pinEntryType => PinEntryType.underline;

  @override
  PinDecoration copyWith({
    TextStyle? textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    TextStyle? errorTextStyle,
    String? hintText,
    TextStyle? hintTextStyle,
  }) {
    return UnderlineDecoration(
      textStyle: textStyle ?? this.textStyle,
      obscureStyle: obscureStyle ?? this.obscureStyle,
      errorText: errorText ?? this.errorText,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      hintText: hintText ?? this.hintText,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      enteredColor: enteredColor,
      color: color,
      gapSpace: gapSpace,
      lineHeight: lineHeight,
      gapSpaces: gapSpaces,
    );
  }
}

/// The object determine the box stroke etc.
class BoxTightDecoration extends PinDecoration {
  /// The box border width.
  final double strokeWidth;

  /// The box border radius.
  final Radius radius;

  /// The box border color.
  final Color strokeColor;

  /// The box inside solid color, sometimes it equals to the box background.
  final Color solidColor;

  const BoxTightDecoration({
    super.textStyle,
    super.obscureStyle,
    super.errorText,
    super.errorTextStyle,
    super.hintText,
    super.hintTextStyle,
    Color? solidColor,
    this.strokeWidth = 1.0,
    this.radius = const Radius.circular(8.0),
    this.strokeColor = Colors.grey,
  }) : solidColor = solidColor ?? Colors.transparent;

  @override
  PinEntryType get pinEntryType => PinEntryType.boxTight;

  @override
  PinDecoration copyWith({
    TextStyle? textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    TextStyle? errorTextStyle,
    String? hintText,
    TextStyle? hintTextStyle,
  }) {
    return BoxTightDecoration(
      textStyle: textStyle ?? this.textStyle,
      obscureStyle: obscureStyle ?? this.obscureStyle,
      errorText: errorText ?? this.errorText,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      hintText: hintText ?? this.hintText,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      solidColor: solidColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      radius: radius,
    );
  }
}

/// The object determine the box stroke etc.
class BoxLooseDecoration extends PinDecoration {
  /// The box border radius.
  final Radius radius;

  /// The box border width.
  final double strokeWidth;

  /// The adjacent box gap.
  final double gapSpace;

  /// The gaps between every two adjacent box, higher priority than [gapSpace].
  final List<double>? gapSpaces;

  /// The box border color.
  final Color strokeColor;

  /// The box inside solid color, sometimes it equals to the box background.
  final Color solidColor;

  /// The border changed color when user enter pin.
  final Color enteredColor;

  const BoxLooseDecoration({
    super.textStyle,
    super.obscureStyle,
    super.errorText,
    super.errorTextStyle,
    super.hintText,
    super.hintTextStyle,
    Color? enteredColor,
    Color? solidColor,
    this.radius = const Radius.circular(8.0),
    this.strokeWidth = 1.0,
    this.gapSpace = 16.0,
    this.gapSpaces,
    this.strokeColor = Colors.grey,
  })  : enteredColor = enteredColor ?? Colors.grey,
        solidColor = solidColor ?? Colors.transparent;

  @override
  PinEntryType get pinEntryType => PinEntryType.boxLoose;

  @override
  PinDecoration copyWith({
    TextStyle? textStyle,
    ObscureStyle? obscureStyle,
    String? errorText,
    TextStyle? errorTextStyle,
    String? hintText,
    TextStyle? hintTextStyle,
  }) {
    return BoxLooseDecoration(
      textStyle: textStyle ?? this.textStyle,
      obscureStyle: obscureStyle ?? this.obscureStyle,
      errorText: errorText ?? this.errorText,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      hintText: hintText ?? this.hintText,
      hintTextStyle: hintTextStyle ?? this.hintTextStyle,
      solidColor: solidColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      radius: radius,
      enteredColor: enteredColor,
      gapSpace: gapSpace,
      gapSpaces: gapSpaces,
    );
  }
}

class PinInputTextField extends StatefulWidget {
  /// The max length of pin.
  final int pinLength;

  /// The callback will execute when user click done.
  final ValueChanged<String>? onSubmit;

  /// Decorate the pin.
  final PinDecoration decoration;

  /// Just like [TextField]'s inputFormatter.
  final List<TextInputFormatter> inputFormatters;

  /// Just like [TextField]'s keyboardType.
  final TextInputType keyboardType;

  /// Controls the pin being edited.
  final TextEditingController? controller;

  /// Same as [TextField]'s autoFocus.
  final bool autoFocus;

  /// Same as [TextField]'s focusNode.
  final FocusNode? focusNode;

  /// Same as [TextField]'s textInputAction.
  final TextInputAction textInputAction;

  /// Same as [TextField]'s enabled.
  final bool enabled;

  /// Same as [TextField]'s onChanged.
  final ValueChanged<String>? onChanged;

  PinInputTextField({
    Key? key,
    this.pinLength = 6,
    this.onSubmit,
    this.decoration = const BoxLooseDecoration(),
    List<TextInputFormatter>? inputFormatter,
    this.keyboardType = TextInputType.phone,
    this.controller,
    this.focusNode,
    this.autoFocus = false,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.onChanged,
  })  : assert(pinLength > 0),
        assert(decoration.hintText.isEmpty ||
            decoration.hintText.length == pinLength),
        inputFormatters = (inputFormatter ?? <TextInputFormatter>[])
          ..add(LengthLimitingTextInputFormatter(pinLength)),
        super(key: key);

  @override
  State<PinInputTextField> createState() => _PinInputTextFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('pinLength', pinLength));
    properties
        .add(DiagnosticsProperty<PinDecoration>('decoration', decoration));
    properties.add(IterableProperty<TextInputFormatter>(
        'inputFormatters', inputFormatters));
    properties
        .add(DiagnosticsProperty<TextInputType>('keyboardType', keyboardType));
    properties.add(
        DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(DiagnosticsProperty<bool>('autoFocus', autoFocus));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
    properties
        .add(EnumProperty<TextInputAction>('textInputAction', textInputAction));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
    properties.add(DiagnosticsProperty<Function>('onSubmit', onSubmit));
    properties.add(DiagnosticsProperty<Function>('onChanged', onChanged));
  }
}

class _PinInputTextFieldState extends State<PinInputTextField> {
  /// The display text to the user.
  String _text = '';

  TextEditingController? _controller;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!;

  void _pinChanged() {
    setState(_updateText);
  }

  void _updateText() {
    final currentText = _effectiveController.text;
    if (currentText.runes.length > widget.pinLength) {
      _text = String.fromCharCodes(
          currentText.runes.take(widget.pinLength));
    } else {
      _text = currentText;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
    }
    _effectiveController.addListener(_pinChanged);
    _updateText();
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_pinChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PinInputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_pinChanged);
      widget.controller?.addListener(_pinChanged);
    }

    if (oldWidget.pinLength > widget.pinLength &&
        _text.runes.length > widget.pinLength) {
      setState(() {
        _text = _text.substring(0, widget.pinLength);
        _effectiveController.text = _text;
        _effectiveController.selection =
            TextSelection.collapsed(offset: _text.runes.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _PinPaint(
        text: _text,
        pinLength: widget.pinLength,
        decoration: widget.decoration,
        themeData: Theme.of(context),
      ),
      child: TextField(
        controller: _effectiveController,
        style: const TextStyle(color: Colors.transparent, fontSize: 1),
        cursorColor: Colors.transparent,
        cursorWidth: 0.0,
        autocorrect: false,
        textAlign: TextAlign.center,
        enableInteractiveSelection: false,
        maxLength: widget.pinLength,
        onSubmitted: widget.onSubmit,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        focusNode: widget.focusNode,
        autofocus: widget.autoFocus,
        textInputAction: widget.textInputAction,
        obscureText: true,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          counterText: '',
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          errorText: widget.decoration.errorText.isEmpty
              ? null
              : widget.decoration.errorText,
          errorStyle: widget.decoration.errorTextStyle,
        ),
        enabled: widget.enabled,
      ),
    );
  }
}

class _PinPaint extends CustomPainter {
  final String text;
  final int pinLength;
  final PinEntryType type;
  final PinDecoration decoration;
  final ThemeData themeData;

  _PinPaint({
    required this.text,
    required this.pinLength,
    PinDecoration? decoration,
    required this.themeData,
  })  : decoration = (decoration ?? const BoxLooseDecoration()).copyWith(
          textStyle: decoration?.textStyle ?? themeData.textTheme.headlineSmall,
          errorTextStyle: decoration?.errorTextStyle ??
              themeData.textTheme.bodySmall
                  ?.copyWith(color: themeData.colorScheme.error),
          hintTextStyle: decoration?.hintTextStyle ??
              themeData.textTheme.headlineSmall
                  ?.copyWith(color: themeData.hintColor),
        ),
        type = (decoration ?? const BoxLooseDecoration()).pinEntryType;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
      !(oldDelegate is _PinPaint && oldDelegate.text == text);

  void _drawBoxTight(Canvas canvas, Size size) {
    double mainHeight;
    if (decoration.errorText.isNotEmpty) {
      final fontSize = decoration.errorTextStyle?.fontSize ?? 12.0;
      mainHeight = size.height - (fontSize + 8.0);
    } else {
      mainHeight = size.height;
    }

    final dr = decoration as BoxTightDecoration;
    final borderPaint = Paint()
      ..color = dr.strokeColor
      ..strokeWidth = dr.strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final insidePaint = Paint()
      ..color = dr.solidColor
      ..strokeWidth = dr.strokeWidth
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final rect = Rect.fromLTRB(
      dr.strokeWidth / 2,
      dr.strokeWidth / 2,
      size.width - dr.strokeWidth / 2,
      mainHeight - dr.strokeWidth / 2,
    );

    canvas.drawRRect(RRect.fromRectAndRadius(rect, dr.radius), insidePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, dr.radius), borderPaint);

    final singleWidth =
        (size.width - dr.strokeWidth * (pinLength + 1)) / pinLength;

    for (var i = 1; i < pinLength; i++) {
      final offsetX = singleWidth +
          dr.strokeWidth * i +
          dr.strokeWidth / 2 +
          singleWidth * (i - 1);
      canvas.drawLine(Offset(offsetX, dr.strokeWidth),
          Offset(offsetX, mainHeight - dr.strokeWidth), borderPaint);
    }

    var index = 0;
    var startY = 0.0;
    var startX = 0.0;

    final obscureOn = decoration.obscureStyle.isTextObscure;

    for (final rune in text.runes) {
      final code = obscureOn
          ? decoration.obscureStyle.obscureText
          : String.fromCharCode(rune);
      final textPainter = TextPainter(
        text: TextSpan(
          style: decoration.textStyle,
          text: code,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      if (startY == 0.0) {
        startY = mainHeight / 2 - textPainter.height / 2;
      }
      startX = dr.strokeWidth * (index + 1) +
          singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2;
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    }

    final remainingHint =
        index < decoration.hintText.length ? decoration.hintText.substring(index) : '';
    remainingHint.runes.forEach((rune) {
      final code = String.fromCharCode(rune);
      final textPainter = TextPainter(
        text: TextSpan(
          style: decoration.hintTextStyle,
          text: code,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      startY = mainHeight / 2 - textPainter.height / 2;
      startX = dr.strokeWidth * (index + 1) +
          singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2;
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    });
  }

  void _drawBoxLoose(Canvas canvas, Size size) {
    double mainHeight;
    if (decoration.errorText.isNotEmpty) {
      final fontSize = decoration.errorTextStyle?.fontSize ?? 12.0;
      mainHeight = size.height - (fontSize + 8.0);
    } else {
      mainHeight = size.height;
    }

    final dr = decoration as BoxLooseDecoration;
    final borderPaint = Paint()
      ..color = dr.strokeColor
      ..strokeWidth = dr.strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    Paint insidePaint = Paint()
      ..color = dr.solidColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final gapSpaces = dr.gapSpaces ?? List.filled(pinLength - 1, dr.gapSpace);
    final gapTotalLength = gapSpaces.fold(0.0, (a, b) => a + b);

    final singleWidth =
        (size.width - dr.strokeWidth * 2 * pinLength - gapTotalLength) /
            pinLength;

    var startX = dr.strokeWidth / 2;
    var startY = mainHeight - dr.strokeWidth / 2;

    for (var i = 0; i < pinLength; i++) {
      if (i < text.length) {
        borderPaint.color = dr.enteredColor;
      } else if (decoration.errorText.isNotEmpty) {
        insidePaint = Paint()
          ..color = decoration.errorTextStyle?.color ?? dr.strokeColor
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
      } else {
        borderPaint.color = dr.strokeColor;
      }
      final rRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(
            startX,
            dr.strokeWidth / 2,
            startX + singleWidth + dr.strokeWidth,
            startY,
          ),
          dr.radius);
      canvas.drawRRect(rRect, borderPaint);
      canvas.drawRRect(rRect, insidePaint);
      startX += singleWidth +
          dr.strokeWidth * 2 +
          (i == pinLength - 1 ? 0 : gapSpaces[i]);
    }

    var index = 0;
    startY = 0.0;

    final obscureOn = decoration.obscureStyle.isTextObscure;

    for (final rune in text.runes) {
      final code = obscureOn
          ? decoration.obscureStyle.obscureText
          : String.fromCharCode(rune);
      final textPainter = TextPainter(
        text: TextSpan(
          style: decoration.textStyle,
          text: code,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      if (startY == 0.0) {
        startY = mainHeight / 2 - textPainter.height / 2;
      }
      startX = singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2 +
          _sumList(gapSpaces.take(index)) +
          dr.strokeWidth * index * 2 +
          dr.strokeWidth;
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    }

    final remainingHint =
        index < decoration.hintText.length ? decoration.hintText.substring(index) : '';
    remainingHint.runes.forEach((rune) {
      final code = String.fromCharCode(rune);
      final textPainter = TextPainter(
        text: TextSpan(
          style: decoration.hintTextStyle,
          text: code,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      startY = mainHeight / 2 - textPainter.height / 2;
      startX = singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2 +
          _sumList(gapSpaces.take(index)) +
          dr.strokeWidth * index * 2 +
          dr.strokeWidth;
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    });
  }

  void _drawUnderLine(Canvas canvas, Size size) {
    double mainHeight;
    if (decoration.errorText.isNotEmpty) {
      final fontSize = decoration.errorTextStyle?.fontSize ?? 12.0;
      mainHeight = size.height - (fontSize + 8.0);
    } else {
      mainHeight = size.height;
    }

    final dr = decoration as UnderlineDecoration;
    final underlinePaint = Paint()
      ..color = dr.color
      ..strokeWidth = dr.lineHeight
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    var startX = 0.0;
    var startY = mainHeight - dr.lineHeight;

    final gapSpaces = dr.gapSpaces ?? List.filled(pinLength - 1, dr.gapSpace);
    final gapTotalLength = gapSpaces.fold(0.0, (a, b) => a + b);

    final singleWidth = (size.width - gapTotalLength) / pinLength;

    for (var i = 0; i < pinLength; i++) {
      if (i < text.length) {
        underlinePaint.color = dr.enteredColor;
      } else if (decoration.errorText.isNotEmpty) {
        underlinePaint.color = decoration.errorTextStyle?.color ?? dr.color;
      } else {
        underlinePaint.color = dr.color;
      }
      canvas.drawLine(Offset(startX, startY),
          Offset(startX + singleWidth, startY), underlinePaint);
      startX += singleWidth + (i == pinLength - 1 ? 0 : gapSpaces[i]);
    }

    var index = 0;
    startX = 0.0;
    startY = 0.0;

    final obscureOn = decoration.obscureStyle.isTextObscure;

    for (final rune in text.runes) {
      final code = obscureOn
          ? decoration.obscureStyle.obscureText
          : String.fromCharCode(rune);
      final textPainter = TextPainter(
        text: TextSpan(
          style: decoration.textStyle,
          text: code,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      if (startY == 0.0) {
        startY = mainHeight / 2 - textPainter.height / 2;
      }
      startX = singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2 +
          _sumList(gapSpaces.take(index));
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    }

    final remainingHint =
        index < decoration.hintText.length ? decoration.hintText.substring(index) : '';
    remainingHint.runes.forEach((rune) {
      final code = String.fromCharCode(rune);
      final textPainter = TextPainter(
        text: TextSpan(
          style: decoration.hintTextStyle,
          text: code,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      startY = mainHeight / 2 - textPainter.height / 2;
      startX = singleWidth * index +
          singleWidth / 2 -
          textPainter.width / 2 +
          _sumList(gapSpaces.take(index));
      textPainter.paint(canvas, Offset(startX, startY));
      index++;
    });
  }

  double _sumList<T extends num>(Iterable<T> list) {
    var sum = 0.0;
    for (final n in list) {
      sum += n.toDouble();
    }
    return sum;
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case PinEntryType.boxTight:
        _drawBoxTight(canvas, size);
        break;
      case PinEntryType.boxLoose:
        _drawBoxLoose(canvas, size);
        break;
      case PinEntryType.underline:
        _drawUnderLine(canvas, size);
        break;
    }
  }
}

class PinInputTextFormField extends FormField<String> {
  final TextEditingController? controller;
  final int pinLength;

  PinInputTextFormField({
    Key? key,
    this.controller,
    String? initialValue,
    this.pinLength = 6,
    ValueChanged<String>? onSubmit,
    PinDecoration decoration = const BoxLooseDecoration(),
    List<TextInputFormatter>? inputFormatter,
    TextInputType keyboardType = TextInputType.phone,
    FocusNode? focusNode,
    bool autoFocus = false,
    TextInputAction textInputAction = TextInputAction.done,
    bool enabled = true,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    ValueChanged<String>? onChanged,
  })  : assert(pinLength > 0),
        super(
          key: key,
          initialValue: controller?.text ?? initialValue ?? '',
          validator: (value) {
            final result = validator?.call(value);
            final currentValue = value ?? '';
            if (result == null) {
              if (currentValue.isEmpty) {
                return 'Input field is empty.';
              }
              if (currentValue.length < pinLength) {
                if (pinLength - currentValue.length > 1) {
                  return 'Missing ${pinLength - currentValue.length} digits of input.';
                } else {
                  return 'Missing last digit of input.';
                }
              }
            }
            return result;
          },
          autovalidateMode: autovalidateMode,
          onSaved: onSaved,
          enabled: enabled,
          builder: (field) {
            final state = field as _PinInputTextFormFieldState;
            return PinInputTextField(
              pinLength: pinLength,
              onSubmit: onSubmit,
              decoration: decoration.copyWith(errorText: field.errorText),
              inputFormatter: inputFormatter,
              keyboardType: keyboardType,
              controller: state._effectiveController,
              focusNode: focusNode,
              autoFocus: autoFocus,
              textInputAction: textInputAction,
              enabled: enabled,
              onChanged: onChanged,
            );
          },
        );

  @override
  FormFieldState<String> createState() => _PinInputTextFormFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(IntProperty('pinLength', pinLength));
  }
}

class _PinInputTextFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController get _effectiveController =>
      widget.controller ?? _controller!;

  @override
  PinInputTextFormField get widget => super.widget as PinInputTextFormField;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    }
    _effectiveController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(PinInputTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
    }

    final currentValue = value ?? '';
    if (oldWidget.pinLength > widget.pinLength &&
        currentValue.runes.length > widget.pinLength) {
      setState(() {
        final truncated = currentValue.substring(0, widget.pinLength);
        setValue(truncated);
        _effectiveController.text = truncated;
        _effectiveController.selection = TextSelection.collapsed(
          offset: truncated.runes.length,
        );
      });
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController.text = widget.initialValue ?? '';
    });
  }

  @override
  void didChange(String? value) {
    final currentValue = value ?? '';
    if (currentValue.runes.length > widget.pinLength) {
      super.didChange(String.fromCharCodes(
        currentValue.runes.take(widget.pinLength),
      ));
    } else {
      super.didChange(currentValue);
    }
  }

  void _handleControllerChanged() {
    if (_effectiveController.text != (value ?? '')) {
      didChange(_effectiveController.text);
    }
  }
}
