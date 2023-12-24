import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_light_app/components/text_form_field.dart';

class LigthSelectItem<T> {
  String title;
  String subtitle;
  T value;

  LigthSelectItem(
      {required this.title, required this.value, this.subtitle = ''});
}

class LigthSelect<T> extends StatefulWidget {
  final int totalPages;
  final void Function(String)? onChanged;
  final void Function(LigthSelectItem<T>?)? onTapItem;
  final Future<void> Function(int page)? infinity;
  final void Function(String?)? onDelete;
  final TextEditingController? controller;
  final String? topText;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueNotifier<List<LigthSelectItem<T>>> items;
  final double? width;
  final String label;
  final void Function()? onFocusChange, onFocusChangeOpen;
  final Widget? Function(int)? preffixIconTable;
  final bool autofocus;
  final TextInputType? keyboardType;
  final IconData? iconClose;
  final IconData? iconOpen;
  final int minSizeListToOpenDropDownMenu;
  final bool forceShowKeyboard;
  final List<TextInputFormatter> formatters;

  const LigthSelect({
    Key? key,
    this.infinity,
    required this.items,
    this.controller,
    this.onTapItem,
    this.totalPages = 20,
    this.onChanged,
    this.validator,
    this.width,
    this.onDelete,
    this.topText,
    this.hintText,
    this.label = '',
    this.onFocusChange,
    this.onFocusChangeOpen,
    this.preffixIconTable,
    this.autofocus = false,
    this.keyboardType,
    this.iconClose,
    this.iconOpen,
    this.minSizeListToOpenDropDownMenu = 0,
    this.forceShowKeyboard = false,
    this.formatters = const [],
  }) : super(key: key);

  @override
  State<LigthSelect<T>> createState() => _LigthSelect<T>();
}

class _LigthSelect<T> extends State<LigthSelect<T>> {
  late final TextEditingController controller;
  late void Function(LigthSelectItem<T>?) onTapItem;
  late final size = MediaQuery.sizeOf(context);
  late final FocusScopeNode currentFocus = FocusScope.of(context);
  late final theme = Theme.of(context);
  late final textTheme = theme.textTheme;

  int page = 1;

  ValueNotifier<List<LigthSelectItem<T>>> filteredItems = ValueNotifier([]);

  double boxList = 0.0;

  Future onRefresh() async {
    if (page <= widget.totalPages && widget.infinity != null) {
      await widget.infinity!(page);
      page++;
    }
  }

  double calculateSizeListToOpenDropDownMenu() {
    bool containsMatchingTitle = widget.items.value.any(
      (item) => item.title.toLowerCase() == controller.text.toLowerCase(),
    );

    if (containsMatchingTitle) {
      return boxList;
    }

    if (widget.minSizeListToOpenDropDownMenu <= controller.text.length) {
      return boxList;
    }

    return 0;
  }

  void filterItems(String text) {
    if (text.isNotEmpty) {
      filteredItems.value = widget.items.value.where((x) {
        return x.title.toLowerCase().contains(text.toLowerCase());
      }).toList();
    } else {
      filteredItems.value = widget.items.value;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    onTapItem = widget.onTapItem ?? (item) {};
    if (mounted) {
      filterItems("");
      setState(() {});
    }
    controller.addListener(() {
      setState(() {});
    });
  }

  TextInputType? handleKeyboardType() {
    if (widget.forceShowKeyboard) {
      return widget.keyboardType;
    }
    if (widget.items.value.length < 30) {
      return TextInputType.none;
    }
    return widget.keyboardType;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      child: Column(
        children: [
          FocusScope(
            onFocusChange: (value) {
              if (value && widget.items.value.isNotEmpty) {
                if (widget.onFocusChangeOpen != null) {
                  widget.onFocusChangeOpen!();
                }
                boxList = 200; // widget.items.value.length <= 5 ? 200 : 300;
                setState(() {});
              } else if (!value) {
                boxList = 0.0;
                setState(() {});
              }
              if (widget.onFocusChange != null) {
                widget.onFocusChange!();
              }
            },
            child: AnimatedBuilder(
              animation: widget.items,
              builder: (context, child) {
                return LigthTextFormField(
                  keyboardType: handleKeyboardType(),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(6),
                    topRight: const Radius.circular(6),
                    bottomLeft: Radius.circular(boxList > 0 ? 0 : 6),
                    bottomRight: Radius.circular(boxList > 0 ? 0 : 6),
                  ),
                  validator: widget.validator,
                  controller: controller,
                  hintText: widget.hintText ?? 'Infome',
                  label: widget.label,
                  enabled: widget.items.value.isNotEmpty,
                  autofocus: widget.autofocus,
                  inputFormatters: widget.formatters,
                  suffixIcon: Container(
                    padding: const EdgeInsets.only(right: 5),
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (boxList > 0) {
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                boxList = 0.0;
                              } else {
                                boxList = widget.items.value.length <= 5 &&
                                        widget.items.value.isNotEmpty
                                    ? 200
                                    : 350;
                              }
                            });
                          },
                          child: Icon(
                            (boxList > 0)
                                ? widget.iconClose ?? Icons.arrow_downward
                                : widget.iconOpen ?? Icons.arrow_upward,
                            color: widget.items.value.isEmpty
                                ? null
                                : theme.colorScheme.outline,
                            size: 15,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                  onChanged: (value) {
                    filterItems(value);
                    if (widget.onChanged != null) widget.onChanged!(value);
                  },
                );
              },
            ),
          ),
          Transform.rotate(
            angle: pi,
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: Container(
                height: calculateSizeListToOpenDropDownMenu(),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                child: AnimatedBuilder(
                  animation: filteredItems,
                  builder: (context, snapshot) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredItems.value.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final textWidget = Text(
                                filteredItems.value[index].title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: controller.text ==
                                          filteredItems.value[index].title
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onPrimary,
                                ),
                              );

                              return Transform.rotate(
                                angle: pi,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        controller.text =
                                            filteredItems.value[index].title;
                                        if (boxList > 0.0) {
                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                          setState(() {
                                            boxList = 0.0;
                                          });
                                        }

                                        onTapItem(filteredItems.value[index]);
                                      },
                                      child: Container(
                                        width: double.maxFinite,
                                        color: controller.text ==
                                                filteredItems.value[index].title
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.outline,
                                        padding: const EdgeInsets.only(
                                          top: 13,
                                          bottom: 13,
                                          left: 10,
                                        ),
                                        child: widget.preffixIconTable == null
                                            ? textWidget
                                            : Row(
                                                children: [
                                                  widget.preffixIconTable!(
                                                          index) ??
                                                      const SizedBox(),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  SizedBox(
                                                    width: size.width * 0.8,
                                                    child: textWidget,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          height: 1,
                          color: theme.colorScheme.background,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
