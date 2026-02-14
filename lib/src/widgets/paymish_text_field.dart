import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/color_utils.dart';
import '../utils/dimens.dart';
import '../utils/image_constants.dart';

// ignore: file_names
class PaymishTextField extends StatefulWidget {
  final double? width;
  final String? label;
  final String? hint;
  final FocusNode? focusNode;
  final TextInputType? type;
  final String? trailingIcon;
  final String? leadingIcon;
  final int? maxLength;
  final bool isLeadingIcon;
  final bool isPassword;
  final bool enabled;
  final bool isObscureText;
  final bool isHeaderVisible;
  final bool isDropdown;
  final bool isPrefixCountryCode;
  final String? prefixCountryCode;
  final String? initialValue;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? textInputFormatter;
  final TextEditingController? controller;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validateFunction;
  final ValueChanged<bool>? endIconClick;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;

  const PaymishTextField({
    Key? key,
    this.width,
    this.label,
    this.hint,
    this.focusNode,
    this.type,
    this.leadingIcon,
    this.trailingIcon,
    this.isObscureText = false,
    this.textInputAction,
    this.isPassword = false,
    this.isLeadingIcon = false,
    this.enabled = true,
    this.initialValue,
    this.onSaved,
    this.maxLength,
    this.validateFunction,
    this.endIconClick,
    this.onFieldSubmitted,
    this.textInputFormatter,
    this.onChanged,
    this.isHeaderVisible = false,
    this.isDropdown = false,
    this.isPrefixCountryCode = false,
    this.prefixCountryCode,
    this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PaymishTextFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('width', width));
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('hint', hint));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
    properties.add(DiagnosticsProperty<TextInputType>('type', type));
    properties.add(StringProperty('trailingIcon', trailingIcon));
    properties.add(StringProperty('leadingIcon', leadingIcon));
    properties.add(IntProperty('maxLength', maxLength));
    properties.add(StringProperty('prefixCountryCode', prefixCountryCode));
    properties.add(StringProperty('initialValue', initialValue));
    properties.add(EnumProperty<TextInputAction>('textInputAction', textInputAction));
    properties.add(IterableProperty<TextInputFormatter>('textInputFormatter', textInputFormatter));
    properties.add(DiagnosticsProperty<TextEditingController>('controller', controller));
    properties.add(DiagnosticsProperty<Function>('onSaved', onSaved));
    properties.add(DiagnosticsProperty<Function>('validateFunction', validateFunction));
    properties.add(DiagnosticsProperty<Function>('endIconClick', endIconClick));
    properties.add(DiagnosticsProperty<Function>('onFieldSubmitted', onFieldSubmitted));
    properties.add(DiagnosticsProperty<Function>('onChanged', onChanged));
    properties.add(DiagnosticsProperty<bool>('isLeadingIcon', isLeadingIcon));
    properties.add(DiagnosticsProperty<bool>('isPassword', isPassword));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
    properties.add(DiagnosticsProperty<bool>('isObscureText', isObscureText));
    properties.add(DiagnosticsProperty<bool>('isHeaderVisible', isHeaderVisible));
    properties.add(DiagnosticsProperty<bool>('isDropdown', isDropdown));
    properties.add(DiagnosticsProperty<bool>('isPrefixCountryCode', isPrefixCountryCode));
  }
}

class PaymishTextFieldState extends State<PaymishTextField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.isObscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.isHeaderVisible
            ? Padding(
                padding: const EdgeInsets.only(top: spacingMedium, bottom: 0),
                child: Text(
                  widget.label ?? '',
                  style: const TextStyle(
                    color: ColorUtils.primaryColor,
                    fontSize: fontMedium,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              )
            : const SizedBox.shrink(),
        TextFormField(
          controller: widget.controller,
          textInputAction: widget.textInputAction,
          maxLength: widget.maxLength,
          focusNode: widget.focusNode,
          initialValue: widget.controller == null ? widget.initialValue : null,
          enabled: widget.enabled,
          style: const TextStyle(
            color: ColorUtils.primaryColor,
            fontSize: fontLarge,
          ),
          decoration: InputDecoration(
            labelText: widget.hint,
            contentPadding: const EdgeInsets.only(top: 0),
            counter: const Offstage(),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            errorStyle: const TextStyle(color: Colors.red),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            errorMaxLines: 3,
            hintStyle: const TextStyle(
              fontSize: fontLarge,
              color: ColorUtils.accentColor,
              fontWeight: FontWeight.w500,
            ),
            labelStyle: const TextStyle(
              fontSize: fontLarge,
              color: ColorUtils.primaryColor,
              fontWeight: FontWeight.w500,
              inherit: true,
            ),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorUtils.accentColor, width: 1)),
            suffixIcon: _suffixIconCheck(),
            prefixText: widget.isPrefixCountryCode == true
                ? widget.prefixCountryCode
                : null,
            prefixStyle: widget.isPrefixCountryCode == true
                ? const TextStyle(
                    color: ColorUtils.primaryColor,
                    fontSize: fontLarge,
                  )
                : null,
            prefixIcon: widget.isLeadingIcon && widget.leadingIcon != null
                ? Image.asset(
                    widget.leadingIcon!,
                    width: 1,
                    scale: 1.7,
                    height: 1,
                  )
                : null,
          ),
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validateFunction,
          onSaved: widget.onSaved,
          inputFormatters: widget.textInputFormatter,
          keyboardType: widget.type,
          obscureText: _isObscure,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }

  Widget? _suffixIconCheck() {
    if (!widget.isPassword) {
      if (widget.trailingIcon == null) return null;
      return GestureDetector(
        onTap: () => widget.endIconClick?.call(_isObscure),
        child: Padding(
          padding: const EdgeInsets.all(spacingSmall),
          child: Image.asset(
            widget.trailingIcon!,
            width: imageMTiny,
            height: imageMTiny,
            scale: 2,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isObscure = !_isObscure;
        });
        widget.endIconClick?.call(_isObscure);
      },
      child: Padding(
        padding: const EdgeInsets.all(spacingSmall),
        child: Image.asset(
          _isObscure
              ? ImageConstants.icPasswordEye
              : ImageConstants.icPasswordEyeOpen,
          width: imageMTiny,
          height: imageMTiny,
          scale: 1.3,
        ),
      ),
    );
  }
}
