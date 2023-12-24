import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LigthTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String label;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final void Function()? onTapSuffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextStyle? textFormStyle;
  final TextAlign? textFormAlign;

  /// A "validação de sucesso" é interpretada semanticamente como uma mensagem de erro pelo TextFormField.
  /// Em outras palavras, ao usar [globalKey.currentState?.validate()], o estado do formulário será marcado
  /// como inválido se essa função for aplicada.
  /// Para acionar algum evento quando o formulário estiver válido, deve-se usar a propriedade [onSuccessForm].
  final String? Function(String?)? validatorSuccess;
  final VoidCallback? onSuccessForm;
  final void Function()? onFocus;
  final void Function()? onBlur;
  final void Function(String text)? onSubmit;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool enabled;
  final int? maxLines;
  final int? hintMaxLines;
  final String? initialValue;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget? prefixIcon;
  final bool isFilled;
  final BorderRadius? borderRadius;
  final void Function(String)? onFieldSubmitted;

  const LigthTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.label = '',
    this.keyboardType,
    this.suffixIcon,
    this.onTapSuffixIcon,
    this.inputFormatters,
    this.validator,
    this.onBlur,
    this.onFocus,
    this.onSubmit,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.maxLines = 1,
    this.hintMaxLines,
    this.initialValue,
    this.maxLength,
    this.focusNode,
    this.autofocus = false,
    this.prefixIcon,
    this.validatorSuccess,
    this.onSuccessForm,
    this.isFilled = true,
    this.borderRadius,
    this.onFieldSubmitted,
    this.textFormStyle,
    this.textFormAlign,
  });

  @override
  State<LigthTextFormField> createState() => _LigthTextFormFieldState();
}

class _LigthTextFormFieldState extends State<LigthTextFormField> {
  bool iconVisibility = false;
  late final List<TextInputFormatter>? inputFormatters;
  late final Listenable listenableInputMessages;

  final errorMessage = ValueNotifier('');
  final sucessMessage = ValueNotifier('');

  late final theme = Theme.of(context);
  late final salaryTextTheme = theme.textTheme;

  Widget? _hasInputPassword() {
    if (widget.keyboardType == TextInputType.visiblePassword) {
      return iconVisibility
          ? const Icon(Icons.keyboard_arrow_down)
          : const Icon(Icons.keyboard_arrow_up);
    }

    return widget.suffixIcon ?? const SizedBox();
  }

  void Function()? _onTapSuffixIcon() {
    if (widget.keyboardType == TextInputType.visiblePassword) {
      return () {
        iconVisibility = !iconVisibility;
        setState(() {});
      };
    }

    return widget.onTapSuffixIcon;
  }

  void submit(String? text) {
    if (text != null && widget.onSubmit != null) {
      widget.onSubmit!(text);
    }
  }

  @override
  void initState() {
    inputFormatters = widget.keyboardType == TextInputType.number
        ? [FilteringTextInputFormatter.digitsOnly, ...?widget.inputFormatters]
        : [...?widget.inputFormatters];
    iconVisibility = widget.keyboardType == TextInputType.visiblePassword;
    listenableInputMessages = Listenable.merge([errorMessage, sucessMessage]);
    listenableInputMessages.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    listenableInputMessages.removeListener(() {});
    errorMessage.dispose();
    sucessMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        FocusScope(
          onFocusChange: (value) {
            if (value && widget.onFocus != null) {
              widget.onFocus!();
            } else if (!value && widget.onBlur != null) {
              widget.onBlur!();
              submit(widget.controller?.text);
            }
          },
          child: TextFormField(
            autofocus: widget.autofocus,
            controller: widget.controller,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            obscureText: iconVisibility,
            inputFormatters: inputFormatters,
            validator: (value) {
              if (widget.validator != null) {
                final validationResult = widget.validator!(value);
                errorMessage.value = validationResult ?? '';

                if (validationResult != null) return validationResult;
              }

              if (widget.validatorSuccess != null) {
                final result = widget.validatorSuccess!(value);
                if (result != null) {
                  sucessMessage.value = result;
                  if (widget.onSuccessForm != null) widget.onSuccessForm!();
                  return result;
                }
              }

              return null;
            },
            textAlign: widget.textFormAlign ?? TextAlign.start,
            onFieldSubmitted: widget.onFieldSubmitted,
            onTap: widget.onTap,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            initialValue: widget.initialValue,
            maxLength: widget.maxLength,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              errorStyle: const TextStyle(color: Colors.transparent),
              hintMaxLines: widget.hintMaxLines,
              label: Text(
                widget.label,
              ),
              hintText: widget.hintText,
              contentPadding: widget.prefixIcon != null
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
                  : null,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: widget.prefixIcon,
                    )
                  : null,
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: InkWell(
                  onTap: _onTapSuffixIcon(),
                  child: _hasInputPassword(),
                ),
              ),
              filled: widget.isFilled,
              fillColor: widget.isFilled ? theme.colorScheme.outline : null,
              border: OutlineInputBorder(
                borderRadius: widget.borderRadius ??
                    const BorderRadius.all(
                      Radius.circular(6),
                    ),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: errorMessage.value.isNotEmpty
                      ? theme.colorScheme.error
                      : const Color(0xFF000000),
                ),
                borderRadius: widget.borderRadius ??
                    const BorderRadius.all(
                      Radius.circular(6),
                    ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: errorMessage.value.isNotEmpty
                      ? theme.colorScheme.error
                      : const Color(0xFF000000),
                ),
                borderRadius: widget.borderRadius ??
                    const BorderRadius.all(
                      Radius.circular(6),
                    ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(),
                borderRadius: widget.borderRadius ??
                    const BorderRadius.all(
                      Radius.circular(6),
                    ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(),
                borderRadius: widget.borderRadius ??
                    const BorderRadius.all(
                      Radius.circular(6),
                    ),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(),
                borderRadius: widget.borderRadius ??
                    const BorderRadius.all(
                      Radius.circular(6),
                    ),
              ),
            ),
          ),
        ),
        Visibility(
          visible:
              errorMessage.value.isNotEmpty || sucessMessage.value.isNotEmpty,
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: errorMessage.value.isNotEmpty
                  ? theme.colorScheme.error
                  : const Color(0xFF000000),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Text(
              errorMessage.value.isNotEmpty
                  ? errorMessage.value
                  : sucessMessage.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: salaryTextTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
